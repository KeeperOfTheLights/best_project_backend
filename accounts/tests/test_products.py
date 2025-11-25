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

class ProductTests(APITestCase):

    def setUp(self):
        self.owner = create_user("owner@test.com", "owner")
        self.client.force_authenticate(self.owner)

    def test_owner_creates_product(self):
        url = reverse("product-list-create")
        data = {
            "name": "Apples",
            "price": "100",
            "stock": 10,
            "category": "Fruits",
            "minOrder": 1
        }
        response = self.client.post(url, data)
        self.assertEqual(response.status_code, 201)

    def test_sales_cannot_create_product(self):
        sales = create_user("sales@test.com", "sales")
        self.client.force_authenticate(sales)

        response = self.client.post(reverse("product-list-create"), {
            "name": "Milk",
            "price": "80"
        })
        self.assertEqual(response.status_code, 403)
