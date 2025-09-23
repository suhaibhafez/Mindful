import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();

  String _enteredEmail = '';
  String _enteredPassword = '';
  String _tempPassword = '';

  bool _isLogin = true;
  bool _isAuthenticating = false;
  void onSubmit() async {
    final isValid = _formKey.currentState!.validate();
    if (isValid) {
      _formKey.currentState!.save();
      try {
        setState(() {
          _isAuthenticating = true;
        });
        if (_isLogin) {
          await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: _enteredEmail,
            password: _enteredPassword,
          );
        } else {
          final userCredential = await FirebaseAuth.instance
              .createUserWithEmailAndPassword(
                email: _enteredEmail,
                password: _enteredPassword,
              );
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userCredential.user!.uid)
              .set({
                'email': _enteredEmail,
                'password': _enteredPassword,
                'created at': Timestamp.now(),
              });
        }
      } on FirebaseAuthException catch (error) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.message ?? "Authentication failed"),

            duration: const Duration(seconds: 3),
          ),
        );
      } finally {
        setState(() {
          _isAuthenticating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Mindful"),
        leading: Image.asset(
          'assets/images/logo.png',
          height: 30,
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(16),
            constraints: const BoxConstraints(maxWidth: 500),
            child: Center(
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    spacing: 20,
                    children: [
                      TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        autofocus: true,
                        
                        decoration: const InputDecoration(
                          
                          labelText: 'Email',
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.trim().isEmpty ||
                              !(value.contains('@') && value.contains('.'))) {
                            return "Please write a valid email";
                          }
                          return null;
                        },
                        onSaved: (newValue) {
                          _enteredEmail = newValue!;
                        },
                        onFieldSubmitted: (_) => onSubmit(),
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Password',
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null ||
                              value.trim().isEmpty ||
                              value.trim().length < 5) {
                            return "Please write a valid password";
                          }
                          _tempPassword = value;
                          return null;
                        },

                        onSaved: (newValue) {
                          _enteredPassword = newValue!;
                        },
                        onFieldSubmitted: (_) => onSubmit(),
                      ),
                      if (!_isLogin)
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Confirm Password',
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty ||
                                value.trim().length < 5) {
                              return "Please write a valid password";
                            }
                            if (value != _tempPassword) {
                              return 'Password doesnt match';
                            }
                            return null;
                          },

                          onFieldSubmitted: (_) => onSubmit(),
                        ),
                      _isAuthenticating
                          ? CircularProgressIndicator(
                              color: Theme.of(context).colorScheme.onPrimary,
                            )
                          : ElevatedButton(
                              onPressed: onSubmit,
                              child: Text(_isLogin ? 'Log in' : 'Sign up'),
                            ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _isLogin = !_isLogin;
                            _formKey.currentState!.reset();
                          });
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _isLogin
                                  ? 'Dont have an account yet? '
                                  : 'Already have an account? ',
                            ),
                            Text(
                              _isLogin ? 'Sign up' : 'Log in',
                              style:const TextStyle(
                                decoration: TextDecoration.underline,
                                decorationThickness: 0.5,
                              ),
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
        ),
      ),
    );
  }
}
