from django.db import migrations

def create_initial_data(apps, schema_editor):
    Category = apps.get_model('products', 'Category')
    Product = apps.get_model('products', 'Product')

    # Create categories
    uniforms_category = Category.objects.create(
        name='Uniforms',
        icon='uniform'
    )
    essentials_category = Category.objects.create(
        name='Essentials',
        icon='jacket'
    )

    # Create products
    Product.objects.create(
        id=1,
        image='assets/images/female_uniform.png',
        brand_name='USTP',
        title='Female Set Uniform',
        category=uniforms_category,
        price=950.00,
        sizes=['S', 'M', 'L', 'XL']
    )

    Product.objects.create(
        id=2,
        image='assets/images/executive_jacket.png',
        brand_name='USTP',
        title='Executive Jacket',
        category=essentials_category,
        price=1180.00,
        sizes=['M', 'L', 'XL']
    )

    Product.objects.create(
        id=3,
        image='assets/images/male_uniform.png',
        brand_name='USTP',
        title='Male Set Uniform',
        category=uniforms_category,
        price=1000.00,
        sizes=['S', 'M', 'L', 'XL']
    )

    Product.objects.create(
        id=4,
        image='assets/images/physicaleduc_uniform.png',
        brand_name='USTP',
        title='Physical Education Uniform',
        category=uniforms_category,
        price=450.00,
        sizes=['28', '30', '32', '34']
    )

def remove_initial_data(apps, schema_editor):
    Category = apps.get_model('products', 'Category')
    Product = apps.get_model('products', 'Product')
    
    # Remove all products
    Product.objects.all().delete()
    
    # Remove all categories
    Category.objects.all().delete()

class Migration(migrations.Migration):
    dependencies = [
        ('products', '0001_initial'),
    ]

    operations = [
        migrations.RunPython(create_initial_data, remove_initial_data),
    ] 