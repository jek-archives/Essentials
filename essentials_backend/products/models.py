from django.db import models

# Create your models here.

class Category(models.Model):
    name = models.CharField(max_length=100)
    icon = models.CharField(max_length=50)  # Store icon name as string

    def __str__(self):
        return self.name

    class Meta:
        verbose_name_plural = "Categories"

class PickupLocation(models.Model):
    name = models.CharField(max_length=100)  # e.g., "USTP Main Campus"
    address = models.TextField()
    operating_hours = models.CharField(max_length=100)
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return self.name

    class Meta:
        ordering = ['name']

class Product(models.Model):
    image = models.CharField(max_length=255)
    brand_name = models.CharField(max_length=100)
    title = models.CharField(max_length=200)
    category = models.ForeignKey(Category, on_delete=models.CASCADE, related_name='products')
    price = models.DecimalField(max_digits=10, decimal_places=2)
    sizes = models.JSONField(null=True, blank=True)
    stock_quantity = models.PositiveIntegerField(default=0)
    reorder_level = models.PositiveIntegerField(default=10)
    last_restocked = models.DateTimeField(auto_now=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.brand_name} - {self.title}"

    @property
    def stock_status(self):
        if self.stock_quantity <= 0:
            return 'out_of_stock'
        elif self.stock_quantity <= self.reorder_level:
            return 'low_stock'
        return 'in_stock'

    class Meta:
        ordering = ['-created_at']
