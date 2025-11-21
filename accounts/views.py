from django.db import models
from django.shortcuts import get_object_or_404
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status, generics, permissions
from rest_framework.permissions import IsAuthenticated
from django.db import transaction
from django.db.models import Q, Sum
from django.utils import timezone

from .models import (
    User,
    Product,
    LinkRequest,
    CartItem,
    Order,
    OrderItem,
    ChatRoom,
    Message,
    Complaint,
    CannedReply,
)
from .serializers import (
    RegisterSerializer,
    LoginSerializer,
    ProductSerializer,
    LinkRequestSerializer,
    SupplierSerializer,
    CartItemSerializer,
    OrderSerializer,
    MessageSerializer,
    ComplaintSerializer,
    UserSerializer,
    CannedReplySerializer,
)

SUPPLIER_ROLES = ["owner", "manager", "sales"]


def is_supplier_side(user: User) -> bool:
    return user.role in SUPPLIER_ROLES


def is_catalog_manager(user: User) -> bool:
    return user.role in ["owner", "manager"]


def get_company_owner(user: User) -> User:
    if user.role == "owner":
        return user
    elif user.company and user.company.owner:
        return user.company.owner
    return user


class RegisterView(APIView):
    def post(self, request):
        serializer = RegisterSerializer(data=request.data)
        if serializer.is_valid():
            user = serializer.save()
            from rest_framework_simplejwt.tokens import RefreshToken
            refresh = RefreshToken.for_user(user)
            return Response(
                {
                    "message": "User registered successfully",
                    "id": user.id,
                    "role": user.role,
                    "token": str(refresh.access_token),
                    "refresh": str(refresh),
                },
                status=status.HTTP_201_CREATED,
            )
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
        user = self.request.user
        if not is_catalog_manager(user):
            return Product.objects.none()
        company_owner = get_company_owner(user)
        return Product.objects.filter(supplier=company_owner)

    def perform_create(self, serializer):
        user = self.request.user
        if not is_catalog_manager(user):
            raise PermissionError("Only Owner and Manager can create products")
        serializer.save(supplier=user)


class SupplierProductDetailView(generics.RetrieveUpdateDestroyAPIView):
    serializer_class = ProductSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        if not is_catalog_manager(user):
            return Product.objects.none()
        company_owner = get_company_owner(user)
        return Product.objects.filter(supplier=company_owner)


class ProductStatusToggleView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def patch(self, request, pk):
        user = request.user
        if not is_catalog_manager(user):
            return Response(
                {"error": "Only Owner/Manager can change product status"},
                status=status.HTTP_403_FORBIDDEN,
            )
        company_owner = get_company_owner(user)
        try:
            product = Product.objects.get(id=pk, supplier=company_owner)
        except Product.DoesNotExist:
            return Response(
                {"error": "Not found or not your product"},
                status=status.HTTP_404_NOT_FOUND,
            )

        product.status = "inactive" if product.status == "active" else "active"
        product.save()

        return Response(
            {"message": f"Status changed to {product.status}"},
            status=status.HTTP_200_OK,
        )


class SendLinkRequestView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        if request.user.role != "consumer":
            return Response(
                {"detail": "Only consumers can send link requests"}, status=403
            )

        supplier_id = request.data.get("supplier_id")
        supplier = get_object_or_404(
            User, id=supplier_id, role="owner"
        )

        existing = LinkRequest.objects.filter(
            consumer=request.user, supplier=supplier
        ).first()
        if existing:
            return Response(
                {"detail": f"Link already exists (status={existing.status})"},
                status=400,
            )

        link = LinkRequest.objects.create(
            consumer=request.user, supplier=supplier, status="pending"
        )
        return Response(
            {"message": "Request sent", "link_id": link.id}, status=201
        )


class SupplierLinkListView(generics.ListAPIView):
    permission_classes = [IsAuthenticated]
    serializer_class = LinkRequestSerializer

    def get_queryset(self):
        user = self.request.user
        if not is_supplier_side(user):
            return LinkRequest.objects.none()
        company_owner = get_company_owner(user)
        queryset = LinkRequest.objects.filter(supplier=company_owner)
        if user.role == "sales":
            return queryset.filter(status="linked")
        return queryset


class UnlinkView(APIView):
    permission_classes = [IsAuthenticated]

    def delete(self, request, link_id):
        user = request.user
        if user.role == "consumer":
            link = LinkRequest.objects.filter(id=link_id, consumer=user).first()
        elif is_supplier_side(user):
            if user.role == "sales":
                return Response({"detail": "Sales representatives cannot manage links"}, status=403)
            company_owner = get_company_owner(user)
            link = LinkRequest.objects.filter(id=link_id, supplier=company_owner).first()
        else:
            return Response({"detail": "Not found or not allowed"}, status=404)

        if not link:
            return Response({"detail": "Not found or not allowed"}, status=404)

        link.delete()
        return Response({"detail": "Unlinked successfully"}, status=200)


class AcceptLinkView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request, link_id):
        if not is_supplier_side(request.user):
            return Response({"detail": "Only supplier staff can accept"}, status=403)
        if request.user.role == "sales":
            return Response({"detail": "Sales representatives cannot manage links"}, status=403)
        company_owner = get_company_owner(request.user)
        link = get_object_or_404(LinkRequest, id=link_id, supplier=company_owner)
        if link.status == "blocked":
            return Response(
                {"detail": "User is blocked, cannot accept"}, status=400
            )
        link.status = "linked"
        link.save()
        return Response({"detail": "Accepted"}, status=200)


class RejectLinkView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request, link_id):
        if not is_supplier_side(request.user):
            return Response({"detail": "Only supplier staff can reject"}, status=403)
        if request.user.role == "sales":
            return Response({"detail": "Sales representatives cannot manage links"}, status=403)
        company_owner = get_company_owner(request.user)
        link = get_object_or_404(LinkRequest, id=link_id, supplier=company_owner)
        link.status = "rejected"
        link.save()
        return Response({"detail": "Rejected"}, status=200)


class BlockLinkView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request, link_id):
        if not is_supplier_side(request.user):
            return Response({"detail": "Only supplier staff can block"}, status=403)
        if request.user.role == "sales":
            return Response({"detail": "Sales representatives cannot manage links"}, status=403)
        company_owner = get_company_owner(request.user)
        link = get_object_or_404(LinkRequest, id=link_id, supplier=company_owner)
        link.status = "blocked"
        link.save()
        return Response({"detail": "Blocked"}, status=200)


class UnblockLinkView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request, link_id):
        if not is_supplier_side(request.user):
            return Response({"detail": "Only supplier staff can unblock"}, status=403)
        if request.user.role == "sales":
            return Response({"detail": "Sales representatives cannot manage links"}, status=403)
        company_owner = get_company_owner(request.user)
        link = get_object_or_404(LinkRequest, id=link_id, supplier=company_owner)
        link.status = "pending"
        link.save()
        return Response({"detail": "Unblocked"}, status=200)


class AllSuppliersView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        if request.user.role != "consumer":
            return Response(
                {"detail": "Only consumers can view suppliers"}, status=403
            )

        suppliers = User.objects.filter(role="owner")
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
        supplier = get_object_or_404(User, id=supplier_id)

        if supplier.role != "owner":
            return Response(
                {"detail": "Only owners can have catalogs"}, status=403
            )

        link = LinkRequest.objects.filter(
            supplier_id=supplier_id,
            consumer=request.user,
            status="linked",
        ).first()

        if not link:
            return Response(
                {"detail": "You are not linked with this supplier"}, status=403
            )

        products = (
            Product.objects.filter(supplier_id=supplier_id, status="active")
            .order_by("name")
        )
        serializer = ProductSerializer(products, many=True)
        return Response(serializer.data, status=200)


class CartAddView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        if request.user.role != "consumer":
            return Response(
                {"detail": "Only consumers can use cart"}, status=403
            )

        product_id = request.data.get("product_id")
        try:
            quantity = int(request.data.get("quantity", 1))
        except (TypeError, ValueError):
            return Response(
                {"detail": "Quantity must be a valid number"}, status=400
            )

        if quantity <= 0:
            return Response({"detail": "Quantity must be > 0"}, status=400)

        product = get_object_or_404(Product, id=product_id, status="active")

        linked = LinkRequest.objects.filter(
            consumer=request.user,
            supplier=product.supplier,
            status="linked",
        ).exists()
        if not linked:
            return Response(
                {"detail": "You must be linked with this supplier"}, status=403
            )

        if quantity < product.minOrder:
            return Response(
                {
                    "detail": f"Minimum order is {product.minOrder} {product.unit}"
                },
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
            CartItem.objects.filter(consumer=self.request.user)
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
            return Response(
                {"detail": "Quantity must be a valid number"}, status=400
            )

        if quantity <= 0:
            item.delete()
            return Response({"detail": "Item removed (quantity <= 0)"}, status=200)

        product = item.product
        if quantity < product.minOrder:
            return Response(
                {
                    "detail": f"Minimum order is {product.minOrder} {product.unit}"
                },
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
            return Response(
                {"detail": "Only consumers can checkout"}, status=403
            )

        cart_items = (
            CartItem.objects.filter(consumer=request.user)
            .select_related("product", "product__supplier")
        )

        if not cart_items.exists():
            return Response({"detail": "Cart is empty"}, status=400)

        supplier_ids = cart_items.values_list(
            "product__supplier_id", flat=True
        ).distinct()
        if supplier_ids.count() > 1:
            return Response(
                {
                    "detail": "Cart must contain items from one supplier only"
                },
                status=400,
            )

        supplier_id = supplier_ids.first()

        total_price = 0
        for item in cart_items:
            product = item.product
            item_price = product.discounted_price if hasattr(product, 'discounted_price') else product.price
            total_price += item_price * item.quantity

        for item in cart_items:
            if item.product.stock < item.quantity:
                return Response(
                    {
                        "detail": f"Insufficient stock for {item.product.name}. Only {item.product.stock} {item.product.unit} available."
                    },
                    status=400,
                )

        order = Order.objects.create(
            consumer=request.user,
            supplier_id=supplier_id,
            total_price=total_price,
            status="pending",
        )

        order_items = [
            OrderItem(
                order=order,
                product=item.product,
                quantity=item.quantity,
                price=item.product.discounted_price if hasattr(item.product, 'discounted_price') else item.product.price,
            )
            for item in cart_items
        ]
        OrderItem.objects.bulk_create(order_items)

        for item in cart_items:
            product = item.product
            product.stock -= item.quantity
            product.save()

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
            Order.objects.filter(consumer=self.request.user)
            .prefetch_related("items__product")
            .order_by("-created_at")
        )


class SupplierOrdersView(generics.ListAPIView):
    permission_classes = [IsAuthenticated]
    serializer_class = OrderSerializer

    def get_queryset(self):
        user = self.request.user
        if not is_supplier_side(user):
            return Order.objects.none()
        company_owner = get_company_owner(user)
        return (
            Order.objects.filter(supplier=company_owner)
            .prefetch_related("items__product")
            .order_by("-created_at")
        )


def get_or_create_room(consumer, supplier):
    room, _ = ChatRoom.objects.get_or_create(
        consumer=consumer, supplier=supplier
    )
    return room


class ChatHistoryView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request, partner_id):
        user = request.user

        if user.role == "consumer":
            supplier_user = get_object_or_404(
                User, id=partner_id, role__in=SUPPLIER_ROLES
            )
            supplier = get_company_owner(supplier_user)
            consumer = user
        elif is_supplier_side(user):
            consumer = get_object_or_404(
                User, id=partner_id, role="consumer"
            )
            supplier = get_company_owner(user)
        else:
            return Response({"detail": "Access denied"}, status=403)

        linked = LinkRequest.objects.filter(
            consumer=consumer, supplier=supplier, status="linked"
        ).exists()

        if not linked:
            return Response({"detail": "Not linked"}, status=403)

        room = get_or_create_room(consumer, supplier)
        messages = room.messages.select_related("sender", "order", "product").order_by("timestamp")

        serializer = MessageSerializer(messages, many=True, context={"request": request})
        return Response(serializer.data, status=200)


class SendMessageView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request, supplier_id):
        user = request.user

        text = request.data.get("text", "").strip()
        message_type = request.data.get("message_type", "text")
        order_id = request.data.get("order_id")
        product_id = request.data.get("product_id")
        attachment = request.FILES.get("attachment")

        if not text and not attachment and not order_id and not product_id:
            return Response({"detail": "Text, attachment, order, or product is required"}, status=400)

        supplier_user = get_object_or_404(
            User, id=supplier_id, role__in=SUPPLIER_ROLES
        )
        supplier = get_company_owner(supplier_user)

        if user.role == "consumer":
            consumer = user
        elif is_supplier_side(user):
            consumer_id = request.data.get("consumer_id")
            if not consumer_id:
                return Response(
                    {"detail": "consumer_id is required"}, status=400
                )
            consumer = get_object_or_404(
                User, id=consumer_id, role="consumer"
            )
            supplier = get_company_owner(user)
        else:
            return Response(
                {"detail": "Only consumers or supplier staff can chat"},
                status=403,
            )

        linked = LinkRequest.objects.filter(
            consumer=consumer, supplier=supplier, status="linked"
        ).exists()
        if not linked:
            return Response(
                {"detail": "No active link between users"}, status=403
            )

        room = get_or_create_room(consumer, supplier)

        order = None
        if order_id:
            order = get_object_or_404(Order, id=order_id, consumer=consumer, supplier=supplier)

        product = None
        if product_id:
            product = get_object_or_404(Product, id=product_id, supplier=supplier)

        msg_data = {
            "room": room,
            "sender": user,
            "text": text,
            "message_type": message_type,
        }

        if attachment:
            msg_data["attachment"] = attachment
            msg_data["attachment_name"] = attachment.name
            if not message_type or message_type == "text":
                msg_data["message_type"] = "attachment"

        if order:
            msg_data["order"] = order
            if not message_type or message_type == "text":
                msg_data["message_type"] = "receipt"

        if product:
            msg_data["product"] = product
            if not message_type or message_type == "text":
                msg_data["message_type"] = "product_link"

        msg = Message.objects.create(**msg_data)

        serializer = MessageSerializer(msg, context={"request": request})
        return Response(serializer.data, status=201)


class SupplierAcceptOrderView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request, order_id):
        if not is_catalog_manager(request.user):
            return Response(
                {"detail": "Only Owner/Manager can accept orders"}, status=403
            )
        company_owner = get_company_owner(request.user)
        order = get_object_or_404(Order, id=order_id, supplier=company_owner)

        if order.status != "pending":
            return Response({"detail": "Order already processed"}, status=400)

        order.status = "approved"
        order.save()
        return Response({"detail": "Order approved"}, status=200)


class SupplierRejectOrderView(APIView):
    permission_classes = [IsAuthenticated]

    @transaction.atomic
    def post(self, request, order_id):
        if not is_catalog_manager(request.user):
            return Response(
                {"detail": "Only Owner/Manager can reject orders"}, status=403
            )
        company_owner = get_company_owner(request.user)
        order = get_object_or_404(Order, id=order_id, supplier=company_owner)

        if order.status != "pending":
            return Response({"detail": "Order already processed"}, status=400)

        for order_item in order.items.all():
            product = order_item.product
            product.stock += order_item.quantity
            product.save()

        order.status = "cancelled"
        order.save()

        return Response({"detail": "Order rejected"}, status=200)


class SupplierDeliverOrderView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request, order_id):
        if not is_catalog_manager(request.user):
            return Response(
                {"detail": "Only Owner/Manager can complete orders"},
                status=403,
            )
        company_owner = get_company_owner(request.user)
        order = get_object_or_404(Order, id=order_id, supplier=company_owner)

        if order.status != "approved":
            return Response(
                {"detail": "Order not ready for delivery"}, status=400
            )

        order.status = "delivered"
        order.save()

        return Response({"detail": "Order marked as delivered"}, status=200)


class CreateComplaintView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request, order_id):
        if request.user.role != "consumer":
            return Response(
                {"detail": "Only consumers can file complaints"}, status=403
            )

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
        user = self.request.user
        if not is_supplier_side(user):
            return Complaint.objects.none()
        company_owner = get_company_owner(user)
        complaints = Complaint.objects.filter(supplier=company_owner)

        if user.role == "sales":
            return complaints.filter(status__in=["pending", "resolved", "rejected"]).order_by("-created_at")
        elif is_catalog_manager(user):
            return complaints.filter(status="escalated").order_by("-created_at")

        return complaints.order_by("-created_at")


class SupplierResolveComplaintView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request, complaint_id):
        if not is_catalog_manager(request.user) and not request.user.role == "sales":
            return Response({"detail": "Access denied"}, status=403)
        company_owner = get_company_owner(request.user)
        complaint = get_object_or_404(
            Complaint, id=complaint_id, supplier=company_owner
        )

        if request.user.role == "sales":
            if complaint.status != "pending":
                return Response({"detail": "Already processed"}, status=400)
        elif is_catalog_manager(request.user):
            if complaint.status != "escalated":
                return Response({"detail": "Only escalated complaints can be resolved by managers/owners"}, status=400)
        else:
            return Response({"detail": "Access denied"}, status=403)

        complaint.status = "resolved"
        complaint.resolved_at = timezone.now()
        complaint.save()

        return Response({"detail": "Complaint resolved"}, status=200)


class SupplierRejectComplaintView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request, complaint_id):
        if not is_catalog_manager(request.user) and not request.user.role == "sales":
            return Response({"detail": "Access denied"}, status=403)
        company_owner = get_company_owner(request.user)
        complaint = get_object_or_404(
            Complaint, id=complaint_id, supplier=company_owner
        )

        if request.user.role == "sales":
            if complaint.status != "pending":
                return Response({"detail": "Already processed"}, status=400)
        elif is_catalog_manager(request.user):
            if complaint.status != "escalated":
                return Response({"detail": "Only escalated complaints can be rejected by managers/owners"}, status=400)
        else:
            return Response({"detail": "Access denied"}, status=403)

        complaint.status = "rejected"
        complaint.resolved_at = timezone.now()
        complaint.save()

        return Response({"detail": "Complaint rejected"}, status=200)


class EscalateComplaintView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request, complaint_id):
        if not is_supplier_side(request.user):
            return Response({"detail": "Access denied"}, status=403)
        company_owner = get_company_owner(request.user)
        complaint = get_object_or_404(
            Complaint, id=complaint_id, supplier=company_owner
        )

        if complaint.status != "pending":
            return Response({"detail": "Already processed"}, status=400)

        complaint.status = "escalated"
        complaint.resolved_at = timezone.now()
        complaint.save()

        return Response({"detail": "Complaint escalated"}, status=200)


class ConsumerComplaintListView(generics.ListAPIView):
    permission_classes = [IsAuthenticated]
    serializer_class = ComplaintSerializer

    def get_queryset(self):
        if self.request.user.role != "consumer":
            return Complaint.objects.none()
        return Complaint.objects.filter(consumer=self.request.user).order_by(
            "-created_at"
        )


class OrderDetailView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request, order_id):
        if request.user.role == "consumer":
            order = get_object_or_404(
                Order, id=order_id, consumer=request.user
            )
        elif is_supplier_side(request.user):
            order = get_object_or_404(
                Order, id=order_id, supplier=request.user
            )
        else:
            return Response({"detail": "Access denied"}, status=403)

        serializer = OrderSerializer(order)
        return Response(serializer.data, status=200)


class ConsumerOrderStatsView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        if request.user.role != "consumer":
            return Response(
                {"detail": "Only consumers can view stats"}, status=403
            )

        orders = Order.objects.filter(consumer=request.user)

        completed = orders.filter(status="delivered").count()
        in_progress = orders.filter(status__in=["pending", "approved"]).count()
        cancelled = orders.filter(status="cancelled").count()
        total_spent = (
                orders.filter(status="delivered").aggregate(total=Sum("total_price"))[
                    "total"
                ]
                or 0
        )

        return Response(
            {
                "completed_orders": completed,
                "in_progress_orders": in_progress,
                "cancelled_orders": cancelled,
                "total_spent": total_spent,
            }
        )


class SupplierOrderStatsView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        if not is_supplier_side(request.user):
            return Response(
                {"detail": "Only supplier staff can view stats"}, status=403
            )

        orders = Order.objects.filter(supplier=request.user)
        active_orders = orders.filter(
            status__in=["pending", "approved"]
        ).count()
        completed_orders = orders.filter(status="delivered").count()
        pending_deliveries = orders.filter(status="approved").count()

        total_revenue = (
                orders.filter(status="delivered").aggregate(total=Sum("total_price"))[
                    "total"
                ]
                or 0
        )

        return Response(
            {
                "active_orders": active_orders,
                "completed_orders": completed_orders,
                "pending_deliveries": pending_deliveries,
                "total_revenue": total_revenue,
            }
        )


class GlobalSearchView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        query = request.GET.get("q", "").strip()

        if not query:
            return Response(
                {"suppliers": [], "categories": [], "products": []}
            )

        # search only among suppliers that current consumer is linked with
        linked_suppliers = LinkRequest.objects.filter(
            consumer=request.user, status="linked"
        ).values_list("supplier_id", flat=True)

        suppliers = User.objects.filter(
            id__in=linked_suppliers, full_name__icontains=query
        )
        suppliers_data = SupplierSerializer(suppliers, many=True).data

        categories = (
            Product.objects.filter(
                supplier_id__in=linked_suppliers, category__icontains=query
            )
            .values_list("category", flat=True)
            .distinct()
        )

        products = Product.objects.filter(
            supplier_id__in=linked_suppliers
        ).filter(
            Q(name__icontains=query) | Q(description__icontains=query)
        )
        products_data = ProductSerializer(products, many=True).data

        return Response(
            {
                "suppliers": suppliers_data,
                "categories": list(categories),
                "products": products_data,
            }
        )


class UnassignedUsersView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        if request.user.role != "owner":
            return Response({"detail": "Only owners can view this list"}, status=403)

        users = User.objects.filter(
            role__in=["manager", "sales"],
            company__isnull=True
        )

        serializer = UserSerializer(users, many=True)
        return Response(serializer.data)


class CompanyEmployeesView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        if request.user.role != "owner":
            return Response({"detail": "Only owners can view employees"}, status=403)

        company = request.user.company
        if not company:
            return Response({"detail": "Owner has no company"}, status=400)

        employees = User.objects.filter(company=company)
        serializer = UserSerializer(employees, many=True)
        return Response(serializer.data)


class AssignEmployeeView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        if request.user.role != "owner":
            return Response({"detail": "Only owners can assign employees"}, status=403)

        user_id = request.data.get("user_id")
        employee = get_object_or_404(User, id=user_id)

        if employee.role not in ["manager", "sales"]:
            return Response({"detail": "Only manager or sales can be assigned"}, status=400)

        if employee.company is not None:
            return Response({"detail": "User is already assigned to a company"}, status=400)

        employee.company = request.user.company
        employee.save()

        return Response({"detail": "Employee assigned successfully"})


class RemoveEmployeeView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        if request.user.role != "owner":
            return Response({"detail": "Only owners can remove employees"}, status=403)

        user_id = request.data.get("user_id")
        employee = get_object_or_404(User, id=user_id, company=request.user.company)

        employee.company = None
        employee.save()

        return Response({"detail": "Employee removed from company"})


class DeleteOwnerAccountView(APIView):
    permission_classes = [IsAuthenticated]

    def delete(self, request):
        user = request.user

        if user.role != "owner":
            return Response({"detail": "Only owners can delete their account"}, status=403)

        company = user.company

        if company:
            User.objects.filter(company=company).update(company=None)

            Product.objects.filter(supplier=user).delete()

            LinkRequest.objects.filter(supplier=user).delete()

            company.delete()

        user.delete()

        return Response(
            {"detail": "Owner account and business deleted successfully"},
            status=200
        )


class CannedReplyListView(generics.ListCreateAPIView):
    permission_classes = [IsAuthenticated]
    serializer_class = CannedReplySerializer

    def get_queryset(self):
        if not is_supplier_side(self.request.user):
            return CannedReply.objects.none()
        company_owner = get_company_owner(self.request.user)
        return CannedReply.objects.filter(supplier=company_owner)

    def perform_create(self, serializer):
        company_owner = get_company_owner(self.request.user)
        serializer.save(supplier=company_owner)


class CannedReplyDetailView(generics.RetrieveUpdateDestroyAPIView):
    permission_classes = [IsAuthenticated]
    serializer_class = CannedReplySerializer

    def get_queryset(self):
        if not is_supplier_side(self.request.user):
            return CannedReply.objects.none()
        company_owner = get_company_owner(self.request.user)
        return CannedReply.objects.filter(supplier=company_owner)

