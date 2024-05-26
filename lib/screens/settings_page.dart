import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:speed_scroll/providers/theme_provider.dart';
import 'package:speed_scroll/screens/about_app.dart';
import 'package:speed_scroll/screens/auth.dart';
import 'package:speed_scroll/screens/profile_page.dart';
import 'package:speed_scroll/screens/reset_password.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

   @override
     State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final _firebase = FirebaseAuth.instance;
  var _isSgignoutLoading = false;

  Future<void> _signOut() async {
    try {
      setState(() {
        _isSgignoutLoading = true;
      });

      await _firebase.signOut();

      //also sign out the user if is sign in with google

      if (_firebase.currentUser == null) {
        await _googleSignIn.signOut();
      }
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const AuthScreen(),
        ),
      );
    } catch (error) {
      setState(() {
        _isSgignoutLoading = false;
      });
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.toString(),
          ),
        ),
      );
    }
  }
  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
          TextButton(
            child: const Text('Logout'),
            onPressed: () {
              Navigator.of(ctx).pop();
              _signOut(); //logout operation
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
        children: [
          _buildSectionHeader('General'),
          _buildListItem(Icons.language, 'Language', () {
            
          }),
          _buildListItem(Icons.color_lens, 'Theme', () {
               Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
            
          }),
          const Divider(),
          _buildSectionHeader('Account'),
          _buildListItem(Icons.person, 'Profile', () {
            //sonra aktive edilecek şu an içi boş
            /*Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfilePage(),
                  ),
                );*/

          }),
          _buildListItem(Icons.lock, 'Change Password', () {
            //Change password kısmını reset passworde yönlendirdim
            Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ResetPasswordScreen(),
                  ),
                );
          }),
          const Divider(),
          _buildSectionHeader('About'),
          _buildListItem(Icons.info, 'About App', () {
            Navigator.push(context,
             MaterialPageRoute(
              builder: (context) => const AboutApp())
             );
          }),
          const Divider(),
          _buildListItem(Icons.logout, 'Log out', () { 
            _confirmDelete(context);
          })
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.bold,
          color: Color.fromRGBO(82, 170, 94, 1.0),
        ),
      ),
    );
  }

  Widget _buildListItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: onTap,
    );
  }
}