import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../../models/user.dart';
import '../../../../utils/validators.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../constants.dart';
import '../../../../route/route_constants.dart';
import '../../../../models/cart.dart';
import '../../../../services/api_service.dart';

class LogInForm extends StatefulWidget {
  const LogInForm({
    super.key,
    required this.formKey,
  });

  final GlobalKey<FormState> formKey;

  @override
  State<LogInForm> createState() => _LogInFormState();
}

class _LogInFormState extends State<LogInForm> {
  String? _email;
  String? _password;
  bool _isLoading = false;

  Future<void> _login() async {
    if (widget.formKey.currentState!.validate()) {
      widget.formKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });

      try {
        print('DEBUG: Attempting login with email: $_email');
        final response = await http.post(
          Uri.parse('${AppConstants.apiUrl}/auth/login/'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: json.encode({
            'email': _email,
            'password': _password,
          }),
        );

        print('DEBUG: Login response status code: ${response.statusCode}');
        print('DEBUG: Login response headers: ${response.headers}');
        print('DEBUG: Login response body: ${response.body}');

        final responseData = json.decode(response.body);
        
        if (response.statusCode == 200) {
          // Extract token from response
          final token = responseData['token'];
          if (token == null) {
            print('DEBUG: Token is null in response');
            print('DEBUG: Full response data: $responseData');
            throw Exception('No token received from server');
          }
          print('DEBUG: Received token from server: $token');

          // First update the User singleton with backend data
          User().updateFromRegistration(
            firstName: responseData['user']['first_name'] ?? '',
            lastName: responseData['user']['last_name'] ?? '',
            email: responseData['user']['email'] ?? '',
            token: token,
          );
          print('DEBUG: User singleton updated with token: ${User().token}');

          // Then save token to SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', token);
          print('DEBUG: Token saved to SharedPreferences: $token');
          print('DEBUG: All SharedPreferences keys after login: ${prefs.getKeys()}');
          
          // Verify token was saved
          final savedToken = prefs.getString('auth_token');
          print('DEBUG: Verified saved token: $savedToken');

          // Set token in ApiService for authenticated requests
          ApiService().setAuthToken(token);

          // Load saved cart for the user
          await Cart().loadCartForUser(responseData['user']['email']);
          print('DEBUG: Loaded saved cart for user ${responseData['user']['email']}');

          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Login successful'),
              backgroundColor: Colors.green,
            ),
          );
          // Navigate to home/profile screen
          Navigator.pushReplacementNamed(context, entryPointScreenRoute);
        } else {
          // Login failed
          String errorMessage = 'Login failed';
          if (responseData is Map<String, dynamic>) {
            if (responseData.containsKey('error')) {
              errorMessage = responseData['error'];
            } else if (responseData.containsKey('detail')) {
              errorMessage = responseData['detail'];
            } else if (responseData.containsKey('message')) {
              errorMessage = responseData['message'];
            }
          }
          print('DEBUG: Login failed with error: $errorMessage');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        print('DEBUG: Login error: $e');
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
        setState(() {
          _isLoading = false;
        });
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
            onSaved: (email) {
              _email = email;
            },
            validator: emailValidator.call,
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: "Email address",
              prefixIcon: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: defaultPadding * 0.75),
                child: SvgPicture.asset(
                  "assets/icons/Message.svg",
                  height: 24,
                  width: 24,
                  colorFilter: ColorFilter.mode(
                      Theme.of(context)
                          .textTheme
                          .bodyLarge!
                          .color!
                          .withOpacity(0.3),
                      BlendMode.srcIn),
                ),
              ),
            ),
          ),
          const SizedBox(height: defaultPadding),
          TextFormField(
            onSaved: (password) {
              _password = password;
            },
            validator: passwordValidator.call,
            obscureText: true,
            decoration: InputDecoration(
              hintText: "Password",
              prefixIcon: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: defaultPadding * 0.75),
                child: SvgPicture.asset(
                  "assets/icons/Lock.svg",
                  height: 24,
                  width: 24,
                  colorFilter: ColorFilter.mode(
                      Theme.of(context)
                          .textTheme
                          .bodyLarge!
                          .color!
                          .withOpacity(0.3),
                      BlendMode.srcIn),
                ),
              ),
            ),
          ),
          const SizedBox(height: defaultPadding),
          ElevatedButton(
            onPressed: _isLoading ? null : _login,
            child: _isLoading
                ? const CircularProgressIndicator()
                : const Text('Login'),
          ),
        ],
      ),
    );
  }
}
