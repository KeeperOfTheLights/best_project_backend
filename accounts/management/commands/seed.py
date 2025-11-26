from django.core.management.base import BaseCommand
from accounts.models import User, Product, LinkRequest, Order

class Command(BaseCommand):
    help = "Seed database with demo data"

    def handle(self, *args, **kwargs):
        owner = User.objects.create_user(email="ownerTest@test.com", password="Asdasdasd1!", role="owner")
        manager = User.objects.create_user(email="managerTest@test.com", password="Asdasdasd1!", role="manager")
        sales = User.objects.create_user(email="salesTest@test.com", password="Asdasdasd1!", role="sales")
        consumer = User.objects.create_user(email="consumerTest@test.com", password="Asdasdasd1!", role="consumer")

        product = Product.objects.create(
            supplier=owner,
            name="Milk premium",
            price=500,
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
            total_price=1000
        )

        self.stdout.write(self.style.SUCCESS("Demo data was created"))
