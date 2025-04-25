import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class AuthService extends GetxService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Expose the auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  
  // Get the current user
  User? get currentUser => _auth.currentUser;

  // Initialize service
  Future<AuthService> init() async {
    return this;
  }

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword({
    required String email, 
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Create user with email and password
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    // Create the user
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    
    // Save additional user data to Firestore
    await _createUserInFirestore(
      uid: userCredential.user!.uid,
      email: email,
      name: name,
    );
    
    return userCredential;
  }

  // Create user document in Firestore
  Future<void> _createUserInFirestore({
    required String uid,
    required String email,
    required String name,
  }) async {
    await _firestore.collection('users').doc(uid).set({
      'name': name,
      'email': email,
      'createdAt': Timestamp.now(),
      'role': 'customer',
    });
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
  
  // Get user data from Firestore
  Future<DocumentSnapshot<Map<String, dynamic>>> getUserData(String uid) async {
    return await _firestore.collection('users').doc(uid).get();
  }
  
  // Update user profile
  Future<void> updateUserProfile({
    required String uid,
    String? name,
    String? phoneNumber,
    String? address,
  }) async {
    final Map<String, dynamic> data = {};
    
    if (name != null) data['name'] = name;
    if (phoneNumber != null) data['phoneNumber'] = phoneNumber;
    if (address != null) data['address'] = address;
    
    if (data.isNotEmpty) {
      await _firestore.collection('users').doc(uid).update(data);
    }
  }
  
  // Update user email
  Future<void> updateEmail({required String newEmail}) async {
    if (currentUser != null) {
      // Use verifyBeforeUpdateEmail instead of updateEmail
      await currentUser!.verifyBeforeUpdateEmail(newEmail);
      await _firestore.collection('users').doc(currentUser!.uid).update({
        'email': newEmail,
      });
    }
  }
  
  // Update user password
  Future<void> updatePassword({required String newPassword}) async {
    if (currentUser != null) {
      await currentUser!.updatePassword(newPassword);
    }
  }
}