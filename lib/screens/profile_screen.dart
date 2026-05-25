import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth/login_screen.dart';
import 'auth/logout_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoggedIn = false;
  String _userName = 'Guest User';
  String _userEmail = 'Please sign in to access your account';
  String _userPhone = '';
  String _userRole = '';

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
        _userName = prefs.getString('user_name') ?? 'User';
        _userEmail = prefs.getString('user_email') ?? '';
        _userPhone = prefs.getString('user_phone') ?? '';
        _userRole = prefs.getString('user_role') ?? '';
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
        actions: [
          if (_isLoggedIn)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProfileScreen(
                      userName: _userName,
                      userEmail: _userEmail,
                      userPhone: _userPhone,
                    ),
                  ),
                ).then((_) => _loadUserData());
              },
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile header
          Center(
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.green, width: 3),
                      ),
                      child: CircleAvatar(
                        radius: 48,
                        backgroundColor: Colors.green,
                        child: Text(
                          _isLoggedIn && _userName != 'Guest User'
                              ? _userName.substring(0, 1).toUpperCase()
                              : 'U',
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    if (_isLoggedIn)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditProfileScreen(
                                  userName: _userName,
                                  userEmail: _userEmail,
                                  userPhone: _userPhone,
                                ),
                              ),
                            ).then((_) => _loadUserData());
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.green, width: 2),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              size: 20,
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ),
                  ],
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
                if (_isLoggedIn && _userPhone.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    _userPhone,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
                if (_isLoggedIn && _userRole.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: _userRole == 'bulk' ? Colors.orange.shade50 : Colors.green.shade50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _userRole == 'bulk' ? 'Bulk Seller' : 'Immediate Buyer',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _userRole == 'bulk' ? Colors.orange.shade700 : Colors.green.shade700,
                      ),
                    ),
                  ),
                ],
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
                ).then((_) => _loadUserData());
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProfileScreen(
                      userName: _userName,
                      userEmail: _userEmail,
                      userPhone: _userPhone,
                    ),
                  ),
                ).then((_) => _loadUserData());
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
                _showComingSoon(context, 'Delivery Address');
              } else {
                _showLoginRequired(context);
              }
            },
          ),
          
          _buildMenuItem(
            Icons.lock_outline,
            'Change Password',
            onTap: () {
              if (_isLoggedIn) {
                _showComingSoon(context, 'Change Password');
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
                _showComingSoon(context, 'Order History');
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
                _showComingSoon(context, 'Favorites');
              } else {
                _showLoginRequired(context);
              }
            },
          ),
          
          _buildMenuItem(
            Icons.settings_outlined,
            'Settings',
            onTap: () {
              _showComingSoon(context, 'Settings');
            },
          ),
          
          _buildMenuItem(
            Icons.help_outline,
            'Help & Support',
            onTap: () {
              _showHelpDialog();
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
                ).then((_) => _loadUserData());
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
              Navigator.pop(context);
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

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature - Coming Soon'),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & Support'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('📞 Phone: +256 123 456 789'),
            SizedBox(height: 8),
            Text('📧 Email: support@ankorefresh.com'),
            SizedBox(height: 8),
            Text('💬 WhatsApp: +256 123 456 789'),
            SizedBox(height: 16),
            Text(
              'Business Hours:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('Monday - Friday: 8am - 6pm'),
            Text('Saturday: 9am - 4pm'),
            Text('Sunday: Closed'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}