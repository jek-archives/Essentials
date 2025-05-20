import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../../../models/user.dart';
import '../../../constants.dart';

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

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: user.name ?? '');
    dobController = TextEditingController(text: user.dob ?? '');
    phoneController = TextEditingController(text: user.phone ?? '');
    genderController = TextEditingController(text: user.gender ?? '');
    emailController = TextEditingController(text: user.email ?? '');
    _selectedGender = user.gender;
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
      // Split name into first and last name
      final nameParts = nameController.text.split(' ');
      final firstName = nameParts.first;
      final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

      // Prepare the data
      final data = {
        'first_name': firstName,
        'last_name': lastName,
        'dob': dobController.text,
        'phone': phoneController.text,
        'gender': _selectedGender ?? '',
      };

      // If there's a new image, add it to the data
      if (user.imageUrl != null && user.imageUrl!.startsWith('/')) {
        final imageFile = File(user.imageUrl!);
        final imageBytes = await imageFile.readAsBytes();
        final base64Image = base64Encode(imageBytes);
        data['image'] = 'data:image/jpeg;base64,$base64Image';
      }

      // Make the API call
      final response = await http.put(
        Uri.parse('$apiUrl/profile/update/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${user.token}', // Assuming you store the token in the User model
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        // Update local user data
        final responseData = jsonDecode(response.body);
        user.updateFromMap(responseData);
        
        setState(() {
          _isEditing = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      } else {
        throw Exception('Failed to update profile');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        user.imageUrl = pickedFile.path;
      });
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
            child: Text(_isEditing ? 'Save' : 'Edit', style: const TextStyle(color: Colors.purple)),
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
                  child: CircleAvatar(
                    radius: 32,
                    backgroundImage: (user.imageUrl != null && user.imageUrl!.startsWith('/'))
                        ? FileImage(File(user.imageUrl!)) as ImageProvider
                        : (user.imageUrl != null && user.imageUrl!.isNotEmpty)
                            ? AssetImage(user.imageUrl!)
                            : const AssetImage('assets/images/profile.jpg'),
                    child: _isEditing
                        ? Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.3),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_alt, color: Colors.white),
                          )
                        : null,
                  ),
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
                        : Text((user.name == null || user.name!.isEmpty) ? 'Not set' : user.name!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    _isEditing
                        ? SizedBox(
                            width: 180,
                            child: TextField(
                              controller: emailController,
                              decoration: const InputDecoration(border: InputBorder.none, isDense: true),
                              style: const TextStyle(color: Colors.grey),
                            ),
                          )
                        : Text((user.email == null || user.email!.isEmpty) ? 'Not set' : user.email!, style: const TextStyle(color: Colors.grey)),
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
                    decoration: const InputDecoration(border: InputBorder.none, isDense: true),
                    style: const TextStyle(fontWeight: FontWeight.w500),
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
                      const Text(
                        'Needs verification',
                        style: TextStyle(fontSize: 10, color: Colors.orange),
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
}