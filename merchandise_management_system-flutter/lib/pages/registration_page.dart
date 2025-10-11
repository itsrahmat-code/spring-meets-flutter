import 'dart:io';

import 'package:date_field/date_field.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:merchandise_management_system/service/authservice.dart';
import 'package:radio_group_v2/radio_group_v2.dart';
import 'package:radio_group_v2/radio_group_v2.dart' as v2;


class Manager extends StatefulWidget {
  const Manager({super.key});

  @override
  State<Manager> createState() => _RegistrationState();
}

class _RegistrationState extends State<Manager> {
  bool _obscurePassword = true;
  final TextEditingController name = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();

  final TextEditingController confirmPassword = TextEditingController();
  final TextEditingController cell = TextEditingController();
  final TextEditingController address = TextEditingController();

  final RadioGroupController genderController = RadioGroupController();
  final DateTimeFieldPickerPlatform dob = DateTimeFieldPickerPlatform.material;

  String? selectedGender;
  DateTime? selectedDOB;

  XFile? selectedImage;
  Uint8List? webImage;
  final ImagePicker _picker = ImagePicker();

  final _formkey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manager Registration'),
        centerTitle: true,
        backgroundColor: Colors.blue,
        // Optional: add action buttons here if you want
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(name.text.isEmpty ? 'Guest User' : name.text),
              accountEmail: Text(email.text.isEmpty ? 'guest@example.com' : email.text),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage: (kIsWeb && webImage != null)
                    ? MemoryImage(webImage!)
                    : (!kIsWeb && selectedImage != null)
                    ? FileImage(File(selectedImage!.path)) as ImageProvider
                    : null,
                child: (webImage == null && selectedImage == null)
                    ? Icon(Icons.person, size: 50, color: Colors.grey)
                    : null,
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to Home page or any action
              },
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to Profile page or any action
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to Settings page or any action
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () {
                Navigator.pop(context);
                // Perform logout operation
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formkey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 20),
                TextField(
                  controller: name,
                  decoration: InputDecoration(
                    labelText: "Full Name",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  onChanged: (_) {
                    setState(() {}); // To refresh Drawer header with name change
                  },
                ),
                SizedBox(height: 20),
                TextField(
                  controller: email,
                  decoration: InputDecoration(
                    labelText: "example@gmail.com",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  onChanged: (_) {
                    setState(() {}); // To refresh Drawer header with email change
                  },
                ),
                SizedBox(height: 20),
                TextField(
                  obscureText: _obscurePassword,
                  controller: password,
                  decoration: InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.password),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: confirmPassword,
                  decoration: InputDecoration(
                    labelText: "Confirm Password",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 20),
                TextField(
                  controller: cell,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: "Cell Number",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone_android_outlined),
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: address,
                  decoration: InputDecoration(
                    labelText: "Dhaka",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.place),
                  ),
                ),
                SizedBox(height: 20),
                DateTimeFormField(
                  decoration: const InputDecoration(labelText: "Date of Birth"),
                  mode: DateTimeFieldPickerMode.date,
                  pickerPlatform: dob,
                  onChanged: (DateTime? value) {
                    setState(() {
                      selectedDOB = value;
                    });
                  },
                ),
                SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Gender:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      v2.RadioGroup(
                        controller: genderController,
                        values: ["Male", "Female", "Other"],
                        indexOfDefault: 0,
                        orientation: RadioGroupOrientation.vertical,
                        onChanged: (newValue) {
                          setState(() {
                            selectedGender = newValue.toString();
                          });
                        },
                      ),
                      SizedBox(height: 20),
                      TextButton.icon(
                        icon: Icon(Icons.image),
                        label: Text('Upload Image'),
                        onPressed: () {
                          pickImage();
                        },
                      ),
                      // display selected image preview
                      if (kIsWeb && webImage != null)
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Image.memory(
                            webImage!,
                            height: 100,
                            width: 100,
                            fit: BoxFit.cover,
                          ),
                        )
                      else if (!kIsWeb && selectedImage != null)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.file(
                            File(selectedImage!.path),
                            height: 100,
                            width: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          _register();
                        },
                        child: Text(
                          "Registration",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontFamily: GoogleFonts.lato().fontFamily,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      SizedBox(height: 20.0),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> pickImage() async {
    if (kIsWeb) {
      // for web: use image_picker_web to pick image and store as bytes
      var pickedImage = await ImagePickerWeb.getImageAsBytes();
      if (pickedImage != null) {
        setState(() {
          webImage = pickedImage;
        });
      }
    } else {
      // for Mobile: use image_picker to pick image
      final XFile? pickedImage = await _picker.pickImage(
        source: ImageSource.gallery,
      );
      if (pickedImage != null) {
        setState(() {
          selectedImage = pickedImage;
        });
      }
    }
  }


  /// Method to handle Admin registration

  void _register() async {
    if(_formkey.currentState!.validate()) {
      if(password.text != confirmPassword.text) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Password does not match!')),
        );
        return;
      }
    }
    if(kIsWeb) {
      if(webImage ==null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select an image')),
        );
        return;
      }
    }
    else{
      if(selectedImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please Select an image')),
        );
        return;
      }
    }
    final user = {
      "name" : name.text,
      "email" : email.text,
      "phone" : cell.text,
      "password" : password.text

    };
    final manager = {
      "name": name.text,
      "email": email.text,
      "phone": cell.text,
      "gender": selectedGender ?? "Other",
      // fallback if null
      "address": address.text,
      "dateOfBirth": selectedDOB?.toIso8601String()?? "",
    };
    final apiService = AuthService();

    bool success = false;

    // ekhane error
    if (kIsWeb && webImage != null) {
      // For Web → send photo as bytes
      success = await apiService.registerManagerWeb(
        user: user,
        manager: manager,
        photoBytes: webImage!, // safe to use ! because already checked above
      );
    } else if (selectedImage != null) {
      // For Mobile → send photo as file
      success = await apiService.registerManagerWeb(
        user: user,
        manager: manager,
        photoFile: File(selectedImage!
            .path), // safe to use ! because already checked above
      );
    }
    if(success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration Successful')),
      );

    }

  }







}
