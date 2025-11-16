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
