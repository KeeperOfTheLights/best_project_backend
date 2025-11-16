from django.urls import path
from .views import RegisterView, LoginView, SupplierProductListCreateView, SupplierProductUpdateDeleteView

urlpatterns = [
    path('register/', RegisterView.as_view(), name='register'),
    path('login/', LoginView.as_view(), name='login'),
    path('products/', SupplierProductListCreateView.as_view(), name='supplier-products'),
    path('products/<int:pk>/', SupplierProductUpdateDeleteView.as_view(), name='supplier-product-detail'),
]
