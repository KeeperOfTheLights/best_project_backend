from django.db import models
from django.shortcuts import get_object_or_404
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status, generics, permissions
from rest_framework.permissions import IsAuthenticated
from .serializers import *
from .models import Product, LinkRequest, User
from .serializers import ProductSerializer
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
