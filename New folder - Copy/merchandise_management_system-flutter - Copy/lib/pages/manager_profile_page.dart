// File: lib/pages/manager_profile_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ManagerProfilePage extends StatelessWidget {
  final Map<String, dynamic> profile;

  const ManagerProfilePage({Key? key, required this.profile}) : super(key: key);

  // Helper function to format the date
  String _formatDate(dynamic date) {
    try {
      DateTime parsedDate;
      if (date is String) {
        parsedDate = DateTime.parse(date);
      } else if (date is DateTime) {
        parsedDate = date;
      } else {
        return 'N/A';
      }
      return DateFormat('yyyy-MM-dd').format(parsedDate);
    } catch (e) {
      return 'N/A';
    }
  }

  // Helper widget to build a single row of information
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.deepPurple),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Text(
              "$label:",
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // --- Data Extraction ---
    final String baseUrl = "http://localhost:8085/images/roleManager/";
    final String? photoName = profile['photo'];
    final String? photoUrl =
    (photoName != null && photoName.isNotEmpty) ? "$baseUrl$photoName" : null;

    final int id = profile['id'] ?? 0;
    final String name = profile['name'] ?? 'N/A';
    final String email = profile['email'] ?? 'N/A';
    final String phone = profile['phone'] ?? 'N/A';
    final String gender = profile['gender'] ?? 'N/A';
    final String address = profile['address'] ?? 'N/A';
    final String dateOfBirth = profile['dateOfBirth'] != null
        ? _formatDate(profile['dateOfBirth'])
        : 'N/A';
    // -----------------------

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // --- Profile Picture Section ---
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 5),
                  ),
                ],
                border: Border.all(
                  color: Colors.deepPurple,
                  width: 3,
                ),
              ),
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey[200],
                backgroundImage: (photoUrl != null)
                    ? NetworkImage(photoUrl)
                    : const AssetImage('assets/default_avatar.png')
                as ImageProvider,
              ),
            ),
            const SizedBox(height: 20),

            // --- Name and Email ---
            Text(
              name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              email,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 24),

            // --- Info Card ---
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 16.0),
                child: Column(
                  children: [
                    _buildInfoRow(Icons.badge, "ID", id.toString()),
                    _buildInfoRow(Icons.phone, "Phone", phone),
                    _buildInfoRow(Icons.person, "Gender", gender),
                    _buildInfoRow(Icons.home, "Address", address),
                    _buildInfoRow(Icons.cake, "Date of Birth", dateOfBirth),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}