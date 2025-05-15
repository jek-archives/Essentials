class User {
  String name;
  String dob;
  String phone;
  String gender;
  String email;
  String imageUrl;

  static final User _instance = User._internal();

  factory User() => _instance;

  User._internal()
      : name = "Sepide",
        dob = "Oct 31, 1997",
        phone = "+1-202-555-0162",
        gender = "Female",
        email = "Sepide@piqo.design",
        imageUrl = "assets/images/profile.jpg";
}