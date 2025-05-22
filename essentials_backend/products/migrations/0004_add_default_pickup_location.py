from django.db import migrations

def create_default_pickup_location(apps, schema_editor):
    PickupLocation = apps.get_model('products', 'PickupLocation')
    PickupLocation.objects.create(
        name="USTP Main Campus",
        address="Cagayan de Oro City, Philippines",
        operating_hours="8:00 AM - 5:00 PM",
        is_active=True
    )

def remove_default_pickup_location(apps, schema_editor):
    PickupLocation = apps.get_model('products', 'PickupLocation')
    PickupLocation.objects.filter(name="USTP Main Campus").delete()

class Migration(migrations.Migration):
    dependencies = [
        ('products', '0003_pickuplocation_product_last_restocked_and_more'),
    ]

    operations = [
        migrations.RunPython(create_default_pickup_location, remove_default_pickup_location),
    ] 