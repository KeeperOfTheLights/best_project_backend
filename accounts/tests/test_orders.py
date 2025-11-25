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

class OrderTests(APITestCase):

    def setUp(self):
        self.consumer = create_user("c@test.com", "consumer")
        self.owner = create_user("o@test.com", "owner")
        LinkRequest.objects.create(
            supplier=self.owner, consumer=self.consumer, status="linked"
        )
        self.product = Product.objects.create(
            supplier=self.owner,
            name="Sugar",
            price=200,
            stock=10,
            minOrder=1
        )
        self.client.force_authenticate(self.consumer)

    def test_checkout_creates_order(self):
        self.client.post(reverse("cart-add"), {
            "product_id": self.product.id,
            "quantity": 3
        })

        response = self.client.post(reverse("checkout"))
        self.assertEqual(response.status_code, 201)
        self.assertEqual(Order.objects.count(), 1)

    class RBACTests(APITestCase):

        def test_sales_cannot_approve_order(self):
            sales = create_user("sales@test.com", "sales")
            consumer = create_user("c@test.com", "consumer")
            owner = create_user("o@test.com", "owner")

            order = Order.objects.create(
                consumer=consumer,
                supplier=owner,
                total_price=100
            )

            self.client.force_authenticate(sales)
            response = self.client.post(
                reverse("order-accept", args=[order.id])
            )

            self.assertEqual(response.status_code, 403)

class RBACTests(APITestCase):

    def test_sales_cannot_approve_order(self):
        sales = create_user("sales@test.com", "sales")
        consumer = create_user("c@test.com", "consumer")
        owner = create_user("o@test.com", "owner")

        order = Order.objects.create(
            consumer=consumer,
            supplier=owner,
            total_price=100
        )

        self.client.force_authenticate(sales)
        response = self.client.post(
            reverse("order-accept", args=[order.id])
        )

        self.assertEqual(response.status_code, 403)