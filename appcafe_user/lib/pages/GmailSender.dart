import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class GmailSender {
  final String userEmail;
  final String appPassword;
  late final SmtpServer _smtpServer;

  GmailSender({
    required this.userEmail,
    required this.appPassword,
  }) {
    _smtpServer = gmail(userEmail, appPassword);
  }

  /// Gửi email
  Future<void> sendEmail({
    required String toEmail,
    required String subject,
    required String messageBody,
  }) async {
    final message = Message()
      ..from = Address(userEmail, 'CFPLUS App')
      ..recipients.add(toEmail)
      ..subject = subject
      ..text = messageBody;

    try {
      await send(message, _smtpServer);
      print('Gửi email thành công');
    } catch (e) {
      print('Lỗi gửi email: $e');
      rethrow;
    }
  }
}
