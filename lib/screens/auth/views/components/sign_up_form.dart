import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'verification_dialog.dart';
import '../../../../models/user.dart';
import '../../../../utils/validators.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../constants.dart';
import '../../../../route/route_constants.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({
    super.key,
    required this.formKey,
    required this.onLoadingChanged,
  });

  final GlobalKey<FormState> formKey;
  final Function(bool) onLoadingChanged;

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final FocusNode _passwordFocusNode = FocusNode();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!widget.formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });
    widget.onLoadingChanged(true);

    try {
      print('Attempting to register with email: ${_emailController.text}');
      final response = await http.post(
        Uri.parse('${apiBaseUrl}/auth/register/'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'first_name': _firstNameController.text,
          'last_name': _lastNameController.text,
          'email': _emailController.text,
          'password': _passwordController.text,
          'confirm_password': _confirmPasswordController.text,
        }),
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (!mounted) return;
        User().updateFromRegistration(
          firstName: _firstNameController.text,
          lastName: _lastNameController.text,
          email: _emailController.text,
          token: responseData['token'],
        );
        if (responseData['token'] != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', responseData['token']);
          print('DEBUG: Token saved to SharedPreferences: ${responseData['token']}');
        }
        final emailForDialog = _emailController.text;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => VerificationDialog(
            email: emailForDialog,
          ),
        );
        _firstNameController.clear();
        _lastNameController.clear();
        _emailController.clear();
        _passwordController.clear();
        _confirmPasswordController.clear();
      } else {
        if (!mounted) return;
        String errorMessage = 'Registration failed';
        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('error')) {
            errorMessage = responseData['error'];
          } else if (responseData.containsKey('detail')) {
            errorMessage = responseData['detail'];
          } else if (responseData.containsKey('message')) {
            errorMessage = responseData['message'];
          }
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Registration error: $e');
      if (!mounted) return;
      String errorMessage = 'Connection error. Please try again.';
      if (e.toString().contains('Connection refused')) {
        errorMessage = 'Cannot connect to server. Please check if the server is running.';
      } else if (e.toString().contains('SocketException')) {
        errorMessage = 'Network error. Please check your internet connection.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        widget.onLoadingChanged(false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _firstNameController,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              hintText: "First Name",
              prefixIcon: Icon(Icons.person_outline),
            ),
            validator: nameValidator.call,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _lastNameController,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              hintText: "Last Name",
              prefixIcon: Icon(Icons.person_outline),
            ),
            validator: nameValidator.call,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: "Email address",
              prefixIcon: Icon(Icons.email_outlined),
            ),
            validator: emailValidator.call,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            focusNode: _passwordFocusNode,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              hintText: "Password",
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            ),
            validator: passwordValidator.call,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            decoration: InputDecoration(
              hintText: "Confirm Password",
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),
            ),
            validator: (value) => confirmPasswordValidator(value, _passwordController.text),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _register,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A4A4A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('CREATE ACCOUNT'),
            ),
          ),
        ],
      ),
    );
  }
}