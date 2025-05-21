import 'package:form_field_validator/form_field_validator.dart';

final emailValidator = MultiValidator([
  RequiredValidator(errorText: 'Email is required'),
  EmailValidator(errorText: 'Please enter a valid email address'),
]);

final passwordValidator = MultiValidator([
  RequiredValidator(errorText: 'Password is required'),
  MinLengthValidator(8, errorText: 'Password must be at least 8 characters long'),
  PatternValidator(
    r'(?=.*?[#?!@$%^&*-])',
    errorText: 'Password must have at least one special character',
  ),
  PatternValidator(
    r'(?=.*?[A-Z])',
    errorText: 'Password must have at least one uppercase letter',
  ),
  PatternValidator(
    r'(?=.*?[a-z])',
    errorText: 'Password must have at least one lowercase letter',
  ),
  PatternValidator(
    r'(?=.*?[0-9])',
    errorText: 'Password must have at least one number',
  ),
]);

final nameValidator = MultiValidator([
  RequiredValidator(errorText: 'Name is required'),
  MinLengthValidator(2, errorText: 'Name must be at least 2 characters long'),
  PatternValidator(
    r'^[a-zA-Z\s]+$',
    errorText: 'Name can only contain letters and spaces',
  ),
]);

String? confirmPasswordValidator(String? value, String password) {
  if (value == null || value.isEmpty) {
    return 'Please confirm your password';
  }
  if (value != password) {
    return 'Passwords do not match';
  }
  return null;
} 