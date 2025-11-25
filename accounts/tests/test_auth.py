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

class RegistrationTests(APITestCase):

    def test_register_consumer(self):
        url = reverse("register")
        data = {
            "full_name": "Islam Consumer",
            "email": "cons@test.com",
            "password": "Pass123!",
            "password2": "Pass123!",
            "role": "consumer"
        }
        response = self.client.post(url, data)
        self.assertEqual(response.status_code, 201)
        self.assertEqual(response.data["role"], "consumer")

class LoginTests(APITestCase):

    def test_login_user(self):
        user = create_user("owner@test.com", "owner")
        url = reverse("login")

        response = self.client.post(url, {
            "email": "owner@test.com",
            "password": "Pass123!"
        })

        self.assertEqual(response.status_code, 200)
        self.assertIn("access", response.data)
