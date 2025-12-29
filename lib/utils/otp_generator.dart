import 'dart:math';

String generateOTP() {
  final random = Random();
  int otp = random.nextInt(9000) + 1000; // 1000–9999
  print("Generated OTP: $otp"); // For debug, shows in console
  return otp.toString();
}
