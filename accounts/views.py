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

        products = Product.objects.filter(supplier_id=supplier_id)
        serializer = ProductSerializer(products, many=True)
        return Response(serializer.data, status=200)

#view check postman
class CartAddView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        if request.user.role != "consumer":
            return Response({"detail": "Only consumers can use cart"}, status=403)

        product_id = request.data.get("product_id")
        quantity = int(request.data.get("quantity", 1))

        if quantity <= 0:
            return Response({"detail": "Quantity must be > 0"}, status=400)

        product = get_object_or_404(Product, id=product_id, status="active")

        item, created = CartItem.objects.get_or_create(
            consumer=request.user,
            product=product,
            defaults={"quantity": quantity},
        )
        if not created:
            item.quantity += quantity
            item.save()

        serializer = CartItemSerializer(item)
        return Response(serializer.data, status=201)


class CartListView(generics.ListAPIView):
    permission_classes = [IsAuthenticated]
    serializer_class = CartItemSerializer

    def get_queryset(self):
        if self.request.user.role != "consumer":
            return CartItem.objects.none()
        return CartItem.objects.filter(consumer=self.request.user).select_related("product")


class CartItemUpdateDeleteView(APIView):
    permission_classes = [IsAuthenticated]

    def patch(self, request, item_id):
        item = get_object_or_404(CartItem, id=item_id, consumer=request.user)

        quantity = int(request.data.get("quantity", 1))
        if quantity <= 0:
            item.delete()
            return Response({"detail": "Item removed (quantity <= 0)"}, status=200)

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

    def get(self, request, supplier_id):
        user = request.user

        if user.role != "consumer":
            return Response({"detail": "Only consumers start this chat view"}, status=403)

        supplier = get_object_or_404(User, id=supplier_id, role="supplier")

        # ensure they are linked
        linked = LinkRequest.objects.filter(
            consumer=user,
            supplier=supplier,
            status="linked"
        ).exists()
        if not linked:
            return Response({"detail": "You are not linked to this supplier"}, status=403)

        room = get_or_create_room(user, supplier)
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
