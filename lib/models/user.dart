class User {
  String? name;
  String? dob;
  String? phone;
  String? gender;
  String? email;
  String? imageUrl;
  String? token;

  static final User _instance = User._internal();

  factory User() => _instance;

  User._internal();

  String getDisplayValue(String? value) {
    return (value == null || value.isEmpty) ? 'Not set' : value;
  }

  void updateFromMap(Map<String, dynamic> data) {
    name = data['name'] ?? name;
    dob = data['dob'] ?? dob;
    phone = data['phone'] ?? phone;
    gender = data['gender'] ?? gender;
    email = data['email'] ?? email;
    imageUrl = data['imageUrl'] ?? imageUrl;
    token = data['token'] ?? token;
  }

  void updateFromRegistration({
    required String firstName,
    required String lastName,
    required String email,
    String? token,
  }) {
    name = '$firstName $lastName';
    this.email = email;
    this.token = token;
  }
}