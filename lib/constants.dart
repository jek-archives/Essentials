import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'utils/validators.dart';

// Product images
const productImg1 = "assets/images/products/product1.png";
const productImg2 = "assets/images/products/product2.png";
const productImg3 = "assets/images/products/product3.png";
const productImg4 = "assets/images/products/product4.png";
const productImg5 = "assets/images/products/product5.png";
const productImg6 = "assets/images/products/product6.png";

// End For demo

const grandisExtendedFont = "Grandis Extended";

// On color 80, 60.... those means opacity

const Color primaryColor = Color(0xFFFE828C); // Ensure the hex code is correct

const MaterialColor primaryMaterialColor = MaterialColor(
  0xFFFE828C, // Match this with primaryColor
  <int, Color>{
    50: Color(0xFFFFEBEE), // Lightest shade
    100: Color(0xFFFFCDD2),
    200: Color(0xFFEF9A9A),
    300: Color(0xFFE57373),
    400: Color(0xFFEF5350),
    500: Color(0xFFE53935), // Base color
    600: Color(0xFFD32F2F),
    700: Color(0xFFC62828),
    800: Color(0xFFB71C1C),
    900: Color(0xFF8E0000), // Darkest shade
  },
);

const Color blackColor = Color(0xFF16161E);
const Color blackColor80 = Color(0xFF45454B);
const Color blackColor60 = Color(0xFF737378);
const Color blackColor40 = Color(0xFFA2A2A5);
const Color blackColor20 = Color(0xFFD0D0D2);
const Color blackColor10 = Color(0xFFE8E8E9);
const Color blackColor5 = Color(0xFFF3F3F4);

const Color whiteColor = Colors.white;
const Color whileColor80 = Color(0xFFCCCCCC);
const Color whileColor60 = Color(0xFF999999);
const Color whileColor40 = Color(0xFF666666);
const Color whileColor20 = Color(0xFF333333);
const Color whileColor10 = Color(0xFF191919);
const Color whileColor5 = Color(0xFF0D0D0D);

const Color greyColor = Color(0xFFB8B5C3);
const Color lightGreyColor = Color(0xFFF8F8F9);
const Color darkGreyColor = Color(0xFF1C1C25);
// const Color greyColor80 = Color(0xFFC6C4CF);
// const Color greyColor60 = Color(0xFFD4D3DB);
// const Color greyColor40 = Color(0xFFE3E1E7);
// const Color greyColor20 = Color(0xFFF1F0F3);
// const Color greyColor10 = Color(0xFFF8F8F9);
// const Color greyColor5 = Color(0xFFFBFBFC);

const Color purpleColor = Color(0xFF7B61FF);
const Color successColor = Color(0xFF2ED573);
const Color warningColor = Color(0xFFFFBE21);
const Color errorColor = Color(0xFFEA5B5B);

const double defaultPadding = 16.0;
const double defaultBorderRadious = 12.0;
const Duration defaultDuration = Duration(milliseconds: 300);

const pasNotMatchErrorText = "passwords do not match";

const String apiBaseUrl = 'http://10.0.2.2:8000/api'; // For Android emulator
// const String apiUrl = 'http://127.0.0.1:8000/api'; // For iOS simulator

class AppConstants {
  // API Configuration
  static const String apiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://10.0.2.2:8000/api',
  );

  // App Configuration
  static const String appName = 'Essentials USTP';
  static const String appVersion = '1.0.0';
  
  // Theme Configuration
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 8.0;
  
  // Animation Durations
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  
  // Error Messages
  static const String networkError = 'Network error occurred. Please check your connection.';
  static const String serverError = 'Server error occurred. Please try again later.';
  static const String authError = 'Authentication failed. Please login again.';
  
  // Success Messages
  static const String orderSuccess = 'Order placed successfully!';
  static const String loginSuccess = 'Login successful!';
  
  // Validation Messages
  static const String requiredField = 'This field is required';
  static const String invalidEmail = 'Please enter a valid email address';
  static const String invalidPassword = 'Password must be at least 8 characters';
  
  // Placeholder Images
  static const String placeholderImage = 'assets/images/placeholder.png';
  
  // Default Values
  static const int defaultQuantity = 1;
  static const String defaultSize = 'M';
}
