// ignore_for_file: camel_case_types

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:note_sphere/auth/auth_page.dart';
import 'package:note_sphere/data/note_tree_view.dart';
import 'package:note_sphere/screens/main/note_tree_view_screen.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return NoteApp();
          } else {
            return const AuthPage();
          }
        },
      ),
    );
  }
}
