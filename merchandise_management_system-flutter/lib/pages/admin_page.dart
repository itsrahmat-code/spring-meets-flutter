import 'package:flutter/material.dart';
import 'package:merchandise_management_system/pages/login_page.dart';
import 'package:merchandise_management_system/service/authservice.dart';

class AdminPage extends StatelessWidget {
  final Map<String, dynamic> profile;
  final AuthService _authService = AuthService();

  AdminPage({Key? key, required this.profile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String baseUrl = "http://localhost:8085/images/roleAdmin/";
    final String? photoName = profile['photo'];
    final String? photoUrl = (photoName != null && photoName.isNotEmpty)
        ? "$baseUrl$photoName"
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // ✅ Back button logic
          },
        ),
      ),

      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.deepPurpleAccent,
              ),
              accountName: Text(
                profile['name'] ?? 'Unknown User',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              accountEmail: Text(profile['user']?['email'] ?? 'N/A'),
              currentAccountPicture: CircleAvatar(
                backgroundImage: (photoUrl != null)
                    ? NetworkImage(photoUrl)
                    : const AssetImage('assets/default_avatar.jpg')
                as ImageProvider,
              ),
            ),

            Expanded(
              child: ListView(
                children: [
                  _buildDrawerItem(
                    icon: Icons.person,
                    title: 'My Profile',
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.group,
                    title: 'View Buyers',
                    onTap: () {
                      // TODO: Navigate to View Buyers
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.add_box,
                    title: 'Save Cut Bundle',
                    onTap: () {
                      // TODO: Navigate to Save Cut Bundle
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.list_alt,
                    title: 'View Cut Bundle',
                    onTap: () {
                      // TODO: Navigate to View Cut Bundle
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.cut,
                    title: 'View Cutting Plans',
                    onTap: () {
                      // TODO: Navigate to View Cutting Plans
                    },
                  ),
                  const Divider(),
                  _buildDrawerItem(
                    icon: Icons.logout,
                    title: 'Logout',
                    iconColor: Colors.deepOrange,
                    textColor: Colors.deepOrange,
                    onTap: () async {
                      await _authService.logout();
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => LoginPage()),
                            (route) => false,
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // 🟣 Profile Photo
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.deepPurple, width: 3),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 5),
                  ),
                ],
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

            // 🟣 Admin Name
            Text(
              profile['name'] ?? 'Admin Name',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 8),

            // 🟣 Email
            Text(
              profile['user']?['email'] ?? 'admin@example.com',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),

            const SizedBox(height: 30),

            // 🟣 Section Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.deepPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Admin Tools',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.deepPurple,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // 🔧 Action Buttons (Optional Future Use)
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildActionButton('View Buyers', Icons.group),
                _buildActionButton('Save Bundle', Icons.save),
                _buildActionButton('Cutting Plans', Icons.cut),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Reusable Drawer Item
  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color iconColor = Colors.black87,
    Color textColor = Colors.black,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(
        title,
        style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
      ),
      onTap: onTap,
    );
  }

  // 🔹 Optional Action Buttons in main body (can link to features)
  Widget _buildActionButton(String label, IconData icon) {
    return ElevatedButton.icon(
      onPressed: () {
        // TODO: Define action
      },
      icon: Icon(icon, color: Colors.white),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
