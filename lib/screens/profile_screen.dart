import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth/login_screen.dart'; // Add this import for navigation
import 'auth/logout_screen.dart';

class ProfileScreen extends StatefulWidget { // Changed to StatefulWidget to handle user data
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoggedIn = false;
  String _userName = 'Guest User';
  String _userEmail = 'Please sign in to access your account';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isLoggedIn = prefs.getBool('is_logged_in') ?? false;
      if (_isLoggedIn) {
        _userName = prefs.getString('user_name') ?? 'John Doe';
        _userEmail = prefs.getString('user_email') ?? 'john.doe@email.com';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile header
          Center(
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.green, width: 3),
                  ),
                  child: const CircleAvatar(
                    radius: 48,
                    backgroundColor: Colors.green,
                    child: Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _userName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _userEmail,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // If not logged in, show sign in button
          if (!_isLoggedIn) ...[
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                ).then((_) => _loadUserData()); // Reload data when returning
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.login),
                  SizedBox(width: 8),
                  Text('Sign In to Your Account'),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          // Menu items
          _buildMenuItem(
            Icons.person_outline,
            'Personal Information',
            onTap: () {
              if (_isLoggedIn) {
                // Navigate to personal info screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Personal Information - Coming Soon')),
                );
              } else {
                _showLoginRequired(context);
              }
            },
          ),
          
          _buildMenuItem(
            Icons.location_on_outlined,
            'Delivery Address',
            onTap: () {
              if (_isLoggedIn) {
                // Navigate to addresses screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Delivery Address - Coming Soon')),
                );
              } else {
                _showLoginRequired(context);
              }
            },
          ),
          
          _buildMenuItem(
            Icons.payment_outlined,
            'Payment Methods',
            onTap: () {
              if (_isLoggedIn) {
                // Navigate to payment methods screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Payment Methods - Coming Soon')),
                );
              } else {
                _showLoginRequired(context);
              }
            },
          ),
          
          _buildMenuItem(
            Icons.history_outlined,
            'Order History',
            onTap: () {
              if (_isLoggedIn) {
                // Navigate to order history screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Order History - Coming Soon')),
                );
              } else {
                _showLoginRequired(context);
              }
            },
          ),
          
          _buildMenuItem(
            Icons.favorite_outline,
            'Favorites',
            onTap: () {
              if (_isLoggedIn) {
                // Navigate to favorites screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Favorites - Coming Soon')),
                );
              } else {
                _showLoginRequired(context);
              }
            },
          ),
          
          _buildMenuItem(
            Icons.settings_outlined,
            'Settings',
            onTap: () {
              // Settings can be accessed even when not logged in
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings - Coming Soon')),
              );
            },
          ),
          
          // Logout button (only show if logged in)
          if (_isLoggedIn) ...[
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LogoutScreen()),
                ).then((_) => _loadUserData()); // Reload data when returning
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout),
                  SizedBox(width: 8),
                  Text('Logout'),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, {required VoidCallback onTap}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.green),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade600),
        onTap: onTap,
      ),
    );
  }

  void _showLoginRequired(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login Required'),
        content: const Text('Please sign in to access this feature.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              ).then((_) => _loadUserData());
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.green,
            ),
            child: const Text('Sign In'),
          ),
        ],
      ),
    );
  }
}