from django.urls import reverse
from rest_framework.test import APITestCase
from accounts.models import User, Product, LinkRequest, CartItem, Order
from rest_framework import status

def create_user(email, role, password="Pass123!"):
    return User.objects.create_user(
        email=email,
        password=password,
        full_name=email.split("@")[0],
        role=role
    )

class ComplaintTests(APITestCase):

    def test_consumer_creates_complaint(self):
        consumer = create_user("c@test.com", "consumer")
        supplier = create_user("o@test.com", "owner")
        order = Order.objects.create(
            consumer=consumer,
            supplier=supplier,
            total_price=100
        )

        self.client.force_authenticate(consumer)
        response = self.client.post(
            reverse("complaint-create", args=[order.id]),
            {"title": "Bad order", "description": "Item damaged"}
        )
        self.assertEqual(response.status_code, 201)
