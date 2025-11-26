from django.core.management.base import BaseCommand
from accounts.models import User, Product, LinkRequest, Order

class Command(BaseCommand):
    help = "Seed database with demo data"

    def handle(self, *args, **kwargs):
        owner = User.objects.create_user(email="owner@test.com", password="Pass123!", role="owner")
        manager = User.objects.create_user(email="manager@test.com", password="Pass123!", role="manager")
        sales = User.objects.create_user(email="sales@test.com", password="Pass123!", role="sales")
        consumer = User.objects.create_user(email="consumer@test.com", password="Pass123!", role="consumer")

        product = Product.objects.create(
            supplier=owner,
            name="Milk",
            price=100,
            stock=50
        )

        LinkRequest.objects.create(
            supplier=owner,
            consumer=consumer,
            status="linked"
        )

        Order.objects.create(
            consumer=consumer,
            supplier=owner,
            total_price=300
        )

        self.stdout.write(self.style.SUCCESS("Demo data created!"))
