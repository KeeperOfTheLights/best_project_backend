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

class CartTests(APITestCase):

    def setUp(self):
        self.consumer = create_user("c@test.com", "consumer")
        self.owner = create_user("o@test.com", "owner")
        LinkRequest.objects.create(
            supplier=self.owner, consumer=self.consumer, status="linked"
        )
        self.product = Product.objects.create(
            supplier=self.owner,
            name="Bread",
            price=100,
            stock=5,
            minOrder=1
        )

    def test_add_to_cart(self):
        self.client.force_authenticate(self.consumer)

        response = self.client.post(reverse("cart-add"), {
            "product_id": self.product.id,
            "quantity": 2
        })

        self.assertEqual(response.status_code, 201)
        self.assertEqual(CartItem.objects.count(), 1)
