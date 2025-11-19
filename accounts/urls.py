from django.urls import path
from .views import *

urlpatterns = [
    path('register/', RegisterView.as_view(), name='register'),
    path('login/', LoginView.as_view(), name='login'),
    path("products/", SupplierProductListCreateView.as_view(), name="product-list-create"),
    path("products/<int:pk>/", SupplierProductDetailView.as_view(), name="product-detail"),
    path("products/<int:pk>/status/", ProductStatusToggleView.as_view(), name="product-status-toggle"),
    path("link/send/", SendLinkRequestView.as_view(), name="send-link"),
    path("links/", SupplierLinkListView.as_view()),
    path("link/<int:link_id>/", UnlinkView.as_view()),
    path("link/<int:link_id>/accept/", AcceptLinkView.as_view()),
    path("link/<int:link_id>/reject/", RejectLinkView.as_view()),
    path("link/<int:link_id>/block/", BlockLinkView.as_view()),
    path("link/<int:link_id>/unblock/", UnblockLinkView.as_view()),
    path("suppliers/", AllSuppliersView.as_view(), name="all-suppliers"),
    path("consumer/links/", ConsumerLinkListView.as_view(), name="consumer-links"),
    path("supplier/<int:supplier_id>/catalog/", SupplierCatalogView.as_view(), name="supplier-catalog"),

]
