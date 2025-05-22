from rest_framework import serializers
from .models import Category, Product, PickupLocation

class CategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = Category
        fields = '__all__'

class PickupLocationSerializer(serializers.ModelSerializer):
    class Meta:
        model = PickupLocation
        fields = '__all__'

class ProductSerializer(serializers.ModelSerializer):
    category = CategorySerializer(read_only=True)
    stock_status = serializers.CharField(read_only=True)
    
    class Meta:
        model = Product
        fields = [
            'id', 'image', 'brand_name', 'title', 'category',
            'price', 'sizes', 'stock_quantity', 'reorder_level',
            'last_restocked', 'stock_status', 'created_at', 'updated_at'
        ] 