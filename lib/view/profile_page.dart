import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/users_api.dart';
import 'package:flutter_application_1/view/users_dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/view/login_page.dart';  // Import the LoginPage

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? email;
  int? id;
  String? isAdmin;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      email = prefs.getString('email');
      id = prefs.getInt('id');
      isAdmin = prefs.getString('isAdmin');
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('email');
    await prefs.remove('id');
    await prefs.remove('isAdmin');

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (email != null && id != null)
              Column(
                children: [
                  Text(
                    'Email: $email',
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'ID: $id',
                    style: const TextStyle(fontSize: 20),
                  ),
                  Text(
                    'You Are an/a : $isAdmin',
                    style: const TextStyle(fontSize: 20),
                  ),
                ],
              )
            else
              const Text(
                'No user data found.',
                style: TextStyle(fontSize: 20),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _logout,
              child: const Text('Logout'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed:() => {
                deleteUser(id!),
                _logout()
              },
              child: const Text('Delete Account',style: TextStyle(color: Colors.red),),
            ),
              const SizedBox(height: 20),
            if(isAdmin == "Admin")
              ElevatedButton(
                onPressed:()=>{
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => UserManagementDashboard()),
                  )
                } ,
                child: const Text('Dashboard'),
              ),
          ],
        ),
      ),
    );
  }
}
