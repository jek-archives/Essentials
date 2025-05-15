import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../../models/user.dart';

class UserInfoScreen extends StatefulWidget {
  const UserInfoScreen({Key? key}) : super(key: key);

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
  bool _isEditing = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: user.name);
    dobController = TextEditingController(text: user.dob);
    phoneController = TextEditingController(text: user.phone);
    genderController = TextEditingController(text: user.gender);
    emailController = TextEditingController(text: user.email);
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

  void _save() {
    setState(() {
      user.name = nameController.text;
      user.dob = dobController.text;
      user.phone = phoneController.text;
      user.gender = genderController.text;
      user.email = emailController.text;
      _isEditing = false;
    });
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
                    backgroundImage: user.imageUrl.startsWith('/')
                        ? FileImage(File(user.imageUrl)) as ImageProvider
                        : AssetImage(user.imageUrl),
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
                        : Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    _isEditing
                        ? SizedBox(
                            width: 180,
                            child: TextField(
                              controller: emailController,
                              decoration: const InputDecoration(border: InputBorder.none, isDense: true),
                              style: const TextStyle(color: Colors.grey),
                            ),
                          )
                        : Text(user.email, style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),
            _buildInfoRow('Name', nameController, user.name, _isEditing),
            _buildInfoRow('Date of birth', dobController, user.dob, _isEditing),
            _buildInfoRow('Phone number', phoneController, user.phone, _isEditing),
            _buildInfoRow('Gender', genderController, user.gender, _isEditing),
            _buildInfoRow('Email', emailController, user.email, _isEditing),
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
              : Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
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