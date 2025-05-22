import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../../../models/user.dart';
import '../../../constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserInfoScreen extends StatefulWidget {
  const UserInfoScreen({super.key});

  @override
  State<UserInfoScreen> createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  final User user = User();
  late TextEditingController nameController;
  late TextEditingController dobController;
  late TextEditingController phoneController;
  late TextEditingController genderController;
  late TextEditingController emailController;
  String? _selectedGender;
  bool _isEditing = false;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();
  String? _tempImagePath;
  bool _isVerifyingPhone = false;
  String? _verificationCode;
  bool _isPhoneVerified = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: user.name ?? '');
    dobController = TextEditingController(text: user.dob ?? '');
    phoneController = TextEditingController(text: user.phone ?? '');
    genderController = TextEditingController(text: user.gender ?? '');
    emailController = TextEditingController(text: user.email ?? '');
    _selectedGender = user.gender;
    
    // Load user data when screen initializes
    _loadUserData();
  }

  @override
  void dispose() {
    nameController.dispose();
    dobController.dispose();
    phoneController.dispose();
    genderController.dispose();
    emailController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Ensure token is loaded from SharedPreferences if not present
      if (user.token == null) {
        final prefs = await SharedPreferences.getInstance();
        user.token = prefs.getString('auth_token');
        if (user.token == null) {
          throw Exception('No authentication token found');
        }
      }

      // Prepare the data with only non-empty fields
      final data = <String, dynamic>{};
      
      if (nameController.text.isNotEmpty) {
        final nameParts = nameController.text.split(' ');
        data['first_name'] = nameParts.first;
        data['last_name'] = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
      }
      if (dobController.text.isNotEmpty) {
        data['date_of_birth'] = dobController.text;
      }
      if (phoneController.text.isNotEmpty) {
        data['phone_number'] = phoneController.text;
      }
      if (_selectedGender != null && _selectedGender!.isNotEmpty) {
        data['gender'] = _selectedGender;
      }
      if (emailController.text.isNotEmpty) {
        data['email'] = emailController.text;
      }

      // If there's a new image, add it to the data
      if (_tempImagePath != null) {
        final imageFile = File(_tempImagePath!);
        final imageBytes = await imageFile.readAsBytes();
        final base64Image = base64Encode(imageBytes);
        data['image'] = 'data:image/jpeg;base64,$base64Image';
      }

      // If no data to update, return early
      if (data.isEmpty) {
        setState(() {
          _isEditing = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No changes to save'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      print('DEBUG: Sending update request with data: $data');

      // Make the API call
      final response = await http.put(
        Uri.parse('$apiBaseUrl/auth/profile/update/'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Token ${user.token}',
        },
        body: jsonEncode(data),
      );

      print('DEBUG: Update profile response status: ${response.statusCode}');
      print('DEBUG: Update profile response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          // Update local user data
          final responseData = jsonDecode(response.body);
          user.updateFromMap(responseData);
          
          // Save to SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          if (data.containsKey('first_name')) {
            await prefs.setString('user_name', user.name ?? '');
          }
          if (data.containsKey('email')) {
            await prefs.setString('user_email', user.email ?? '');
          }
          if (responseData['image'] != null) {
            await prefs.setString('user_image', responseData['image']);
          }
          
          setState(() {
            _isEditing = false;
            _tempImagePath = null;
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile updated successfully'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } catch (e) {
          print('DEBUG: Error parsing update response: $e');
          throw Exception('Invalid response format from server');
        }
      } else {
        String errorMessage = 'Failed to update profile';
        try {
          final errorData = jsonDecode(response.body);
          if (errorData is Map) {
            if (errorData.containsKey('detail')) {
              errorMessage = errorData['detail'];
            } else if (errorData.containsKey('message')) {
              errorMessage = errorData['message'];
            } else if (errorData.containsKey('error')) {
              errorMessage = errorData['error'];
            } else {
              final firstError = errorData.values.firstWhere(
                (value) => value is String || (value is List && value.isNotEmpty),
                orElse: () => null,
              );
              if (firstError != null) {
                errorMessage = firstError is List ? firstError.first : firstError;
              }
            }
          }
        } catch (e) {
          print('DEBUG: Error parsing error response: $e');
          errorMessage = 'Server error: ${response.statusCode}';
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('DEBUG: Error updating profile: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: ${e.toString()}'),
            backgroundColor: errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.parse('$apiBaseUrl/auth/profile/'),
        headers: {
          'Authorization': 'Token $token',
          'Accept': 'application/json',
        },
      );

      print('DEBUG: Load profile response status: ${response.statusCode}');
      print('DEBUG: Load profile response body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final userData = jsonDecode(response.body);
          user.updateFromMap({
            'name': '${userData['first_name']} ${userData['last_name']}'.trim(),
            'email': userData['email'],
            'dob': userData['date_of_birth'],
            'phone': userData['phone_number'],
            'gender': userData['gender'],
            'imageUrl': userData['image'],
          });
          
          // Update controllers with user data
          nameController.text = user.name ?? '';
          dobController.text = user.dob ?? '';
          phoneController.text = user.phone ?? '';
          genderController.text = user.gender ?? '';
          emailController.text = user.email ?? '';
          _selectedGender = user.gender;
          
          // Save to SharedPreferences for other parts of the app
          await prefs.setString('user_name', user.name ?? '');
          await prefs.setString('user_email', user.email ?? '');
          if (userData['image'] != null) {
            await prefs.setString('user_image', userData['image']);
          }
          
          setState(() {});
        } catch (e) {
          print('DEBUG: Error parsing user data: $e');
          throw Exception('Invalid response format from server');
        }
      } else {
        throw Exception('Failed to load user data: ${response.statusCode}');
      }
    } catch (e) {
      print('DEBUG: Error loading user data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading profile: ${e.toString()}'),
            backgroundColor: errorColor,
          ),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _tempImagePath = pickedFile.path;
      });
    }
  }

  Widget _buildProfileImage() {
    if (_tempImagePath != null) {
      return CircleAvatar(
        radius: 32,
        backgroundImage: FileImage(File(_tempImagePath!)),
        child: _isEditing
            ? Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.camera_alt, color: Colors.white),
              )
            : null,
      );
    } else if (user.imageUrl != null && user.imageUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: 32,
        backgroundImage: NetworkImage(user.imageUrl!),
        child: _isEditing
            ? Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.camera_alt, color: Colors.white),
              )
            : null,
      );
    } else {
      return CircleAvatar(
        radius: 32,
        backgroundColor: Colors.grey[300],
        child: _isEditing
            ? Stack(
                children: [
                  const Icon(Icons.person, size: 40, color: Colors.grey),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt, color: Colors.white),
                  ),
                ],
              )
            : const Icon(Icons.person, size: 40, color: Colors.grey),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                  ),
                ),
              ),
            )
          else
            TextButton(
              onPressed: () {
                setState(() {
                  if (_isEditing) {
                    _save();
                  } else {
                    _isEditing = true;
                  }
                });
              },
              child: Text(
                _isEditing ? 'Save' : 'Edit',
                style: const TextStyle(color: primaryColor),
              ),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Row(
              children: [
                GestureDetector(
                  onTap: _isEditing ? _pickImage : null,
                  child: _buildProfileImage(),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _isEditing
                        ? SizedBox(
                            width: 150,
                            child: TextField(
                              controller: nameController,
                              decoration: const InputDecoration(border: InputBorder.none, isDense: true),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          )
                        : Text(
                            (user.name == null || user.name!.isEmpty) ? 'Not set' : user.name!,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                    _isEditing
                        ? SizedBox(
                            width: 180,
                            child: TextField(
                              controller: emailController,
                              decoration: const InputDecoration(border: InputBorder.none, isDense: true),
                              style: const TextStyle(color: Colors.grey),
                            ),
                          )
                        : Text(
                            (user.email == null || user.email!.isEmpty) ? 'Not set' : user.email!,
                            style: const TextStyle(color: Colors.grey),
                          ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),
            _buildInfoRow('Name', nameController, user.name ?? '', _isEditing),
            _buildDatePickerRow('Date of birth', dobController, user.dob ?? '', _isEditing),
            _buildPhoneRow('Phone number', phoneController, user.phone ?? '', _isEditing),
            _buildGenderDropdownRow('Gender', _selectedGender, _isEditing),
            _buildInfoRow('Email', emailController, user.email ?? '', _isEditing),
            _buildPasswordRow(context),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, TextEditingController controller, String value, bool isEditing) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          isEditing
              ? SizedBox(
                  width: 180,
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      hintText: 'Enter ${label.toLowerCase()}',
                    ),
                    style: const TextStyle(fontWeight: FontWeight.w500),
                    textCapitalization: label == 'Name' ? TextCapitalization.words : TextCapitalization.none,
                  ),
                )
              : Text(user.getDisplayValue(value), style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildDatePickerRow(String label, TextEditingController controller, String value, bool isEditing) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          isEditing
              ? SizedBox(
                  width: 180,
                  child: GestureDetector(
                    onTap: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: controller.text.isNotEmpty ? DateTime.parse(controller.text) : DateTime(2000),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        controller.text = picked.toIso8601String().split('T')[0];
                        setState(() {});
                      }
                    },
                    child: AbsorbPointer(
                      child: TextField(
                        controller: controller,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          hintText: 'YYYY-MM-DD',
                        ),
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                )
              : Text(user.getDisplayValue(value), style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildPhoneRow(String label, TextEditingController controller, String value, bool isEditing) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          isEditing
              ? SizedBox(
                  width: 180,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: controller,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(border: InputBorder.none, isDense: true),
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Row(
                        children: [
                          Text(
                            _isPhoneVerified ? 'Verified' : 'Needs verification',
                            style: TextStyle(
                              fontSize: 10,
                              color: _isPhoneVerified ? Colors.green : Colors.orange,
                            ),
                          ),
                          if (!_isPhoneVerified)
                            TextButton(
                              onPressed: _isVerifyingPhone ? null : _sendVerificationCode,
                              child: _isVerifyingPhone
                                  ? const SizedBox(
                                      width: 12,
                                      height: 12,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'Verify',
                                      style: TextStyle(fontSize: 10),
                                    ),
                            ),
                        ],
                      ),
                    ],
                  ),
                )
              : Text(user.getDisplayValue(value), style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildGenderDropdownRow(String label, String? selectedGender, bool isEditing) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          isEditing
              ? SizedBox(
                  width: 180,
                  child: DropdownButtonFormField<String>(
                    value: selectedGender?.isNotEmpty == true ? selectedGender : null,
                    items: const [
                      DropdownMenuItem(value: 'Male', child: Text('Male')),
                      DropdownMenuItem(value: 'Female', child: Text('Female')),
                      DropdownMenuItem(value: 'Other', child: Text('Other')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedGender = value;
                      });
                    },
                    decoration: const InputDecoration(border: InputBorder.none, isDense: true),
                    style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black),
                  ),
                )
              : Text(user.getDisplayValue(selectedGender ?? ''), style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildPasswordRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Password', style: TextStyle(color: Colors.grey)),
          GestureDetector(
            onTap: () {
              // Handle change password
            },
            child: const Text('Change Password', style: TextStyle(color: Colors.purple)),
          ),
        ],
      ),
    );
  }

  Future<void> _sendVerificationCode() async {
    if (phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a phone number first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Format phone number to E.164 format
    String phoneNumber = phoneController.text;
    if (!phoneNumber.startsWith('+')) {
      phoneNumber = '+63${phoneNumber.startsWith('0') ? phoneNumber.substring(1) : phoneNumber}';
    }

    print('DEBUG: Sending verification code to phone number: $phoneNumber');

    setState(() {
      _isVerifyingPhone = true;
    });

    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/auth/phone/send-verification/'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Token ${user.token}',
        },
        body: jsonEncode({
          'phone_number': phoneNumber,
        }),
      );

      print('DEBUG: Send verification response status: ${response.statusCode}');
      print('DEBUG: Send verification response body: ${response.body}');

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Verification code sent successfully'),
              backgroundColor: Colors.green,
            ),
          );
          _showVerificationDialog();
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to send verification code');
      }
    } catch (e) {
      print('DEBUG: Error sending verification code: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isVerifyingPhone = false;
        });
      }
    }
  }

  Future<void> _verifyPhoneNumber() async {
    if (_verificationCode == null || _verificationCode!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the verification code'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/auth/phone/verify/'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Token ${user.token}',
        },
        body: jsonEncode({
          'phone_number': phoneController.text,
          'verification_code': _verificationCode,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        setState(() {
          _isPhoneVerified = responseData['user']['is_phone_verified'];
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Phone number verified successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context); // Close the verification dialog
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to verify phone number');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showVerificationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Verification Code'),
        content: TextField(
          keyboardType: TextInputType.number,
          maxLength: 6,
          decoration: const InputDecoration(
            hintText: 'Enter 6-digit code',
            counterText: '',
          ),
          onChanged: (value) {
            _verificationCode = value;
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: _verifyPhoneNumber,
            child: const Text('Verify'),
          ),
        ],
      ),
    );
  }
}