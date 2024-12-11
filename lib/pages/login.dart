import 'package:flutter/material.dart';
import 'package:public_lookupp/components/dynamic_textfield.dart';
import 'package:public_lookupp/components/custom_button.dart';
import 'package:public_lookupp/pages/signup.dart';
import 'package:public_lookupp/services/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:public_lookupp/pages/state_page.dart';
import 'package:public_lookupp/toast.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isSignedIn = false;
  final FirebaseAuthService authService = FirebaseAuthService();
  final FirebaseAuth auth = FirebaseAuth.instance;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Scaffold(
          backgroundColor: Colors.grey[200],
          body: SingleChildScrollView(
            child: SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 100),
                    //logo
                    // to be added later, text for now
                    const Text(
                      'Lookupp',
                      style: TextStyle(
                          fontSize: 50,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue),
                    ),

                    const SizedBox(height: 75),

                    //email field
                    MyTextField(
                      controller: emailController,
                      hintText: 'Email',
                      obscureText: false,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 10),
                    //password field
                    MyTextField(
                      controller: passwordController,
                      hintText: 'Password',
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 10),
                    //forgot password
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'Forgot Password?',
                            style: TextStyle(color: Colors.grey[600]),
                            //TODO: implement forgot password
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),
                    //sign in button
                    isSignedIn
                        ? CircularProgressIndicator(
                            color: Colors.blue[900]) // Spinner when loading
                        : MyButton(
                            buttonText: 'Sign In',
                            onTap: signIn,
                          ),
                    const SizedBox(height: 50),
                    //sign up
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Don\'t have an account?',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        TextButton(
                          style: ButtonStyle(
                            foregroundColor:
                                WidgetStateProperty.all<Color>(Colors.blue),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const SignupPage()),
                            );
                          },
                          child: const Text('Sign Up'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          )),
    );
  }

  void signIn() async {
    setState(() {
      isSignedIn = true;
    });

    String email = emailController.text;
    String password = passwordController.text;

    User? user = await authService.signInWithEmailAndPassword(email, password);

    setState(() {
      isSignedIn = false;
    });

    if (user != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const StatePage()),
      );
    } else {
      showToast(
          message: "Error occurred. Check email and/or password.",
          backgroundColor: Colors.red);
    }
  }
}
