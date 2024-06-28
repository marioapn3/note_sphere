// ignore_for_file: file_names, camel_case_types, non_constant_identifier_names, no_leading_underscores_for_local_identifiers

import 'package:flutter/material.dart';
import 'package:note_sphere/auth/loading_page.dart';
import 'package:note_sphere/data/auth_data.dart';
import 'package:note_sphere/utils/colors.dart';

class RegisterPage extends StatefulWidget {
  final VoidCallback show;
  const RegisterPage(this.show, {super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final FocusNode _focusNode1 = FocusNode();
  final FocusNode _focusNode2 = FocusNode();
  final FocusNode _focusNode3 = FocusNode();
  final FocusNode _focusNode4 = FocusNode();

  final email = TextEditingController();
  final password = TextEditingController();
  final namaLengkap = TextEditingController();
  final nomorHandphone = TextEditingController();

  @override
  void initState() {
    super.initState();
    _focusNode1.addListener(() {
      setState(() {});
    });
    _focusNode2.addListener(() {
      setState(() {});
    });
    _focusNode3.addListener(() {
      setState(() {});
    });
    _focusNode4.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Padding(
                    padding: const EdgeInsets.only(bottom: 40.0),
                    child: Text(
                      'NotteSphere',
                      style: TextStyle(
                        color: secondaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    )),
                // Title
                const Text(
                  'Sign Up',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                // Email TextField
                textField(email, _focusNode1, 'Email', Icons.email),
                const SizedBox(height: 16),
                // Password TextField
                textField(password, _focusNode2, 'Password', Icons.lock),
                const SizedBox(height: 16),
                // Nama Lengkap TextField
                textField(
                    namaLengkap, _focusNode3, 'Nama Lengkap', Icons.person),
                const SizedBox(height: 16),
                // Nomor Handphone TextField
                textField(nomorHandphone, _focusNode4, 'Nomor Handphone',
                    Icons.phone_android),
                const SizedBox(height: 24),
                // Sign Up button
                signUpButton(),
                const SizedBox(height: 24),
                // Login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Do you have an account?",
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: widget.show,
                      child: Text(
                        'Log In',
                        style: TextStyle(
                          color: secondaryColor,
                          fontSize: 14,
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
      ),
    );
  }

  Widget textField(TextEditingController controller, FocusNode focusNode,
      String hintText, IconData icon) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      decoration: InputDecoration(
        prefixIcon: Icon(icon,
            color: focusNode.hasFocus ? secondaryColor : Colors.grey),
        hintText: hintText,
        filled: true,
        fillColor: Colors.grey[200],
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.transparent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: secondaryColor),
        ),
      ),
    );
  }

  Widget signUpButton() {
    return ElevatedButton(
      onPressed: () {
        AuthenticationRemote().register(
            email.text, password.text, namaLengkap.text, nomorHandphone.text);

        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => LoadingPage(),
            ));
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: secondaryColor,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: const Text(
        'Sign Up',
        style: TextStyle(fontSize: 18, color: Colors.white),
      ),
    );
  }
}
