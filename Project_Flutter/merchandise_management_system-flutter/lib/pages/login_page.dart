import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:merchandise_management_system/pages/admin_page.dart';
import 'package:merchandise_management_system/pages/manager_page.dart';
import 'package:merchandise_management_system/pages/registration_page.dart';
import 'package:merchandise_management_system/pages/welcome_page.dart';
import 'package:merchandise_management_system/service/admin_service.dart';
import 'package:merchandise_management_system/service/authservice.dart';
import 'package:merchandise_management_system/service/manager_service.dart';

// --- Theme Definition (Optional but Recommended for Professionalism) ---
// You would ideally define this in your main Theme data, but for this file:
const Color kPrimaryColor = Color(0xFF673AB7); // Deep Purple
const Color kAccentColor = Color(0xFFE91E63); // Pink/Accent

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final storage = const FlutterSecureStorage();

  bool _obscurePassword = true;
  bool _isLoading = false; // Added for professional loading state

  final authService = AuthService();
  final managerService = ManagerService();
  final adminService = AdminService();

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> loginUser() async {
    if (_isLoading) return; // Prevent multiple taps

    setState(() {
      _isLoading = true; // Start loading
    });

    try {
      // Your existing login logic
      await authService.login(email.text, password.text);
      final role = await authService.getUserRole();

      if (role == 'ADMIN') {
        final profile = await adminService.getAdminProfile();
        if (profile != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AdminPage(profile: profile)),
          );
        }
      } else if (role == 'MANAGER') {
        final profile = await managerService.getManagerProfile();
        if (profile != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => ManagerPage(profile: profile)),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid role detected')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login Failed: $error')),
      );
    } finally {
      setState(() {
        _isLoading = false; // Stop loading
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // Allow body to go behind transparent AppBar
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white), // Changed icon color
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          /// Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/img/11.png', // Your background image path
              fit: BoxFit.cover,
            ),
          ),

          /// Semi-transparent dark overlay for better text contrast
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.4), // Darker overlay for professionalism
            ),
          ),

          /// Foreground content
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60), // Increased padding
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch the card
                children: [
                  const Text(
                    "Welcome Back!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Sign in to continue.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Card(
                    color: Colors.white, // Changed to pure white for better contrast
                    elevation: 12, // Higher elevation for a more prominent, professional look
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16), // Slightly rounder corners
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(28.0), // Increased internal padding
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            controller: email,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: "Email Address", // More professional label
                              hintText: "example@gmail.com",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              prefixIcon: const Icon(Icons.email_outlined, color: kPrimaryColor),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: kPrimaryColor, width: 2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: password,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: "Password",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              prefixIcon: const Icon(Icons.lock_outline, color: kPrimaryColor),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: kPrimaryColor, width: 2),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                  color: kPrimaryColor,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          ElevatedButton(
                            onPressed: _isLoading ? null : loginUser, // Disable button while loading
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kPrimaryColor, // Use defined primary color
                              foregroundColor: Colors.white,
                              minimumSize: const Size.fromHeight(50), // Slightly taller button
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 4,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                                : const Text(
                              "LOGIN", // Uppercase for emphasis
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Registration Link
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const Register(),
                                ),
                              );
                            },
                            child: RichText(
                              text: TextSpan(
                                text: "Don't have an account? ",
                                style: TextStyle(color: Colors.grey[700], fontSize: 14),
                                children: const [
                                  TextSpan(
                                    text: "Register Now",
                                    style: TextStyle(
                                      color: kAccentColor, // Use accent color
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Go to Welcome Page Button (Optional/Utility)
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const WelcomePage()),
                              );
                            },
                            child: const Text(
                              "Go back to Home Page",
                              style: TextStyle(
                                color: kPrimaryColor, // Use primary color
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}