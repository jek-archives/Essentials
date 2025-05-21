from django.db import models

# Create your models here.

class Category(models.Model):
    name = models.CharField(max_length=100)
    icon = models.CharField(max_length=50)  # Store icon name as string

    def __str__(self):
        return self.name

    class Meta:
        verbose_name_plural = "Categories"

class Product(models.Model):
    image = models.CharField(max_length=255)
    brand_name = models.CharField(max_length=100)
    title = models.CharField(max_length=200)
    category = models.ForeignKey(Category, on_delete=models.CASCADE, related_name='products')
    price = models.DecimalField(max_digits=10, decimal_places=2)
    sizes = models.JSONField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.brand_name} - {self.title}"

    class Meta:
        ordering = ['-created_at']
