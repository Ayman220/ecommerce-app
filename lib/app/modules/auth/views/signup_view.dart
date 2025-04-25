import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecommerce_app/app/modules/auth/controllers/auth_controller.dart';
import 'package:ecommerce_app/app/widgets/keyboard_dismisser.dart';
import 'package:ecommerce_app/app/components/inputs/custom_text_field.dart';
import 'package:ecommerce_app/app/components/buttons/primary_button.dart';

class SignupView extends GetView<AuthController> {
  const SignupView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).textTheme.titleLarge?.color,
      ),
      body: KeyboardDismisser(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Let\'s get started',
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create an account to continue shopping',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 32),
                  _buildNameField(),
                  const SizedBox(height: 16),
                  _buildEmailField(),
                  const SizedBox(height: 16),
                  _buildPasswordField(),
                  const SizedBox(height: 32),
                  _buildSignUpButton(),
                  const SizedBox(height: 16),
                  _buildLoginButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return CustomTextField(
      controller: controller.nameController,
      labelText: 'Full Name',
      prefixIcon: const Icon(Icons.person_outline),
      keyboardType: TextInputType.name,
      textCapitalization: TextCapitalization.words,
      textInputAction: TextInputAction.next,
    );
  }

  Widget _buildEmailField() {
    return CustomTextField(
      controller: controller.emailController,
      labelText: 'Email',
      prefixIcon: const Icon(Icons.email_outlined),
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      autofillHints: true,
      autofillHintsData: const [AutofillHints.email],
    );
  }

  Widget _buildPasswordField() {
    return Obx(
      () => CustomTextField(
        controller: controller.passwordController,
        obscureText: controller.obscureText.value,
        labelText: 'Password',
        helperText: 'Password must be at least 6 characters',
        prefixIcon: const Icon(Icons.lock_outline),
        textInputAction: TextInputAction.done,
        autofillHints: true,
        autofillHintsData: const [AutofillHints.newPassword],
        suffixIcon: IconButton(
          icon: Icon(
            controller.obscureText.value
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
          ),
          onPressed: controller.togglePasswordVisibility,
        ),
      ),
    );
  }

  Widget _buildSignUpButton() {
    return Obx(
      () => PrimaryButton(
        text: 'Create Account',
        onPressed: controller.signUp,
        isLoading: controller.isLoading.value,
      ),
    );
  }

  Widget _buildLoginButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Already have an account?',
          style: Get.textTheme.bodyMedium,
        ),
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('Sign In'),
        ),
      ],
    );
  }
}
