from rest_framework import serializers
from django.contrib.auth import get_user_model
from django.contrib.auth.password_validation import validate_password
from django.contrib.auth import authenticate
from rest_framework_simplejwt.tokens import RefreshToken
from accounts.models import *

User = get_user_model()

class RegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, validators=[validate_password])
    password2 = serializers.CharField(write_only=True)

    class Meta:
        model = User
        fields = ('full_name', 'username', 'email', 'role', 'password', 'password2')

    def validate(self, attrs):
        if attrs['password'] != attrs['password2']:
            raise serializers.ValidationError({"password": "Passwords do not match"})
        return attrs

    def create(self, validated_data):
        validated_data.pop('password2')
        user = User.objects.create_user(**validated_data)
        return user


class LoginSerializer(serializers.Serializer):
    email = serializers.EmailField()
    password = serializers.CharField(write_only=True)

    def validate(self, data):
        email = data.get('email')
        password = data.get('password')

        try:
            user = User.objects.get(email=email)
        except User.DoesNotExist:
            raise serializers.ValidationError("Invalid email or password")

        user = authenticate(username=user.username, password=password)
        if not user:
            raise serializers.ValidationError("Invalid email or password")

        refresh = RefreshToken.for_user(user)

        return {
            'refresh': str(refresh),
            'access': str(refresh.access_token),
            'username': user.username,
            'full_name': user.full_name,
            'role': user.role,
            'email': user.email,
        }


class ProductSerializer(serializers.ModelSerializer):
    supplier_name = serializers.CharField(source='supplier.full_name', read_only=True)

    class Meta:
        model = Product
        fields = [
            'id', 'name', 'category', 'price', 'unit', 'stock', 'minOrder',
            'image', 'description', 'status', 'created_at', 'supplier_name'
        ]
        # УБРАЛИ 'status' из read_only_fields!
        read_only_fields = ['supplier', 'created_at', 'supplier_name']

    def create(self, validated_data):
        user = self.context['request'].user

        if user.role != "supplier":
            raise serializers.ValidationError("Only suppliers can create products")

        validated_data['supplier'] = user
        return super().create(validated_data)

    def update(self, instance, validated_data):
        validated_data.pop('supplier', None)
        return super().update(instance, validated_data)

class LinkRequestSerializer(serializers.ModelSerializer):
    consumer_name = serializers.CharField(source='consumer.full_name', read_only=True)
    supplier_name = serializers.CharField(source='supplier.full_name', read_only=True)
    supplier_company = serializers.CharField(source='supplier.supplier_profile.company_name', read_only=True, default=None)

    class Meta:
        model = LinkRequest
        fields = [
            'id', 'supplier', 'consumer', 'status', 'created_at',
            'consumer_name', 'supplier_name', 'supplier_company'
        ]
        read_only_fields = ['status', 'created_at', 'consumer', 'supplier']

class SupplierSerializer(serializers.ModelSerializer):
    supplier_company = serializers.CharField(source="supplier_profile.company_name", read_only=True)

    class Meta:
        model = User
        fields = ["id", "full_name", "email", "role", "supplier_company"]

#check postman
class CartItemSerializer(serializers.ModelSerializer):
    product_name = serializers.CharField(source="product.name", read_only=True)
    product_price = serializers.DecimalField(
        source="product.price",
        read_only=True,
        max_digits=10,
        decimal_places=2,
    )
    product_image = serializers.URLField(
        source="product.image",
        read_only=True,
        allow_null=True,
        default=None,
    )
    product_unit = serializers.CharField(source="product.unit", read_only=True)
    product_min_order = serializers.IntegerField(
        source="product.minOrder",
        read_only=True,
    )
    product_stock = serializers.IntegerField(
        source="product.stock",
        read_only=True,
    )
    product_supplier_id = serializers.IntegerField(
        source="product.supplier_id",
        read_only=True,
    )
    line_total = serializers.SerializerMethodField()

    class Meta:
        model = CartItem
        fields = [
            "id",
            "product",
            "product_name",
            "product_price",
            "product_image",
            "product_unit",
            "product_min_order",
            "product_supplier_id",
            "product_stock",
            "quantity",
            "added_at",
            "line_total",
        ]

    def get_line_total(self, obj):
        return obj.product.price * obj.quantity


class OrderItemSerializer(serializers.ModelSerializer):
    product_name = serializers.CharField(source="product.name", read_only=True)

    class Meta:
        model = OrderItem
        fields = ["id", "product", "product_name", "quantity", "price"]


class OrderSerializer(serializers.ModelSerializer):
    items = OrderItemSerializer(many=True, read_only=True)
    consumer_name = serializers.CharField(source="consumer.full_name", read_only=True)
    supplier_name = serializers.CharField(source="supplier.full_name", read_only=True)

    class Meta:
        model = Order
        fields = [
            "id",
            "consumer",
            "consumer_name",
            "supplier",
            "supplier_name",
            "created_at",
            "total_price",
            "status",
            "items",
        ]
        read_only_fields = ["consumer", "total_price", "created_at"]


class MessageSerializer(serializers.ModelSerializer):
    sender_name = serializers.CharField(source="sender.full_name", read_only=True)

    class Meta:
        model = Message
        fields = ["id", "room", "sender", "sender_name", "text", "timestamp"]
        read_only_fields = ["room", "sender", "timestamp"]
