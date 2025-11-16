from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status, generics, permissions
from .serializers import RegisterSerializer, LoginSerializer
from .models import Product
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