import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // returns the currently logged in user, null if no one is logged in
  User? get currentUser => _auth.currentUser;

  // login with email and password
  // returns the role string: "student" or "employee"
  // throws an error if login fails
  Future<void> register({
  required String name,
  required String email,
  required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = credential.user!.uid;

    await _firestore.collection('users').doc(uid).set({
      'name': name,
      'email': email,
      'role': 'student',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
  Future<String> login(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = credential.user!.uid;
    final doc = await _firestore.collection('users').doc(uid).get();
    final role = doc.data()!['role'] as String;

    return role;
  }
  
  Future<String?> getUserRole() async {
    final user = _auth.currentUser;

    if (user == null) return null;

    final doc = await _firestore
        .collection('users')
        .doc(user.uid)
        .get();

    if (!doc.exists) return null;

    return doc.data()!['role'] as String;
  }


  // logout
  Future<void> logout() async {
    await _auth.signOut();
  }
}