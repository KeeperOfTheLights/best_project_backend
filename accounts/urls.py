from django.urls import path
from .views import RegisterView, LoginView, SupplierProductListCreateView, \
    SupplierProductDetailView, ProductStatusToggleView

urlpatterns = [
    path('register/', RegisterView.as_view(), name='register'),
    path('login/', LoginView.as_view(), name='login'),
    path("products/", SupplierProductListCreateView.as_view(), name="product-list-create"),
    path("products/<int:pk>/", SupplierProductDetailView.as_view(), name="product-detail"),
    path("products/<int:pk>/status/", ProductStatusToggleView.as_view(), name="product-status-toggle"),
]
