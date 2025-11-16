from django.conf import settings
from django.db import models
from django.contrib.auth.models import AbstractUser


class User(AbstractUser):
    ROLE_CHOICES = [
        ('supplier', 'Supplier'),
        ('consumer', 'Consumer'),
    ]

    role = models.CharField(max_length=10, choices=ROLE_CHOICES)
    full_name = models.CharField(max_length=120)
    email = models.EmailField(max_length=120, unique=True)

    def __str__(self):
        return f"{self.username} - {self.role}"


class SupplierProfile(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name="supplier_profile")
    company_name = models.CharField(max_length=120)
    address = models.CharField(max_length=120, blank=True)
    phone_number = models.CharField(max_length=20, blank=True)

    def __str__(self):
        return f"Supplier Profile: {self.user.username}"


class ConsumerProfile(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name="consumer_profile")
    organization_name = models.CharField(max_length=120)
    address = models.CharField(max_length=120, blank=True)
    phone_number = models.CharField(max_length=20, blank=True)

    def __str__(self):
        return f"Consumer Profile: {self.user.username}"


class Product(models.Model):
    UNIT_CHOICES = [
        ('kg', 'Kilogram'),
        ('pcs', 'Pieces'),
        ('litre', 'Litre'),
        ('pack', 'Pack'),
    ]

    STATUS_CHOICES = [
        ('active', 'Active'),
        ('inactive', 'Inactive'),
    ]

    supplier = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='products')
    name = models.CharField(max_length=120)
    category = models.CharField(max_length=100, default='Uncategorized')
    price = models.DecimalField(max_digits=10, decimal_places=2)
    unit = models.CharField(max_length=10, choices=UNIT_CHOICES, default='kg')
    stock = models.PositiveIntegerField(default=0)
    minOrder = models.PositiveIntegerField(default=1)
    image = models.URLField(blank=True, null=True)
    description = models.TextField(blank=True)
    status = models.CharField(max_length=10, choices=STATUS_CHOICES, default='active')

    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.name} - {self.supplier.username}"

class LinkRequest(models.Model):
    STATUS_CHOICES = [
        ('pending', 'Pending'),
        ('linked', 'Linked'),
        ('rejected', 'Rejected'),
        ('blocked', 'Blocked'),
    ]

    supplier = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="supplier_links")
    consumer = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="consumer_links")
    status = models.CharField(max_length=10, choices=STATUS_CHOICES, default='pending')
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.consumer.username} → {self.supplier.username} [{self.status}]"