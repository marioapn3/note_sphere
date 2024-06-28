import 'package:firebase_auth/firebase_auth.dart';
import 'package:note_sphere/data/firestore_datastore.dart';

abstract class AuthenticationDatasource {
  Future<void> register(
      String email, String password, String namaLengkap, String nomorHandphone);
  Future<void> login(String email, String password);
}

class AuthenticationRemote extends AuthenticationDatasource {
  final FirestoreDatastore _firestoreDatasource = FirestoreDatastore();

  @override
  Future<void> login(String email, String password) async {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(), password: password.trim());
  }

  bool _isValidEmail(String email) {
    // Simple regex for email validation
    String emailPattern =
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&\'*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+";
    RegExp regExp = RegExp(emailPattern);
    return regExp.hasMatch(email);
  }

  @override
  Future<void> register(String email, String password, String namaLengkap,
      String nomorHandphone) async {
    if (!_isValidEmail(email)) {
      throw FirebaseAuthException(
          code: 'invalid-email',
          message: 'The email address is badly formatted.');
    }

    try {
      // First, create the user with FirebaseAuth
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: email.trim(), password: password.trim());

      // Ensure that the user is signed in
      User? user = userCredential.user;

      if (user != null) {
        // Now, store the user data in Firestore
        bool userCreated = await _firestoreDatasource.createUser(
          email,
          namaLengkap,
          nomorHandphone,
        );

        if (userCreated) {
          // ignore: avoid_print
          print('User registered and data stored successfully');
        } else {
          // Handle the failure case if necessary
          throw Exception('Failed to store user data in Firestore');
        }
      } else {
        throw Exception('User is not signed in');
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error during registration: $e');
      rethrow; // Ensure the error is rethrown to handle it upstream if needed
    }

    // Explicitly return a Future<void>
    return;
  }
}
