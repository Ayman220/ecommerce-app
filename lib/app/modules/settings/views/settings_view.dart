import 'package:ecommerce_app/app/components/loading_indicator.dart';
import 'package:ecommerce_app/app/modules/settings/controllers/settings_controller.dart';
import 'package:ecommerce_app/app/widgets/keyboard_dismisser.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return KeyboardDismisser(
      child: Scaffold(
        appBar: AppBar(
          title: Text('settings'.tr),
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
        _buildSectionHeader('appearance'.tr),
        Obx(() => SwitchListTile(
              title: Text('use_system_theme'.tr),
              value: controller.useSystemTheme.value,
              onChanged: controller.toggleUseSystemTheme,
            )),
        Obx(() => SwitchListTile(
              title: Text('dark_mode'.tr),
              value: controller.isDarkMode.value,
              onChanged: controller.useSystemTheme.value ? null : controller.toggleDarkMode,
            )),
      ],
    );
  }

  Widget _buildNotificationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('notifications'.tr),
        Obx(() => SwitchListTile(
              title: Text('push_notifications'.tr),
              subtitle: Text('receive_notifications'.tr),
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
        _buildSectionHeader('localization'.tr),
        ListTile(
          title: Text('currency'.tr),
          subtitle: Obx(() => Text(controller.currency.value)),
          trailing: const Icon(Icons.chevron_right),
          onTap: _showCurrencyPicker,
        ),
        ListTile(
          title: Text('language'.tr),
          subtitle: Obx(() => Text(controller.getLanguageDisplayName(controller.languageCode.value))),
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
        _buildSectionHeader('about'.tr),
        ListTile(
          title: Text('app_version'.tr),
          subtitle: const Text('1.0.0'),
          trailing: const Icon(Icons.info_outline),
        ),
        ListTile(
          title: Text('privacy_policy'.tr),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // Open privacy policy screen or web page
          },
        ),
        ListTile(
          title: Text('terms_of_service'.tr),
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
                  Text(
                    'select_currency'.tr,
                    style: const TextStyle(
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
    final languages = [
      {'code': 'en', 'name': 'english'.tr, 'flag': '🇺🇸'},
      {'code': 'ar', 'name': 'arabic'.tr, 'flag': '🇸🇦'}
    ];

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
                  Text(
                    'select_language'.tr,
                    style: const TextStyle(
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
                  leading: Text(
                    language['flag']!, 
                    style: const TextStyle(fontSize: 20),
                  ),
                  title: Text(language['name']!),
                  trailing: controller.languageCode.value == language['code']
                      ? Icon(
                          Icons.check,
                          color: Get.theme.colorScheme.primary,
                        )
                      : null,
                  onTap: () {
                    controller.setLanguage(language['code']!);
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
