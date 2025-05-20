from django.urls import path
from . import views

urlpatterns = [
    path('login/', views.login_view, name='login'),
    path('register/', views.register_view, name='register'),
    path('verify-email/<uuid:token>/', views.verify_email_view, name='verify-email'),
    path('password-reset/', views.password_reset_request_view, name='password-reset'),
    path('reset-password/<uuid:token>/', views.password_reset_confirm_view, name='password-reset-confirm'),
    path('profile/update/', views.update_profile_view, name='profile-update'),
]