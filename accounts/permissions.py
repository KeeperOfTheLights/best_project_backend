from rest_framework.permissions import BasePermission

class IsOwner(BasePermission):
    def has_permission(self, request, view):
        return request.user.is_authenticated and request.user.role == "owner"

class IsManager(BasePermission):
    def has_permission(self, request, view):
        return request.user.is_authenticated and request.user.role == "manager"

class IsSalesRep(BasePermission):
    def has_permission(self, request, view):
        return request.user.is_authenticated and request.user.role == "sales"

class IsCompanyMember(BasePermission):
    def has_permission(self, request, view):
        return (
            request.user.is_authenticated and
            request.user.role in ["owner", "manager", "sales_rep"]
        )