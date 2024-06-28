// ignore_for_file: camel_case_types

import 'package:flutter/material.dart';
import 'package:note_sphere/screens/login_page.dart';
import 'package:note_sphere/screens/register_page.dart';


class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool a = true;
  void to() {
    setState(() {
      a = !a;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (a) {
      return LoginPage(to);
    } else {
      return RegisterPage(to);
    }
  }
}
