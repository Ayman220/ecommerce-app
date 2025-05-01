import 'package:ecommerce_app/app/components/loading_indicator.dart';
import 'package:ecommerce_app/app/modules/profile/controllers/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('my_profile'.tr),
        centerTitle: true,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: LoadingIndicator());
        }

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildProfileHeader(),
                const SizedBox(height: 24),
                _buildProfileForm(),
                const SizedBox(height: 32),
                _buildSecurityOptions(),
                const SizedBox(height: 32),
                _buildAddressesSection(),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        GestureDetector(
          onTap: controller.updateProfilePicture,
          child: Stack(
            children: [
              Obx(() => CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: controller.profileImageUrl.isNotEmpty
                        ? NetworkImage(controller.profileImageUrl.value)
                        : null,
                    child: controller.profileImageUrl.isEmpty
                        ? Icon(
                            Icons.person,
                            size: 50,
                            color: Colors.grey[400],
                          )
                        : null,
                  )),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Get.theme.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Obx(() => Text(
              controller.userData['name'] ?? 'user'.tr,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            )),
        const SizedBox(height: 4),
        Obx(() => Text(
              controller.userData['email'] ?? '',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            )),
      ],
    );
  }

  Widget _buildProfileForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'personal_information'.tr,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: controller.nameController,
          decoration: InputDecoration(
            labelText: 'full_name'.tr,
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.person_outline),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: controller.emailController,
          readOnly: true, // Email can't be changed directly
          decoration: InputDecoration(
            labelText: 'email'.tr,
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.email_outlined),
            suffixIcon: const Icon(Icons.lock_outline, size: 16),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: controller.phoneController,
          decoration: InputDecoration(
            labelText: 'phone_number'.tr,
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.phone_outlined),
          ),
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 24),
        Obx(() => ElevatedButton(
              onPressed:
                  controller.isUpdating.value ? null : controller.updateProfile,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: controller.isUpdating.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : Text('save_changes'.tr),
            )),
      ],
    );
  }

  Widget _buildSecurityOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'security'.tr,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: controller.changePassword,
          icon: const Icon(Icons.lock_outline),
          label: Text('change_password'.tr),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildAddressesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'saved_addresses'.tr,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              onPressed: () => controller.navigateToAddressEdit(),
              icon: const Icon(Icons.add),
              label: Text('add_new'.tr),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Addresses list
        Obx(() {
          if (controller.isLoadingAddresses.value) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (controller.addresses.isEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  'no_saved_addresses'.tr,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            );
          }

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.addresses.length,
            itemBuilder: (context, index) {
              final address = controller.addresses[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: address.isDefault
                        ? Get.theme.primaryColor
                        : Colors.grey[300]!,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            address.fullName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (address.isDefault)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Get.theme.primaryColor.withAlpha((0.1 * 255).toInt()),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'default'.tr,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Get.theme.primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          const Spacer(),
                          PopupMenuButton(
                            icon: const Icon(Icons.more_vert),
                            onSelected: (value) {
                              if (value == 'edit') {
                                controller.navigateToAddressEdit(address);
                              } else if (value == 'delete') {
                                _showDeleteConfirmation(address.id);
                              } else if (value == 'default') {
                                controller.setDefaultAddress(address.id);
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'edit',
                                child: Text('edit'.tr),
                              ),
                              if (!address.isDefault)
                                PopupMenuItem(
                                  value: 'default',
                                  child: Text('set_as_default'.tr),
                                ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Text(
                                  'delete'.tr,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        address.phone,
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        address.formattedAddress,
                        style: const TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }),
      ],
    );
  }

  void _showDeleteConfirmation(String addressId) {
    Get.dialog(
      AlertDialog(
        title: Text('delete_address'.tr),
        content: Text('delete_address_confirmation'.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('cancel'.tr),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.deleteAddress(addressId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('delete'.tr),
          ),
        ],
      ),
    );
  }
}
