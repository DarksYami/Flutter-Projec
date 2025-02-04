import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/users_api.dart';
import 'package:flutter_application_1/view/change_forgot_pass.dart';
import 'dart:async';
import 'dart:math';

import 'package:flutter_application_1/view/login_page.dart';


class VerificationPage extends StatefulWidget {
  final String userEmail;
  final String? userPassword;
  final bool? isForgotPass;

  const VerificationPage({super.key, required this.userEmail,  this.userPassword, this.isForgotPass});

  @override
  _VerificationPageState createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  final TextEditingController _codeController = TextEditingController();
  late String _verificationCode;
  late Timer _timer;
  int _timeRemaining = 300; // 5 minutes in seconds
  bool _isCodeExpired = false;

  @override
  void initState() {
    super.initState();
    _generateVerificationCode();
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    _codeController.dispose();
    super.dispose();
  }

  void _generateVerificationCode() {
    final random = Random();
    _verificationCode = (10000 + random.nextInt(90000)).toString();
    // EmailSender.sendVerificationEmail(recipientEmail: 'senpaihiga@gmail.com', verificationCode:_verificationCode);
    print('Generated Code: $_verificationCode'); // For testing purposes
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeRemaining > 0) {
          _timeRemaining--;
        } else {
          _isCodeExpired = true;
          timer.cancel();
        }
      });
    });
  }

  Future<void> _verifyCode() async {
    if (_isCodeExpired) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Code has expired. Please request a new one.')),
      );
      return;
    }

    if (_codeController.text == _verificationCode) {
      try {
        if(widget.isForgotPass! == true){
          Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => ChangePasswordPage(email: widget.userEmail)),
          (route) => false,
        );
        return;
        }
        print("${widget.userEmail}");
        await addUser(widget.userEmail, widget.userPassword!, 0);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sign Up Successful, Now Login')),
        );
        
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
          (route) => false,
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to sign up. Please try again.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid code. Please try again.')),
      );
    }
  }

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainingSeconds';
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text('Verification'),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(screenWidth * 0.05),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'A 5-digit code has been sent to:\n${widget.userEmail}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Text(
              'Time Remaining: ${_formatTime(_timeRemaining)}',
              style: TextStyle(
                fontSize: 18,
                color: _isCodeExpired ? Colors.red : Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _codeController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Enter Code',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _verifyCode,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Verify',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: _isCodeExpired
                  ? () {
                      setState(() {
                        _generateVerificationCode();
                        _timeRemaining = 300;
                        _isCodeExpired = false;
                        _startTimer();
                      });
                    }
                  : null,
              child: Text(
                'Resend Code',
                style: TextStyle(
                  color: _isCodeExpired ? Colors.purple : Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}