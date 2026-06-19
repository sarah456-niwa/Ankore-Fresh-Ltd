// lib/screens/auth/verification_screen.dart
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'reset_password_screen.dart';

class VerificationScreen extends StatefulWidget {
  final String? email;
  final String? verificationType;
  
  const VerificationScreen({
    super.key,
    this.email,
    this.verificationType = 'password_reset',
  });

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  late List<TextEditingController> _otpControllers;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _otpControllers = List.generate(6, (index) => TextEditingController());
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _verifyCode() async {
    String otp = _otpControllers.map((c) => c.text).join();
    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the 6-digit verification code'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    final apiService = ApiService();
    
    try {
      final response = await apiService.post('password-reset/verify-code/', {
        'email': widget.email,
        'code': otp,
      });
      
      setState(() {
        _isLoading = false;
      });
      
      if (response['success']) {
        // Navigate to reset password screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResetPasswordScreen(
              email: widget.email!,
              code: otp,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Invalid verification code'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Network error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _resendCode() async {
    setState(() {
      _isLoading = true;
    });
    
    final apiService = ApiService();
    
    try {
      final response = await apiService.post('password-reset/forgot-password/', {
        'email': widget.email,
      });
      
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['message'] ?? 'New code sent!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to resend code'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPasswordReset = widget.verificationType == 'password_reset';
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isPasswordReset ? 'Reset Password' : 'Verify Email'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.green,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.mark_email_read,
                  size: 60,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 30),
              Text(
                isPasswordReset ? 'Reset Your Password' : 'Verify Your Email',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                isPasswordReset
                    ? 'We have sent a 6-digit verification code to:\n\n${widget.email}'
                    : 'We have sent a 6-digit verification code to your email',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              
              // OTP Input Fields
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) => 
                  SizedBox(
                    width: 50,
                    child: TextFormField(
                      controller: _otpControllers[index],
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      decoration: InputDecoration(
                        counterText: '',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.green, width: 2),
                        ),
                      ),
                      onChanged: (value) {
                        if (value.length == 1 && index < 5) {
                          FocusScope.of(context).nextFocus();
                        }
                      },
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _isLoading ? null : _verifyCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Verify Code',
                        style: TextStyle(fontSize: 18),
                      ),
              ),
              
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Didn't receive code? ",
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  TextButton(
                    onPressed: _isLoading ? null : _resendCode,
                    child: const Text(
                      'Resend',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}