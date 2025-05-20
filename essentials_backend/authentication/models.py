from django.db import models
from django.contrib.auth.models import AbstractUser, Group, Permission
import uuid
from django.utils import timezone
from datetime import timedelta
from django.conf import settings

class User(AbstractUser):
    date_of_birth = models.DateField(null=True, blank=True)
    phone_number = models.CharField(max_length=20, null=True, blank=True)
    gender = models.CharField(max_length=10, null=True, blank=True)
    groups = models.ManyToManyField(
        Group,
        related_name='customuser_set',
        blank=True,
        help_text='The groups this user belongs to.',
        related_query_name='user',
    )
    user_permissions = models.ManyToManyField(
        Permission,
        related_name='customuser_set',
        blank=True,
        help_text='Specific permissions for this user.',
        related_query_name='user',
    )
    @property
    def name(self):
        return f"{self.first_name} {self.last_name}".strip()

class EmailVerificationToken(models.Model):
    user = models.OneToOneField(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    token = models.UUIDField(default=uuid.uuid4, editable=False)
    created_at = models.DateTimeField(auto_now_add=True)
    is_verified = models.BooleanField(default=False)

    def is_valid(self):
        expiry_time = self.created_at + timedelta(hours=getattr(settings, 'VERIFICATION_TOKEN_EXPIRY', 24))
        return timezone.now() <= expiry_time and not self.is_verified

    def __str__(self):
        return f"Token for {self.user.email}"

class PasswordResetToken(models.Model):
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    token = models.UUIDField(default=uuid.uuid4, editable=False)
    created_at = models.DateTimeField(auto_now_add=True)
    is_used = models.BooleanField(default=False)

    def is_valid(self):
        expiry_time = self.created_at + timedelta(hours=24)
        return timezone.now() <= expiry_time and not self.is_used

    def __str__(self):
        return f"Password reset token for {self.user.email}"