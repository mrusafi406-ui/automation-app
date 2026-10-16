import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _user;
  String? _role;
  String? _name;
  bool _isLoading = true;
  bool _isFirstLogin = false;

  User? get user => _user;
  String? get role => _role;
  String? get name => _name;
  bool get isLoading => _isLoading;
  bool get isFirstLogin => _isFirstLogin;

  AuthProvider() {
    _auth.authStateChanges().listen((User? user) async {
      _user = user;
      if (user != null) {
        await _fetchUserData(user.uid);
      } else {
        _role = null;
        _name = null;
        _isLoading = false;
      }
      notifyListeners();
    });
  }

  Future<void> _fetchUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        _role = data['role'];
        _name = data['name'];
        _isFirstLogin = data['isFirstLogin'] ?? false;
      }
    } catch (e) {
      debugPrint("Error fetching user data: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> signIn(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      if (e.code == 'user-not-found') return 'No user found for that email.';
      if (e.code == 'wrong-password') return 'Wrong password provided.';
      return 'An error occurred. Please try again.';
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
