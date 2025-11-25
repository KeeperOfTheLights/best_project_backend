from django.urls import reverse
from rest_framework.test import APITestCase
from accounts.models import User, Product, Order, LinkRequest


def create_user(email, role, password="Pass123!"):
    return User.objects.create_user(
        email=email,
        password=password,
        full_name=email.split("@")[0],
        role=role
    )

class RBACTests(APITestCase):

    def test_sales_cannot_create_product(self):
        sales = create_user("sales@test.com", "sales")
        self.client.force_authenticate(sales)

        response = self.client.post(reverse("product-list-create"), {
            "name": "Milk",
            "price": "100",
            "stock": 5
        })

        self.assertEqual(response.status_code, 403)

    def test_sales_cannot_approve_order(self):
        sales = create_user("sales@test.com", "sales")
        consumer = create_user("c2@test.com", "consumer")
        owner = create_user("o2@test.com", "owner")

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

    def test_sales_cannot_assign_employee(self):
        sales = create_user("sales@test.com", "sales")
        manager = create_user("manager@test.com", "manager")

        self.client.force_authenticate(sales)

        response = self.client.post(reverse("company-assign"), {
            "user_id": manager.id
        })

        self.assertEqual(response.status_code, 403)

    def test_consumer_cannot_view_supplier_orders(self):
        consumer = create_user("c@test.com", "consumer")
        self.client.force_authenticate(consumer)

        response = self.client.get(reverse("supplier-orders"))

        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.json(), [])

    def test_supplier_cannot_access_cart(self):
        owner = create_user("owner@test.com", "owner")
        self.client.force_authenticate(owner)

        response = self.client.get(reverse("cart-list"))

        # DRF returns 200 + empty list (not 403)
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.json(), [])
