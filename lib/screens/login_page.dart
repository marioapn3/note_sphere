import 'package:flutter/material.dart';
import 'package:note_sphere/auth/loading_page.dart';
import 'package:note_sphere/auth/main_page.dart';
import 'package:note_sphere/data/auth_data.dart';
import 'package:note_sphere/utils/colors.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback show;
  const LoginPage(this.show, {super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FocusNode _focusNode1 = FocusNode();
  final FocusNode _focusNode2 = FocusNode();

  final email = TextEditingController();
  final password = TextEditingController();

  @override
  void initState() {
    super.initState();
    _focusNode1.addListener(() {
      setState(() {});
    });
    _focusNode2.addListener(() {
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
                  'Login',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                // Continue with Google
                const SizedBox(height: 16),
                // Continue with Apple
                const SizedBox(height: 24),
                // Email TextField
                textField(email, _focusNode1, 'Email', Icons.email),
                const SizedBox(height: 16),
                // Password TextField
                textField(password, _focusNode2, 'Password', Icons.lock),
                const SizedBox(height: 8),
                // Forgot password

                const SizedBox(height: 24),
                // Log In button
                loginButton(),
                const SizedBox(height: 24),
                // Sign Up
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account?",
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: widget.show,
                      child: Text(
                        'Sign Up',
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

  Widget socialButton(String text, String assetPath) {
    return ElevatedButton.icon(
      onPressed: () {},
      icon: Image.asset(assetPath, height: 24),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        minimumSize: const Size(double.infinity, 50),
        side: const BorderSide(color: Colors.grey),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
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

  Widget loginButton() {
    return ElevatedButton(
      onPressed: () {
        AuthenticationRemote().login(email.text, password.text);
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
        'Log In',
        style: TextStyle(fontSize: 18, color: Colors.white),
      ),
    );
  }
}
