import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:public_lookupp/components/custom_button.dart';
import 'package:public_lookupp/components/dynamic_textfield.dart';
import 'package:public_lookupp/services/auth.dart';
import 'package:public_lookupp/components/dropdown.dart';
import 'package:public_lookupp/toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// This class is a StatelessWidget that builds the UI for the sign up page.
class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  SignupPageState createState() => SignupPageState();
}

class SignupPageState extends State<SignupPage> {
// Initialize Firebase Auth from AuthService class
  final FirebaseAuthService _authService = FirebaseAuthService();

  // Initialize text controllers for email, password, and password confirmation.
  //
  // These controllers will be used to get the text input from the user.
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final passConfirmController = TextEditingController();
  final roleController = TextEditingController();

  // Initialize a boolean to check if the user is signed up
  bool isSignedUp = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    passConfirmController.dispose();
    roleController.dispose();
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
                    //TODO: logo to be added later, text for now
                    Text(
                      'Sign Up',
                      style: TextStyle(
                          fontSize: 50,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[900]),
                    ),
                    const Text(
                      'for LookUpp',
                      style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      "Create your account",
                      style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                    ),

                    const SizedBox(height: 25),

                    MyTextField(
                      controller: nameController,
                      hintText: 'Name',
                      obscureText: false,
                    ),

                    const SizedBox(height: 20),

                    //role field
                    RoleDropdownMenu(controller: roleController),

                    const SizedBox(height: 20),

                    //email field
                    MyTextField(
                      controller: emailController,
                      hintText: 'Email',
                      obscureText: false,
                    ),

                    const SizedBox(height: 20),

                    //password field
                    MyTextField(
                      controller: passwordController,
                      hintText: 'Password',
                      obscureText: true,
                    ),

                    const SizedBox(height: 10),

                    //password field
                    MyTextField(
                      controller: passConfirmController,
                      hintText: 'Confirm Password',
                      obscureText: true,
                    ),

                    const SizedBox(height: 25),

                    //sign in button
                    isSignedUp
                        ? CircularProgressIndicator(
                            color: Colors.blue[900]) // Spinner when loading
                        : MyButton(buttonText: 'Sign Up', onTap: signUp),

                    const SizedBox(height: 25),

                    //sign up
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account?',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        TextButton(
                          style: ButtonStyle(
                            foregroundColor:
                                WidgetStateProperty.all<Color>(Colors.blue),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Log In'),
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

  void signUp() async {
    setState(() {
      isSignedUp = true;
    });

    String email = emailController.text;
    String password = passwordController.text;
    String passConfirm = passConfirmController.text;

    if (nameController.text.isEmpty) {
      showToast(message: 'Please enter your name', backgroundColor: Colors.red);
      setState(() {
        isSignedUp = false;
      });
      return;
    }

    if (emailController.text.contains('@') == false ||
        emailController.text.contains('.') == false) {
      showToast(
          message: 'Please enter a valid email', backgroundColor: Colors.red);
      setState(() {
        isSignedUp = false;
      });
      return;
    }

    if (roleController.text.isEmpty) {
      showToast(message: 'Please select a role', backgroundColor: Colors.red);
      setState(() {
        isSignedUp = false;
      });
      return;
    }

    if (passwordController.text.isEmpty) {
      showToast(
          message: 'Please enter a password', backgroundColor: Colors.red);
      setState(() {
        isSignedUp = false;
      });
      return;
    }

    if (password != passConfirm) {
      showToast(message: "Passwords do not match", backgroundColor: Colors.red);
      setState(() {
        isSignedUp = false;
      });
      return;
    }

    User? user = await _authService.signUpWithEmailAndPassword(email, password);

    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'name': nameController.text,
        'role': roleController.text,
        'currentPoints': 0,
        'totalPoints': 0,
        'email': email,
      });
    }

    setState(() {
      isSignedUp = false;
    });
    if (user != null) {
      showToast(
          message: "User is succcesfully created",
          backgroundColor: Colors.green);
      if (!context.mounted) return;
      Navigator.pop(context);
    } else {
      showToast(
          message: "User is not created. Check all fields.",
          backgroundColor: Colors.red);
    }
  }
}
