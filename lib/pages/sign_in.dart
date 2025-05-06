import 'package:flutter/material.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';
import 'package:go_router/go_router.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3FF90), // Light yellow background
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Sign In",
          style: TextStyle(
            color: Colors.white, // White text
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF059212), // Dark green background color
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 100),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      SupaEmailAuth(
                        redirectTo: 'io.supabase.cornstalk://login-callback/',
                        onSignInComplete: (response) {
                          context.go('/home');
                        },
                        onSignUpComplete: (response) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Please check your email for verification."),
                            ),
                          );
                          context.go('/home');
                        },
                        metadataFields: [
                          MetaDataField(
                            prefixIcon: const Icon(Icons.person, color: Color(0xFF059212)),
                            label: 'Username',
                            key: 'username',
                            validator: (val) {
                              if (val == null || val.isEmpty) {
                                return 'Please enter something';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}