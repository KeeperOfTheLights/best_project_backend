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

    class Meta:
        verbose_name = "User"
        verbose_name_plural = "Users"

    def __str__(self):
        return f"{self.username} ({self.role})"


class Supplier(User):
    company_name = models.CharField(max_length=120)
    address = models.CharField(max_length=120, blank=True)
    phone_number = models.CharField(max_length=20, blank=True)

    class Meta:
        verbose_name = "Supplier"
        verbose_name_plural = "Suppliers"

    def save(self, *args, **kwargs):
        self.role = 'supplier'     # auto-assign
        super().save(*args, **kwargs)

class Consumer(User):
    organization_name = models.CharField(max_length=120)
    address = models.CharField(max_length=120, blank=True)
    phone_number = models.CharField(max_length=20, blank=True)

    class Meta:
        verbose_name = "Consumer"
        verbose_name_plural = "Consumers"

    def save(self, *args, **kwargs):
        self.role = 'consumer'     # auto-assign
        super().save(*args, **kwargs)
