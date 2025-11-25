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

class LinkTests(APITestCase):

    def setUp(self):
        self.consumer = create_user("c@test.com", "consumer")
        self.owner = create_user("o@test.com", "owner")

    def test_consumer_sends_link(self):
        self.client.force_authenticate(self.consumer)

        response = self.client.post(
            reverse("send-link"),
            {"supplier_id": self.owner.id}
        )

        self.assertEqual(response.status_code, 201)
        self.assertEqual(LinkRequest.objects.count(), 1)

    def test_owner_accepts_link(self):
        link = LinkRequest.objects.create(
            supplier=self.owner,
            consumer=self.consumer
        )
        self.client.force_authenticate(self.owner)

        response = self.client.post(
            reverse("accept-link", args=[link.id])
        )
        link.refresh_from_db()

        self.assertEqual(response.status_code, 200)
        self.assertEqual(link.status, "linked")
