from django.contrib import admin
from django.urls import path, include
from .views import api_index
from products.views import PickupLocationViewSet
from rest_framework.routers import DefaultRouter

router = DefaultRouter()
router.register(r'pickup-locations', PickupLocationViewSet, basename='pickup-location')

urlpatterns = [
    path('', api_index, name='api-index'),
    path('admin/', admin.site.urls),
    path('api/auth/', include('authentication.urls')),
    path('api/products/', include('products.urls')),
    path('api/orders/', include('orders.urls')),
    path('api/', include(router.urls)),  # This exposes /api/pickup-locations/
]
