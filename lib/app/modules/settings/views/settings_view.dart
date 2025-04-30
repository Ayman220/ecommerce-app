import 'package:ecommerce_app/app/components/loading_indicator.dart';
import 'package:ecommerce_app/app/widgets/keyboard_dismisser.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return KeyboardDismisser(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
          elevation: 0,
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: LoadingIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAppearanceSection(),
                const SizedBox(height: 32),
                _buildNotificationSection(),
                const SizedBox(height: 32),
                _buildLocalizationSection(),
                const SizedBox(height: 32),
                _buildAboutSection(),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Divider(),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildAppearanceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Appearance'),
        Obx(() => SwitchListTile(
              title: const Text('Use System Theme'),
              subtitle: const Text('Match app theme to system settings'),
              value: controller.useSystemTheme.value,
              onChanged: controller.toggleUseSystemTheme,
              activeColor: Get.theme.colorScheme.primary,
            )),
        if (!controller.useSystemTheme.value)
          Obx(() => SwitchListTile(
                title: const Text('Dark Mode'),
                subtitle: const Text('Use dark theme'),
                value: controller.isDarkMode.value,
                onChanged: controller.toggleDarkMode,
              )),
      ],
    );
  }

  Widget _buildNotificationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Notifications'),
        Obx(() => SwitchListTile(
              title: const Text('Push Notifications'),
              subtitle:
                  const Text('Receive notifications for orders and promotions'),
              value: controller.isNotificationsEnabled.value,
              onChanged: controller.toggleNotifications,
            )),
      ],
    );
  }

  Widget _buildLocalizationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Localization'),
        ListTile(
          title: const Text('Currency'),
          subtitle: Obx(() => Text(controller.currency.value)),
          trailing: const Icon(Icons.chevron_right),
          onTap: _showCurrencyPicker,
        ),
        ListTile(
          title: const Text('Language'),
          subtitle: Obx(() => Text(controller.language.value)),
          trailing: const Icon(Icons.chevron_right),
          onTap: _showLanguagePicker,
        ),
      ],
    );
  }

  Widget _buildAboutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('About'),
        const ListTile(
          title: Text('App Version'),
          subtitle: Text('1.0.0'),
          trailing: Icon(Icons.info_outline),
        ),
        ListTile(
          title: const Text('Privacy Policy'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // Open privacy policy screen or web page
          },
        ),
        ListTile(
          title: const Text('Terms of Service'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // Open terms of service screen or web page
          },
        ),
      ],
    );
  }

  void _showCurrencyPicker() {
    final currencies = ['USD', 'EUR', 'GBP', 'AED', 'INR', 'JPY', 'CNY'];

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Get.theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Text(
                    'Select Currency',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: currencies.length,
                itemBuilder: (context, index) {
                  final currency = currencies[index];
                  return ListTile(
                    title: Text(currency),
                    trailing: controller.currency.value == currency
                        ? Icon(
                            Icons.check,
                            color: Get.theme.colorScheme.primary,
                          )
                        : null,
                    onTap: () {
                      controller.setCurrency(currency);
                      Get.back();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      ignoreSafeArea: false,
    );
  }

  void _showLanguagePicker() {
    final languages = ['English', 'Arabic'];

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Get.theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Text(
                  'Select Language',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
          ),
          const Divider(),
          ListView.builder(
            shrinkWrap: true,
            itemCount: languages.length,
            itemBuilder: (context, index) {
              final language = languages[index];
              return ListTile(
                title: Text(language),
                trailing: controller.language.value == language
                    ? Icon(
                        Icons.check,
                        color: Get.theme.colorScheme.primary,
                      )
                    : null,
                onTap: () {
                  controller.setLanguage(language);
                  Get.back();
                },
              );
            },
          ),
        ],
      ),
    ),
    isScrollControlled: true,
  );
}
}
