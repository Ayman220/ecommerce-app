import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/app/routes/app_pages.dart';
import 'package:ecommerce_app/app/components/notifications/custom_toast.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final isLoading = false.obs;
  final obscureText = true.obs;

  // Form controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();

  // User data
  final Rxn<User> currentUser = Rxn<User>();

  @override
  void onInit() {
    currentUser.bindStream(_auth.authStateChanges());
    ever(currentUser, _setInitialScreen);
    super.onInit();
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    super.onClose();
  }

  // Determine the initial screen based on auth state
  void _setInitialScreen(User? user) {
    if (user == null) {
      // User is not logged in
      if (Get.currentRoute != Routes.login &&
          Get.currentRoute != Routes.signup) {
        Get.offAllNamed(Routes.login);
      }
    } else {
      // User is logged in
      Get.offAllNamed(Routes.home);
    }
  }

  // Toggle password visibility
  void togglePasswordVisibility() => obscureText.value = !obscureText.value;

  // Sign in with email and password
  Future<void> signIn() async {
    if (!_validateLoginForm()) return;

    try {
      FocusScope.of(Get.context!).unfocus(); // Dismiss keyboard
      isLoading.value = true;
      await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      _clearControllers();
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
    } finally {
      isLoading.value = false;
    }
  }

  // Register with email and password
  Future<void> signUp() async {
    if (!_validateSignUpForm()) return;

    try {
      FocusScope.of(Get.context!).unfocus(); // Dismiss keyboard
      isLoading.value = true;
      // Create the user
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      // Save additional user data to Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'createdAt': Timestamp.now(),
      });

      _clearControllers();
      CustomToast.success('Account created successfully');
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
    } finally {
      isLoading.value = false;
    }
  }

  // Reset password
  Future<void> resetPassword() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      CustomToast.warning("Please enter your email");
      return;
    }

    if (!GetUtils.isEmail(email)) {
      CustomToast.warning("Please enter a valid email");
      return;
    }

    try {
      isLoading.value = true;
      await _auth.sendPasswordResetEmail(email: email);
      CustomToast.success(
          "Password reset email sent. Please check your inbox.");
      Get.back(); // Go back to login page
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
    } finally {
      isLoading.value = false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      CustomToast.error("Error signing out. Please try again.");
    }
  }

  // Form validation
  bool _validateLoginForm() {
    if (emailController.text.trim().isEmpty ||
        passwordController.text.isEmpty) {
      CustomToast.warning("Please fill all fields");
      return false;
    }

    if (!GetUtils.isEmail(emailController.text.trim())) {
      CustomToast.warning("Please enter a valid email");
      return false;
    }

    return true;
  }

  bool _validateSignUpForm() {
    if (nameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        passwordController.text.isEmpty) {
      CustomToast.warning("Please fill all fields");
      return false;
    }

    if (!GetUtils.isEmail(emailController.text.trim())) {
      CustomToast.warning("Please enter a valid email");
      return false;
    }

    if (passwordController.text.length < 6) {
      CustomToast.warning("Password must be at least 6 characters");
      return false;
    }

    return true;
  }

  // Handle Firebase auth errors
  void _handleAuthError(FirebaseAuthException e) {
    String message;
    switch (e.code) {
      case 'user-not-found':
        message = "No user found with this email.";
        break;
      case 'wrong-password':
        message = "Wrong password.";
        break;
      case 'invalid-credential':
        message = "Invalid credentials.";
        break;
      case 'email-already-in-use':
        message = "Email is already in use.";
        break;
      case 'invalid-email':
        message = "Email address is invalid.";
        break;
      case 'weak-password':
        message = "Password is too weak.";
        break;
      case 'operation-not-allowed':
        message = "Operation not allowed.";
        break;
      case 'too-many-requests':
        message = "Too many requests. Try again later.";
        break;
      default:
        message = "An error occurred. Please try again.";
        break;
    }

    CustomToast.error(message);
  }

  // Clear form controllers
  void _clearControllers() {
    emailController.clear();
    passwordController.clear();
    nameController.clear();
  }
}
