import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class EmailSender {
  static Future<void> sendVerificationEmail({
    required String recipientEmail,
    required String verificationCode,
  }) async {
    // SMTP server configuration (for Gmail)
    final smtpServer = gmail('darksyami@gmail.com', 'Im771884062Higa@');

    // Create the email message
    final message = Message()
      ..from = Address('darksyami@gmail.com', 'Your App Name')
      ..recipients.add(recipientEmail) // Recipient email
      ..subject = 'Verification Code' // Email subject
      ..text = 'Your verification code is: $verificationCode'; // Email body

    try {
      // Send the email
      await send(message, smtpServer);
      print('Email sent successfully');
    } catch (e) {
      print('Failed to send email: $e');
    }
  }
}