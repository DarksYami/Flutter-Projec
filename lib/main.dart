import 'package:flutter/material.dart';
import 'package:flutter_application_1/view/home_page.dart';
import 'package:flutter_application_1/view/login_page.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: FutureBuilder(
            future: _checkLoginStatus(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              return snapshot.data ?? const LoginPage();
            },
          ),
        );
      },
    );
  }

  static Future<Widget> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('id');
    final userEmail = prefs.getString('email');
    print(userEmail);
    // Check if both ID and email exist
    if (userId != null && userEmail != null) {
      return HomePage();
    }
    return const LoginPage();
  }
}