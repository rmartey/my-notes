// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'dart:developer' as devtools show log;

import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/services/auth/auth_exceptions.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/utilities/show_error_dialog.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: Column(
        children: [
          TextField(
            keyboardType: TextInputType.emailAddress,
            controller: _email,
            decoration:
                const InputDecoration(hintText: "Please enter your email"),
          ),
          TextField(
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
            controller: _password,
            decoration:
                const InputDecoration(hintText: "Please enter your password"),
          ),
          TextButton(
            onPressed: () async {
              final email = _email.text;
              final password = _password.text;

              try {
                final userCredential = await AuthService.firebase().createUser(
                  email: email,
                  password: password,
                );
                // final user = AuthService.firebase().currentUser;
                await AuthService.firebase().sendEmailVerification();
                Navigator.of(context).pushNamed(verifyEmailRoute);
                devtools.log(userCredential.toString());
              } on WeakPasswordAuthException {
                await showErrorDialog(context, "Weak password");
              } on EmailAlreadyInUseAuthException {
                await showErrorDialog(context, "Email already in use");
              } on InvalidEmailAuthException {
                await showErrorDialog(context, "Invalid email");
              } on GenericAuthException {
                await showErrorDialog(context, "Failed to register");
              }
            },
            child: const Text(
              "Register",
              style: TextStyle(fontSize: 22),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil(
                loginRoute,
                (route) => false,
              );
            },
            child: const Text("Already registered? Login here"),
          )
        ],
      ),
    );
  }
}
