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

class ChatTests(APITestCase):

    def test_send_message(self):
        c = create_user("c@test.com", "consumer")
        o = create_user("o@test.com", "owner")

        LinkRequest.objects.create(
            supplier=o, consumer=c, status="linked"
        )

        self.client.force_authenticate(c)
        response = self.client.post(
            reverse("chat-send", args=[o.id]),
            {"text": "Hello!"}
        )

        self.assertEqual(response.status_code, 201)
