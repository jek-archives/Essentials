from django.db import migrations

def add_ustp_pickup_location(apps, schema_editor):
    PickupLocation = apps.get_model('products', 'PickupLocation')
    PickupLocation.objects.create(
        name="USTP Main Campus",
        address="Cagayan de Oro City, Philippines",
        operating_hours="8:00 AM - 5:00 PM",
        is_active=True
    )

def remove_ustp_pickup_location(apps, schema_editor):
    PickupLocation = apps.get_model('products', 'PickupLocation')
    PickupLocation.objects.filter(name="USTP Main Campus").delete()

class Migration(migrations.Migration):
    dependencies = [
        ('products', '0004_add_default_pickup_location'),
    ]

    operations = [
        migrations.RunPython(add_ustp_pickup_location, remove_ustp_pickup_location),
    ] 