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
  State<Manager> createState() => _ManagerState();
}

class _ManagerState extends State<Manager> {
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  // Controllers
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();
  final cell = TextEditingController();
  final address = TextEditingController();

  final genderController = RadioGroupController();
  final picker = ImagePicker();

  String? selectedGender;
  DateTime? selectedDOB;

  XFile? selectedImage;
  Uint8List? webImage;

  final dobPickerPlatform = DateTimeFieldPickerPlatform.material;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manager Registration'),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      drawer: _buildDrawer(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTextInput(name, "Full Name", Icons.person),
                const SizedBox(height: 16),
                _buildTextInput(email, "Email", Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: _validateEmail),
                const SizedBox(height: 16),
                _buildPasswordInput(password, "Password"),
                const SizedBox(height: 16),
                _buildPasswordInput(confirmPassword, "Confirm Password"),
                const SizedBox(height: 16),
                _buildTextInput(cell, "Cell Number", Icons.phone,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
                const SizedBox(height: 16),
                _buildTextInput(address, "Address", Icons.place),
                const SizedBox(height: 16),
                DateTimeFormField(
                  decoration: const InputDecoration(
                    labelText: "Date of Birth",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  mode: DateTimeFieldPickerMode.date,
                  pickerPlatform: dobPickerPlatform,
                  onChanged: (value) {
                    selectedDOB = value;
                  },
                ),
                const SizedBox(height: 16),
                _buildGenderRadio(),
                const SizedBox(height: 16),
                _buildImageUploadButton(),
                const SizedBox(height: 12),
                _buildImagePreview(),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    "Register",
                    style: GoogleFonts.lato(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ====================
  // === WIDGET HELPERS ==
  // ====================

  Widget _buildTextInput(
      TextEditingController controller,
      String label,
      IconData icon, {
        TextInputType keyboardType = TextInputType.text,
        List<TextInputFormatter>? inputFormatters,
        String? Function(String?)? validator,
      }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _buildPasswordInput(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      obscureText: _obscurePassword,
      validator: (value) =>
      value == null || value.isEmpty ? "Required field" : null,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.lock),
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
    );
  }

  Widget _buildGenderRadio() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Gender", style: TextStyle(fontWeight: FontWeight.bold)),
        v2.RadioGroup(
          controller: genderController,
          values: const ["Male", "Female", "Other"],
          indexOfDefault: 0,
          orientation: RadioGroupOrientation.horizontal,
          onChanged: (value) {
            selectedGender = value.toString();
          },
        ),
      ],
    );
  }

  Widget _buildImageUploadButton() {
    return TextButton.icon(
      onPressed: pickImage,
      icon: const Icon(Icons.image),
      label: const Text("Upload Image"),
    );
  }

  Widget _buildImagePreview() {
    if (kIsWeb && webImage != null) {
      return Image.memory(webImage!, height: 100, width: 100, fit: BoxFit.cover);
    } else if (!kIsWeb && selectedImage != null) {
      return Image.file(File(selectedImage!.path),
          height: 100, width: 100, fit: BoxFit.cover);
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName:
            Text(name.text.isEmpty ? 'Guest User' : name.text),
            accountEmail:
            Text(email.text.isEmpty ? 'guest@example.com' : email.text),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage: (kIsWeb && webImage != null)
                  ? MemoryImage(webImage!)
                  : (!kIsWeb && selectedImage != null)
                  ? FileImage(File(selectedImage!.path))
                  : null,
              child: (webImage == null && selectedImage == null)
                  ? const Icon(Icons.person, size: 50, color: Colors.grey)
                  : null,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () => Navigator.pop(context),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  // ======================
  // === FUNCTION HELPERS ==
  // ======================

  Future<void> pickImage() async {
    if (kIsWeb) {
      final imageBytes = await ImagePickerWeb.getImageAsBytes();
      if (imageBytes != null) {
        setState(() => webImage = imageBytes);
      }
    } else {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() => selectedImage = pickedFile);
      }
    }
  }

  void _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (password.text != confirmPassword.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match!')),
      );
      return;
    }

    if ((kIsWeb && webImage == null) ||
        (!kIsWeb && selectedImage == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image')),
      );
      return;
    }

    final user = {
      "name": name.text,
      "email": email.text,
      "phone": cell.text,
      "password": password.text
    };

    final manager = {
      "name": name.text,
      "email": email.text,
      "phone": cell.text,
      "gender": selectedGender ?? "Other",
      "address": address.text,
      "dateOfBirth": selectedDOB?.toIso8601String() ?? "",
    };

    final apiService = AuthService();
    bool success = false;

    if (kIsWeb && webImage != null) {
      success = await apiService.registerManagerWeb(
        user: user,
        manager: manager,
        photoBytes: webImage!,
      );
    } else if (selectedImage != null) {
      success = await apiService.registerManagerWeb(
        user: user,
        manager: manager,
        photoFile: File(selectedImage!.path),
      );
    }

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration Successful')),
      );
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email required';
    final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
    if (!emailRegex.hasMatch(value)) return 'Enter a valid email';
    return null;
  }
}
