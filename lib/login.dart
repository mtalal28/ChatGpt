import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'path_to_auth_service/auth_service.dart';

class MyLogin extends StatefulWidget {
  const MyLogin({Key? key}) : super(key: key);

  @override
  _MyLoginState createState() => _MyLoginState();
}

class _MyLoginState extends State<MyLogin> {
  final AuthService _authService = AuthService();
  bool _isGoogleSignInPopupOpen = false;

  Future<void> googleSignIn() async {
    try {
      if (_isGoogleSignInPopupOpen) {
        return; // Don't proceed if the popup is already open
      }
      _isGoogleSignInPopupOpen = true;

      FirebaseAuth auth = FirebaseAuth.instance;
      final GoogleSignIn googleSignIn0 = GoogleSignIn(
        scopes: [
          'https://www.googleapis.com/auth/drive',
        ],
      );
      await googleSignIn0.signIn();
      final GoogleSignInAccount? googleUser = await googleSignIn0.signIn();

      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final UserCredential userCredential = await auth.signInWithCredential(credential);
        print("User signed in with Google: ${userCredential.user?.displayName}");
      } else {
        print("Google Sign-In Cancelled");
      }
    } catch (error) {
      print("Google Sign-In Error: $error");
    } finally {
      _isGoogleSignInPopupOpen = false;
    }
  }

  String _email = '';
  String _password = '';

  // Function to handle the login button press
  void _login() async {
    if (_email.isNotEmpty && _password.isNotEmpty) {
      try {
        // Use _authService to handle login logic
        UserCredential? userCredential = await _authService.signInWithEmailAndPassword(_email, _password);

        if (userCredential != null && userCredential.user != null) {
          Navigator.pushNamed(context, '/home');
        } else {
          // Authentication failed, show an error message.
          print('Authentication failed');
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Login Failed'),
                content: const Text('Invalid email or password. Please try again.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          );
        }
      } catch (error) {
        // Handle other errors, e.g., network issues.
        print('Error during login: $error');
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Login Failed'),
              content: const Text('An error occurred during login. Please try again.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } else {
      print('Please enter valid email and password');
    }
  }

  bool _exitDialogShown = false; // Add this flag at the beginning of your _MyLoginState class.

  Future<bool> _onWillPop() async {
    // Check if the Google sign-in popup is open
    bool isGoogleSignInInProgress = false;

    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? account = await googleSignIn.signInSilently();
      isGoogleSignInInProgress = account != null;
    } catch (error) {
      print("Error checking Google sign-in status: $error");
    }

    if (isGoogleSignInInProgress) {
      // Dismiss the Google sign-in popup
      final GoogleSignIn googleSignIn = GoogleSignIn();
      await googleSignIn.signOut();
      return false; // Prevent app from exiting
    }

    if (_exitDialogShown) {
      // If the exit confirmation dialog was already shown, allow navigation to happen.
      return true;
    }

    // Show exit confirmation modal
    bool? shouldPop = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // Prevent tapping outside to dismiss
      builder: (context) {
        return WillPopScope(
          onWillPop: () async {
            // Handle back button press inside the dialog
            Navigator.of(context).pop(false); // Close the dialog
            return false; // Prevent further navigation
          },
          child: AlertDialog(
            title: Text('Exit App'),
            content: Text('Are you sure you want to exit?'),
            actions: <Widget>[
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: Text('No'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(true); // Close the dialog with "Yes"
                },
                child: Text('Yes'),
              ),
            ],
          ),
        );
      },
    );

    // Check the value of shouldPop to decide whether to exit
    if (shouldPop == true) {
      // Set the flag to true to allow navigation
      _exitDialogShown = true;
      Navigator.of(context).pop(true); // This will exit the app
    }

    // Return true to prevent further navigation when the dialog is dismissed.
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop, // Intercept back button press
      child: GestureDetector(
        onTap: () {
          // Handle taps outside the popup here, if needed
          if (_isGoogleSignInPopupOpen) {
            // Do something to close the popup or provide feedback to the user
          }
        },
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/screen b.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.only(left: 0.1, top: 130),
                    child: const Text(
                      'Welcome\nBack',
                      style: TextStyle(color: Colors.white, fontSize: 33),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(left: 15, top: 80),
                    child: const Text(
                      'Sign In',
                      style: TextStyle(color: Colors.white, fontSize: 33),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(
                      top: 90,
                      right: 35,
                      left: 35,
                    ),
                    child: Column(
                      children: [
                        TextField(
                          onChanged: (value) {
                            setState(() {
                              _email = value;
                            });
                          },
                          decoration: InputDecoration(
                            fillColor: Colors.grey.shade100,
                            filled: true,
                            hintText: 'Email',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        TextField(
                          onChanged: (value) {
                            setState(() {
                              _password = value;
                            });
                          },
                          obscureText: true,
                          decoration: InputDecoration(
                            fillColor: Colors.grey.shade100,
                            filled: true,
                            hintText: 'Password',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 35,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            CircleAvatar(
                              radius: 25,
                              backgroundColor: const Color(0xFFFFFFFF),
                              child: IconButton(
                                color: Colors.black,
                                onPressed: _login, // Call the login function
                                icon: const Icon(Icons.arrow_forward),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 40,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "If you don't have an Account ",
                              style: TextStyle(
                                fontSize: 17,
                                height: -1,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(context, 'register');
                              },
                              child: const Text(
                                'Sign Up',
                                style: TextStyle(
                                  fontSize: 17,
                                  height: -1,
                                  decoration: TextDecoration.underline,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(context, 'forget');
                              },
                              child: const Text(
                                'Forget Password',
                                style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  fontSize: 18,
                                  height: -1,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () async {
                                await googleSignIn();
                                print('After googleSignIn');
                                if (mounted) {
                                  print('hey buddy');
                                  Navigator.pushNamed(context, '/home');
                                } else {
                                  print('Widget not mounted');
                                }
                              },
                              icon: Image.asset(
                                'assets/g.png',
                                height: 32,
                                width: 32,
                              ),
                              label: const Text('Sign in with Google'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white, // Set background color
                                foregroundColor: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
