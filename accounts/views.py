from django.db import models
from django.shortcuts import get_object_or_404
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status, generics, permissions
from rest_framework.permissions import IsAuthenticated
from .models import *
from django.db import transaction
from django.db.models import Q, Sum, F
from .serializers import *
from .permissions import IsSupplier
from django.utils import timezone

class RegisterView(APIView):
    def post(self, request):
        serializer = RegisterSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response({"message": "User registered successfully"}, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class LoginView(APIView):
    def post(self, request):
        serializer = LoginSerializer(data=request.data)
        if serializer.is_valid():
            return Response(serializer.validated_data, status=status.HTTP_200_OK)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class SupplierProductListCreateView(generics.ListCreateAPIView):
    serializer_class = ProductSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return Product.objects.filter(supplier=self.request.user)


class SupplierProductDetailView(generics.RetrieveUpdateDestroyAPIView):
    serializer_class = ProductSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return Product.objects.filter(supplier=self.request.user)

class ProductStatusToggleView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def patch(self, request, pk):
        try:
            product = Product.objects.get(id=pk, supplier=request.user)
        except Product.DoesNotExist:
            return Response({"error": "Not found or not your product"}, status=status.HTTP_404_NOT_FOUND)

        product.status = "inactive" if product.status == "active" else "active"
        product.save()

        return Response({"message": f"Status changed to {product.status}"}, status=status.HTTP_200_OK)

class SendLinkRequestView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        if request.user.role != 'consumer':
            return Response({"detail": "Only consumers can send link requests"}, status=403)

        supplier_id = request.data.get("supplier_id")
        supplier = get_object_or_404(User, id=supplier_id, role='supplier')

        existing = LinkRequest.objects.filter(consumer=request.user, supplier=supplier).first()
        if existing:
            return Response({"detail": f"Link already exists (status={existing.status})"}, status=400)

        link = LinkRequest.objects.create(consumer=request.user, supplier=supplier, status="pending")
        return Response({"message": "Request sent", "link_id": link.id}, status=201)


class SupplierLinkListView(generics.ListAPIView):
    permission_classes = [IsAuthenticated]
    serializer_class = LinkRequestSerializer

    def get_queryset(self):
        return LinkRequest.objects.filter(supplier=self.request.user)


class UnlinkView(APIView):
    permission_classes = [IsAuthenticated]

    def delete(self, request, link_id):
        link = LinkRequest.objects.filter(
            id=link_id
        ).filter(
            models.Q(supplier=request.user) | models.Q(consumer=request.user)
        ).first()

        if not link:
            return Response({"detail": "Not found or not allowed"}, status=404)

        link.delete()
        return Response({"detail": "Unlinked successfully"}, status=200)



class AcceptLinkView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request, link_id):
        link = get_object_or_404(LinkRequest, id=link_id, supplier=request.user)
        if link.status == "blocked":
            return Response({"detail": "User is blocked, cannot accept"}, status=400)
        link.status = "linked"
        link.save()
        return Response({"detail": "Accepted"}, status=200)


class RejectLinkView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request, link_id):
        link = get_object_or_404(LinkRequest, id=link_id, supplier=request.user)
        link.status = "rejected"
        link.save()
        return Response({"detail": "Rejected"}, status=200)


class BlockLinkView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request, link_id):
        link = get_object_or_404(LinkRequest, id=link_id, supplier=request.user)
        link.status = "blocked"
        link.save()
        return Response({"detail": "Blocked"}, status=200)


class UnblockLinkView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request, link_id):
        link = get_object_or_404(LinkRequest, id=link_id, supplier=request.user)
        link.status = "pending"
        link.save()
        return Response({"detail": "Unblocked"}, status=200)

class AllSuppliersView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        if request.user.role != "consumer":
            return Response({"detail": "Only consumers can view suppliers"}, status=403)

        suppliers = User.objects.filter(role="supplier")
        serializer = SupplierSerializer(suppliers, many=True)
        return Response(serializer.data, status=200)


class ConsumerLinkListView(generics.ListAPIView):
    permission_classes = [IsAuthenticated]
    serializer_class = LinkRequestSerializer

    def get_queryset(self):
        return LinkRequest.objects.filter(consumer=self.request.user)

class SupplierCatalogView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request, supplier_id):
        link = LinkRequest.objects.filter(
            supplier_id=supplier_id,
            consumer=request.user,
            status="linked"
        ).first()

        if not link:
            return Response(
                {"detail": "You are not linked with this supplier"},
                status=403
            )

        products = (
            Product.objects
            .filter(supplier_id=supplier_id, status="active")
            .order_by("name")
        )
        serializer = ProductSerializer(products, many=True)
        return Response(serializer.data, status=200)

#view check postman
class CartAddView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        if request.user.role != "consumer":
            return Response({"detail": "Only consumers can use cart"}, status=403)

        product_id = request.data.get("product_id")
        try:
            quantity = int(request.data.get("quantity", 1))
        except (TypeError, ValueError):
            return Response({"detail": "Quantity must be a valid number"}, status=400)

        if quantity <= 0:
            return Response({"detail": "Quantity must be > 0"}, status=400)

        product = get_object_or_404(Product, id=product_id, status="active")

        linked = LinkRequest.objects.filter(
            consumer=request.user,
            supplier=product.supplier,
            status="linked",
        ).exists()
        if not linked:
            return Response({"detail": "You must be linked with this supplier"}, status=403)

        if quantity < product.minOrder:
            return Response(
                {"detail": f"Minimum order is {product.minOrder} {product.unit}"},
                status=400,
            )

        if quantity > product.stock:
            return Response(
                {"detail": f"Only {product.stock} {product.unit} available"},
                status=400,
            )

        item, created = CartItem.objects.get_or_create(
            consumer=request.user,
            product=product,
            defaults={"quantity": quantity},
        )
        if not created:
            new_quantity = item.quantity + quantity
            if new_quantity > product.stock:
                return Response(
                    {"detail": f"Only {product.stock} {product.unit} available"},
                    status=400,
                )
            item.quantity = new_quantity
            item.save()

        serializer = CartItemSerializer(item)
        return Response(serializer.data, status=201)


class CartListView(generics.ListAPIView):
    permission_classes = [IsAuthenticated]
    serializer_class = CartItemSerializer

    def get_queryset(self):
        if self.request.user.role != "consumer":
            return CartItem.objects.none()
        return (
            CartItem.objects
            .filter(consumer=self.request.user)
            .select_related("product", "product__supplier")
            .order_by("-added_at")
        )


class CartItemUpdateDeleteView(APIView):
    permission_classes = [IsAuthenticated]

    def patch(self, request, item_id):
        item = get_object_or_404(CartItem, id=item_id, consumer=request.user)

        try:
            quantity = int(request.data.get("quantity", 1))
        except (TypeError, ValueError):
            return Response({"detail": "Quantity must be a valid number"}, status=400)

        if quantity <= 0:
            item.delete()
            return Response({"detail": "Item removed (quantity <= 0)"}, status=200)

        product = item.product
        if quantity < product.minOrder:
            return Response(
                {"detail": f"Minimum order is {product.minOrder} {product.unit}"},
                status=400,
            )

        if quantity > product.stock:
            return Response(
                {"detail": f"Only {product.stock} {product.unit} available"},
                status=400,
            )

        item.quantity = quantity
        item.save()
        serializer = CartItemSerializer(item)
        return Response(serializer.data, status=200)

    def delete(self, request, item_id):
        item = get_object_or_404(CartItem, id=item_id, consumer=request.user)
        item.delete()
        return Response({"detail": "Cart item removed"}, status=200)

class CheckoutView(APIView):
    permission_classes = [IsAuthenticated]

    @transaction.atomic
    def post(self, request):
        if request.user.role != "consumer":
            return Response({"detail": "Only consumers can checkout"}, status=403)

        cart_items = (
            CartItem.objects
            .filter(consumer=request.user)
            .select_related("product", "product__supplier")
        )

        if not cart_items.exists():
            return Response({"detail": "Cart is empty"}, status=400)

        # For simplicity: assume all products belong to ONE supplier
        supplier_ids = cart_items.values_list("product__supplier_id", flat=True).distinct()
        if supplier_ids.count() > 1:
            return Response({"detail": "Cart must contain items from one supplier only"}, status=400)

        supplier_id = supplier_ids.first()

        total_price = 0
        for item in cart_items:
            total_price += item.product.price * item.quantity

        order = Order.objects.create(
            consumer=request.user,
            supplier_id=supplier_id,
            total_price=total_price,
            status="pending",
        )

        order_items = []
        for item in cart_items:
            order_items.append(
                OrderItem(
                    order=order,
                    product=item.product,
                    quantity=item.quantity,
                    price=item.product.price,
                )
            )
        OrderItem.objects.bulk_create(order_items)

        # Clear cart
        cart_items.delete()

        serializer = OrderSerializer(order)
        return Response(serializer.data, status=201)


class MyOrdersView(generics.ListAPIView):
    permission_classes = [IsAuthenticated]
    serializer_class = OrderSerializer

    def get_queryset(self):
        if self.request.user.role != "consumer":
            return Order.objects.none()
        return (
            Order.objects
            .filter(consumer=self.request.user)
            .prefetch_related("items__product")
            .order_by("-created_at")
        )


class SupplierOrdersView(generics.ListAPIView):
    permission_classes = [IsAuthenticated]
    serializer_class = OrderSerializer

    def get_queryset(self):
        if self.request.user.role != "supplier":
            return Order.objects.none()
        return (
            Order.objects
            .filter(supplier=self.request.user)
            .prefetch_related("items__product")
            .order_by("-created_at")
        )

def get_or_create_room(consumer, supplier):
    room, _ = ChatRoom.objects.get_or_create(consumer=consumer, supplier=supplier)
    return room


class ChatHistoryView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request, partner_id):
        user = request.user

        if user.role == "consumer":
            supplier = get_object_or_404(User, id=partner_id, role="supplier")
            consumer = user

        elif user.role == "supplier":
            consumer = get_object_or_404(User, id=partner_id, role="consumer")
            supplier = user

        else:
            return Response({"detail": "Access denied"}, status=403)

        linked = LinkRequest.objects.filter(
            consumer=consumer,
            supplier=supplier,
            status="linked"
        ).exists()

        if not linked:
            return Response({"detail": "Not linked"}, status=403)

        room = get_or_create_room(consumer, supplier)
        messages = room.messages.select_related("sender").order_by("timestamp")

        serializer = MessageSerializer(messages, many=True)
        return Response(serializer.data, status=200)



class SendMessageView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request, supplier_id):
        user = request.user

        text = request.data.get("text", "").strip()
        if not text:
            return Response({"detail": "Text is required"}, status=400)

        # who is talking? consumer or supplier
        supplier = get_object_or_404(User, id=supplier_id, role="supplier")

        if user.role == "consumer":
            consumer = user
        elif user.role == "supplier":
            # supplier can also send messages to consumer
            consumer_id = request.data.get("consumer_id")
            if not consumer_id:
                return Response({"detail": "consumer_id is required"}, status=400)
            consumer = get_object_or_404(User, id=consumer_id, role="consumer")
        else:
            return Response({"detail": "Only consumers or suppliers can chat"}, status=403)

        linked = LinkRequest.objects.filter(
            consumer=consumer,
            supplier=supplier,
            status="linked"
        ).exists()
        if not linked:
            return Response({"detail": "No active link between users"}, status=403)

        room = get_or_create_room(consumer, supplier)

        msg = Message.objects.create(
            room=room,
            sender=user,
            text=text,
        )

        serializer = MessageSerializer(msg)
        return Response(serializer.data, status=201)

class SupplierAcceptOrderView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request, order_id):
        if request.user.role != "supplier":
            return Response({"detail": "Only suppliers can accept orders"}, status=403)

        order = get_object_or_404(Order, id=order_id, supplier=request.user)

        if order.status != "pending":
            return Response({"detail": "Order already processed"}, status=400)

        order.status = "approved"
        order.save()
        return Response({"detail": "Order approved"}, status=200)


class SupplierRejectOrderView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request, order_id):
        if request.user.role != "supplier":
            return Response({"detail": "Only suppliers can reject orders"}, status=403)

        order = get_object_or_404(Order, id=order_id, supplier=request.user)

        if order.status != "pending":
            return Response({"detail": "Order already processed"}, status=400)

        order.status = "cancelled"
        order.save()

        return Response({"detail": "Order rejected"}, status=200)


class CreateComplaintView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request, order_id):
        if request.user.role != "consumer":
            return Response({"detail": "Only consumers can file complaints"}, status=403)

        order = get_object_or_404(Order, id=order_id, consumer=request.user)

        serializer = ComplaintSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save(
                consumer=request.user,
                supplier=order.supplier,
                order=order,
            )
            return Response(serializer.data, status=201)

        return Response(serializer.errors, status=400)

class SupplierComplaintListView(generics.ListAPIView):
    permission_classes = [IsAuthenticated]
    serializer_class = ComplaintSerializer

    def get_queryset(self):
        if self.request.user.role != "supplier":
            return Complaint.objects.none()
        return Complaint.objects.filter(supplier=self.request.user).order_by("-created_at")

class SupplierResolveComplaintView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request, complaint_id):
        complaint = get_object_or_404(
            Complaint, id=complaint_id, supplier=request.user
        )

        if complaint.status != "pending":
            return Response({"detail": "Already processed"}, status=400)

        complaint.status = "resolved"
        complaint.resolved_at = timezone.now()
        complaint.save()

        return Response({"detail": "Complaint resolved"}, status=200)

class SupplierRejectComplaintView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request, complaint_id):
        complaint = get_object_or_404(
            Complaint, id=complaint_id, supplier=request.user
        )

        if complaint.status != "pending":
            return Response({"detail": "Already processed"}, status=400)

        complaint.status = "rejected"
        complaint.resolved_at = timezone.now()
        complaint.save()

        return Response({"detail": "Complaint rejected"}, status=200)

class EscalateComplaintView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request, complaint_id):
        complaint = get_object_or_404(
            Complaint, id=complaint_id, supplier=request.user
        )

        if complaint.status != "pending":
            return Response({"detail": "Already processed"}, status=400)

        complaint.status = "escalated"
        complaint.resolved_at = timezone.now()
        complaint.save()

        return Response({"detail": "Complaint escalated"}, status=200)

class OrderDetailView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request, order_id):
        if request.user.role == "consumer":
            order = get_object_or_404(Order, id=order_id, consumer=request.user)

        # supplier can see only their own orders
        elif request.user.role == "supplier":
            order = get_object_or_404(Order, id=order_id, supplier=request.user)

        else:
            return Response({"detail": "Access denied"}, status=403)

        serializer = OrderSerializer(order)
        return Response(serializer.data, status=200)

class ConsumerOrderStatsView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        if request.user.role != "consumer":
            return Response({"detail": "Only consumers can view stats"}, status=403)

        orders = Order.objects.filter(consumer=request.user)

        completed = orders.filter(status="delivered").count()
        in_progress = orders.filter(status__in=["pending", "approved"]).count()
        cancelled = orders.filter(status="cancelled").count()
        total_spent = orders.filter(status="delivered").aggregate(
            total=Sum("total_price")
        )["total"] or 0

        return Response({
            "completed_orders": completed,
            "in_progress_orders": in_progress,
            "cancelled_orders": cancelled,
            "total_spent": total_spent
        })

class SupplierOrderStatsView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        if request.user.role != "supplier":
            return Response({"detail": "Only suppliers can view stats"}, status=403)

        orders = Order.objects.filter(supplier=request.user)
        active_orders = orders.filter(status__in=["pending", "approved"]).count()
        completed_orders = orders.filter(status="delivered").count()
        pending_deliveries = orders.filter(status="approved").count()

        total_revenue = orders.filter(status="delivered").aggregate(
            total=Sum("total_price")
        )["total"] or 0

        return Response({
            "active_orders": active_orders,
            "completed_orders": completed_orders,
            "pending_deliveries": pending_deliveries,
            "total_revenue": total_revenue,
        })

class SupplierDeliverOrderView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request, order_id):
        if request.user.role != "supplier":
            return Response({"detail": "Only suppliers can complete orders"}, status=403)

        order = get_object_or_404(Order, id=order_id, supplier=request.user)

        # Only approved orders can be delivered
        if order.status != "approved":
            return Response({"detail": "Order not ready for delivery"}, status=400)

        order.status = "delivered"
        order.save()

        return Response({"detail": "Order marked as delivered"}, status=200)

class ConsumerComplaintListView(generics.ListAPIView):
    permission_classes = [IsAuthenticated]
    serializer_class = ComplaintSerializer

    def get_queryset(self):
        if self.request.user.role != "consumer":
            return Complaint.objects.none()
        return Complaint.objects.filter(consumer=self.request.user).order_by("-created_at")
