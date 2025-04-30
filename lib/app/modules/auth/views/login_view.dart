import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecommerce_app/app/modules/auth/controllers/auth_controller.dart';
import 'package:ecommerce_app/app/routes/app_pages.dart';
import 'package:ecommerce_app/app/widgets/keyboard_dismisser.dart';
import 'package:ecommerce_app/app/components/inputs/custom_text_field.dart';
import 'package:ecommerce_app/app/components/buttons/primary_button.dart';

class LoginView extends GetView<AuthController> {
  const LoginView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: KeyboardDismisser(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  Text(
                    'welcome_back'.tr,
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'sign_in'.tr,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 40),
                  _buildEmailField(),
                  const SizedBox(height: 16),
                  _buildPasswordField(),
                  const SizedBox(height: 16),
                  _buildForgotPassword(),
                  const SizedBox(height: 24),
                  _buildSignInButton(),
                  const SizedBox(height: 16),
                  _buildCreateAccountButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return CustomTextField(
      controller: controller.emailController,
      labelText: 'email'.tr,
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
        labelText: 'password'.tr,
        obscureText: controller.obscureText.value,
        prefixIcon: const Icon(Icons.lock_outline),
        textInputAction: TextInputAction.done,
        autofillHints: true,
        autofillHintsData: const [AutofillHints.password],
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

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () => _showForgotPasswordDialog(),
        child: Text('forgot_password'.tr),
      ),
    );
  }

  Widget _buildSignInButton() {
    return Obx(
      () => PrimaryButton(
        text: 'sign_in'.tr,
        onPressed: controller.signIn,
        isLoading: controller.isLoading.value,
      ),
    );
  }

  Widget _buildCreateAccountButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'dont_have_account'.tr,
          style: Get.textTheme.bodyMedium,
        ),
        TextButton(
          onPressed: () => Get.toNamed(Routes.signup),
          child: Text('create_account'.tr),
        ),
      ],
    );
  }

  void _showForgotPasswordDialog() {
    final resetEmailController = TextEditingController(
      text: controller.emailController.text,
    );

    Get.dialog(
      AlertDialog(
        title: Text('reset_password'.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'reset_password_instructions'.tr,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: resetEmailController,
              labelText: 'email'.tr,
              prefixIcon: const Icon(Icons.email_outlined),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('cancel'.tr),
          ),
          Obx(
            () => TextButton(
              onPressed: controller.isLoading.value
                  ? null
                  : () {
                      controller.emailController.text = resetEmailController.text;
                      controller.resetPassword();
                    },
              child: controller.isLoading.value
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(),
                    )
                  : Text('send_reset_link'.tr),
            ),
          ),
        ],
      ),
    );
  }
}