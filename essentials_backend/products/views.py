from django.shortcuts import render
from rest_framework import status, viewsets
from rest_framework.decorators import api_view, permission_classes, action
from rest_framework.response import Response
from rest_framework.permissions import AllowAny
from .models import Category, Product, PickupLocation
from .serializers import CategorySerializer, ProductSerializer, PickupLocationSerializer

# Create your views here.

@api_view(['GET'])
@permission_classes([AllowAny])
def product_list(request):
    products = Product.objects.all()
    serializer = ProductSerializer(products, many=True)
    return Response(serializer.data)

@api_view(['GET'])
@permission_classes([AllowAny])
def product_detail(request, pk):
    try:
        product = Product.objects.get(pk=pk)
        serializer = ProductSerializer(product)
        return Response(serializer.data)
    except Product.DoesNotExist:
        return Response(status=status.HTTP_404_NOT_FOUND)

class CategoryViewSet(viewsets.ModelViewSet):
    queryset = Category.objects.all()
    serializer_class = CategorySerializer

class ProductViewSet(viewsets.ModelViewSet):
    queryset = Product.objects.all()
    serializer_class = ProductSerializer

    @action(detail=True, methods=['post'])
    def update_stock(self, request, pk=None):
        product = self.get_object()
        quantity = request.data.get('quantity', 0)
        
        if quantity < 0 and abs(quantity) > product.stock_quantity:
            return Response({'error': 'Insufficient stock'}, status=400)
            
        product.stock_quantity += quantity
        product.save()
        
        return Response(self.get_serializer(product).data)

class PickupLocationViewSet(viewsets.ModelViewSet):
    queryset = PickupLocation.objects.filter(is_active=True)
    serializer_class = PickupLocationSerializer
    permission_classes = [AllowAny] 