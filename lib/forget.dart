import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyForget extends StatefulWidget {
  const MyForget({Key? key}) : super(key: key);

  @override
  State<MyForget> createState() => _MyForgetState();
}

class _MyForgetState extends State<MyForget> {
  TextEditingController forgotPasswordController = TextEditingController();
  bool isLoading = false; // Define and initialize isLoading here

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Password'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Enter your email to reset password',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  TextFormField(
                    controller: forgotPasswordController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (isLoading)
                    CircularProgressIndicator(
                      color: Colors.black,
                    ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      var forgotEmail = forgotPasswordController.text.trim();

                      try {
                        setState(() {
                          isLoading = true;
                        });

                        await FirebaseAuth.instance.sendPasswordResetEmail(
                          email: forgotEmail,
                        );

                        print('Email sent!');
                        Navigator.pushNamed(context, 'login');
                      } on FirebaseAuthException catch (e) {
                        print('Error $e');
                      } finally {
                        setState(() {
                          isLoading = false;
                        });
                      }
                    },
                    child: const Text('Reset Password'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
