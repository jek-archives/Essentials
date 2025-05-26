from django.shortcuts import render
from django.contrib.auth import authenticate, login
from django.contrib.auth import get_user_model
User = get_user_model()
from rest_framework import status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response
from rest_framework.permissions import AllowAny
from django.views.decorators.csrf import csrf_exempt, ensure_csrf_cookie
from django.core.mail import send_mail
from django.conf import settings
from .models import EmailVerificationToken, PasswordResetToken
from django.template.loader import render_to_string
from django.utils.html import strip_tags
from django.template import loader
from rest_framework.permissions import IsAuthenticated
from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response
from rest_framework.authtoken.models import Token
from django.core.cache import cache
import random

# Create your views here.

@csrf_exempt
@api_view(['POST'])
@permission_classes([AllowAny])
def login_view(request):
    email = request.data.get('email')
    password = request.data.get('password')

    if not email or not password:
        return Response(
            {'error': 'Please provide both email and password'},
            status=status.HTTP_400_BAD_REQUEST
        )

    try:
        user = User.objects.get(email=email)
    except User.DoesNotExist:
        return Response(
            {'error': 'Invalid email or password'},
            status=status.HTTP_401_UNAUTHORIZED
        )

    if not user.is_active:
        return Response(
            {'error': 'Please verify your email address before logging in'},
            status=status.HTTP_401_UNAUTHORIZED
        )

    user = authenticate(username=user.username, password=password)
    if user is not None:
        login(request, user)
        # Get or create token for the user
        token, _ = Token.objects.get_or_create(user=user)
        return Response({
            'message': 'Login successful',
            'token': token.key,
            'user': {
                'id': user.id,
                'email': user.email,
                'username': user.username,
                'first_name': user.first_name,
                'last_name': user.last_name,
            }
        })
    else:
        return Response(
            {'error': 'Invalid email or password'},
            status=status.HTTP_401_UNAUTHORIZED
        )

@csrf_exempt
@api_view(['POST'])
@permission_classes([AllowAny])
def register_view(request):
    print("Registration request data:", request.data)  # Debug print
    first_name = request.data.get('first_name')
    last_name = request.data.get('last_name')
    email = request.data.get('email')
    password = request.data.get('password')
    confirm_password = request.data.get('confirm_password')

    # Validate all fields
    if not first_name or not last_name or not email or not password or not confirm_password:
        return Response(
            {'error': 'Please provide first name, last name, email, password and confirm password'},
            status=status.HTTP_400_BAD_REQUEST
        )

    if password != confirm_password:
        return Response(
            {'error': 'Passwords do not match'},
            status=status.HTTP_400_BAD_REQUEST
        )

    if User.objects.filter(email=email).exists():
        return Response(
            {'error': 'Email already registered'},
            status=status.HTTP_400_BAD_REQUEST
        )

    # Create username from email (before @ symbol)
    username = email.split('@')[0]
    base_username = username
    counter = 1
    while User.objects.filter(username=username).exists():
        username = f"{base_username}{counter}"
        counter += 1

    try:
        # Create user with first and last name
        user = User.objects.create_user(
            username=username,
            email=email,
            password=password,
            is_active=False,  # User will be activated after email verification
            first_name=first_name,
            last_name=last_name,
        )

        # Create verification token
        verification_token = EmailVerificationToken.objects.create(user=user)

        # Send verification email
        verification_url = f"http://localhost:8000/api/auth/verify-email/{verification_token.token}/"
        html_message = render_to_string('email/verification_email.html', {
            'verification_url': verification_url,
            'username': username
        })
        plain_message = strip_tags(html_message)

        try:
            send_mail(
                'Verify your email address',
                plain_message,
                settings.EMAIL_HOST_USER,
                [email],
                html_message=html_message,
                fail_silently=False,
            )
            print("Verification email sent successfully to:", email)  # Debug print
        except Exception as e:
            print("Error sending verification email:", str(e))  # Debug print
            # Delete the user and token if email sending fails
            user.delete()
            return Response(
                {'error': 'Failed to send verification email. Please try again.'},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )

        return Response({
            'message': 'Registration successful! Please check your email to verify your account.',
            'user': {
                'id': user.id,
                'email': user.email,
                'username': user.username,
            }
        })
    except Exception as e:
        print("Registration error:", str(e))  # Debug print
        return Response(
            {'error': str(e)},
            status=status.HTTP_400_BAD_REQUEST
        )

@csrf_exempt
@api_view(['GET'])
@permission_classes([AllowAny])
def verify_email_view(request, token):
    try:
        verification = EmailVerificationToken.objects.get(token=token)
        if verification.is_valid():
            user = verification.user
            user.is_active = True
            user.save()
            verification.is_verified = True
            verification.save()
            
            # Render the success template
            return render(request, 'email/verification_success.html')
        else:
            return Response({
                'error': 'Verification link has expired or is invalid.'
            }, status=status.HTTP_400_BAD_REQUEST)
    except EmailVerificationToken.DoesNotExist:
        return Response({
            'error': 'Invalid verification link.'
        }, status=status.HTTP_400_BAD_REQUEST)

@csrf_exempt
@api_view(['POST'])
@permission_classes([AllowAny])
def password_reset_request_view(request):
    email = request.data.get('email')
    if not email:
        return Response({'error': 'Please provide your email address.'}, status=status.HTTP_400_BAD_REQUEST)
    try:
        user = User.objects.get(email=email)
    except User.DoesNotExist:
        # For security, don't reveal if email exists
        return Response({'message': 'If this email is registered, a password reset link has been sent.'})

    # Create a password reset token
    reset_token = PasswordResetToken.objects.create(user=user)
    reset_url = f"http://localhost:8000/api/auth/reset-password/{reset_token.token}/"
    html_message = render_to_string('email/password_reset_email.html', {
        'reset_url': reset_url,
        'username': user.username
    })
    plain_message = strip_tags(html_message)
    try:
        send_mail(
            'Reset your password',
            plain_message,
            settings.EMAIL_HOST_USER,
            [email],
            html_message=html_message,
            fail_silently=False,
        )
    except Exception as e:
        print("Error sending password reset email:", str(e))
        return Response({'error': 'Failed to send password reset email.'}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
    return Response({'message': 'If this email is registered, a password reset link has been sent.'})

@csrf_exempt
@api_view(['GET', 'POST'])
@permission_classes([AllowAny])
def password_reset_confirm_view(request, token):
    if request.method == 'GET':
        # Render a password reset HTML form
        try:
            reset_token = PasswordResetToken.objects.get(token=token)
            if not reset_token.is_valid():
                return render(request, 'email/password_reset_invalid.html')
        except PasswordResetToken.DoesNotExist:
            return render(request, 'email/password_reset_invalid.html')
        return render(request, 'email/password_reset_form.html', {'token': token})

    # POST: handle password reset
    password = request.data.get('password') if request.content_type == 'application/json' else request.POST.get('password')
    confirm_password = request.data.get('confirm_password') if request.content_type == 'application/json' else request.POST.get('confirm_password')
    if not password or not confirm_password:
        if request.content_type == 'application/json':
            return Response({'error': 'Please provide both password fields.'}, status=status.HTTP_400_BAD_REQUEST)
        else:
            return render(request, 'email/password_reset_form.html', {'token': token, 'error': 'Please provide both password fields.'})
    if password != confirm_password:
        if request.content_type == 'application/json':
            return Response({'error': 'Passwords do not match.'}, status=status.HTTP_400_BAD_REQUEST)
        else:
            return render(request, 'email/password_reset_form.html', {'token': token, 'error': 'Passwords do not match.'})
    try:
        reset_token = PasswordResetToken.objects.get(token=token)
        if not reset_token.is_valid():
            if request.content_type == 'application/json':
                return Response({'error': 'Reset link has expired or is invalid.'}, status=status.HTTP_400_BAD_REQUEST)
            else:
                return render(request, 'email/password_reset_invalid.html')
        user = reset_token.user
        user.set_password(password)
        user.save()
        reset_token.is_used = True
        reset_token.save()
        if request.content_type == 'application/json':
            return Response({'message': 'Password has been reset successfully.'})
        else:
            return render(request, 'email/password_reset_success.html')
    except PasswordResetToken.DoesNotExist:
        if request.content_type == 'application/json':
            return Response({'error': 'Invalid reset link.'}, status=status.HTTP_400_BAD_REQUEST)
        else:
            return render(request, 'email/password_reset_invalid.html')

@csrf_exempt
@api_view(['PUT'])
@permission_classes([IsAuthenticated])
def update_profile_view(request):
    user = request.user
    data = request.data

    # Update fields
    user.first_name = data.get('first_name', user.first_name)
    user.last_name = data.get('last_name', user.last_name)
    user.email = data.get('email', user.email)
    user.date_of_birth = data.get('date_of_birth', user.date_of_birth)
    user.phone_number = data.get('phone_number', user.phone_number)
    user.gender = data.get('gender', user.gender)
    user.save()

    return Response({
        'id': user.id,
        'email': user.email,
        'first_name': user.first_name,
        'last_name': user.last_name,
        'name': user.name,
        'date_of_birth': user.date_of_birth,
        'phone_number': user.phone_number,
        'gender': user.gender,
    })

@csrf_exempt
@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_profile_view(request):
    user = request.user
    return Response({
        'id': user.id,
        'email': user.email,
        'username': user.username,
        'first_name': user.first_name,
        'last_name': user.last_name,
        'date_of_birth': user.date_of_birth,
        'phone_number': user.phone_number,
        'gender': user.gender,
        'image': user.image.url if hasattr(user, 'image') and user.image else None,
    })

@csrf_exempt
@api_view(['POST'])
@permission_classes([IsAuthenticated])
def send_phone_verification(request):
    phone_number = request.data.get('phone_number')
    if not phone_number:
        return Response({'error': 'Phone number is required'}, status=status.HTTP_400_BAD_REQUEST)

    try:
        # Generate a 6-digit verification code
        verification_code = '123456'  # Fixed code for testing
        print(f"DEBUG: Generated verification code: {verification_code}")
        
        # Store the code in cache with 10-minute expiration
        cache_key = f'phone_verification_{phone_number}'
        cache.set(cache_key, verification_code, 600)  # 600 seconds = 10 minutes
        print(f"DEBUG: Stored verification code in cache with key: {cache_key}")
        
        return Response({
            'message': 'Verification code sent successfully',
            'verification_code': verification_code  # Only for testing! Remove in production
        })
    except Exception as e:
        print(f"DEBUG: Error: {str(e)}")
        return Response({
            'error': f'An error occurred: {str(e)}'
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

@csrf_exempt
@api_view(['POST'])
@permission_classes([IsAuthenticated])
def verify_phone_number(request):
    phone_number = request.data.get('phone_number')
    verification_code = request.data.get('verification_code')
    
    if not phone_number or not verification_code:
        return Response({
            'error': 'Phone number and verification code are required'
        }, status=status.HTTP_400_BAD_REQUEST)

    # Get stored verification code
    cache_key = f'phone_verification_{phone_number}'
    stored_code = cache.get(cache_key)
    
    if not stored_code:
        return Response({
            'error': 'Verification code has expired. Please request a new one.'
        }, status=status.HTTP_400_BAD_REQUEST)
    
    if verification_code != stored_code:
        return Response({
            'error': 'Invalid verification code'
        }, status=status.HTTP_400_BAD_REQUEST)
    
    # Update user's phone number and mark it as verified
    user = request.user
    user.phone_number = phone_number
    user.is_phone_verified = True
    user.save()
    
    # Clear the verification code from cache
    cache.delete(cache_key)
    
    return Response({
        'message': 'Phone number verified successfully',
        'user': {
            'phone_number': user.phone_number,
            'is_phone_verified': user.is_phone_verified
        }
    })