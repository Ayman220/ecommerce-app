import 'package:ecommerce_app/app/data/models/address_model.dart';
import 'package:ecommerce_app/app/modules/profile/controllers/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddressEditView extends GetView<ProfileController> {
  final AddressModel? address;

  const AddressEditView({
    Key? key,
    this.address,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Initialize form with existing address data if editing
    if (address != null) {
      controller.initAddressForm(address!);
    } else {
      controller.clearAddressForm();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(address == null ? 'add_new_address'.tr : 'edit_address'.tr),
        centerTitle: true,
        elevation: 0,
        actions: [
          Obx(() => controller.isUpdating.value
              ? Container(
                  margin: const EdgeInsets.all(10),
                  width: 20,
                  height: 20,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : IconButton(
                  onPressed: () {
                    if (address == null) {
                      controller.addAddress();
                    } else {
                      controller.updateAddress(address!.id);
                    }
                  },
                  icon: const Icon(Icons.check),
                  tooltip: 'save'.tr,
                )),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'contact_information'.tr,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller.fullNameController,
                decoration: InputDecoration(
                  labelText: 'full_name_required'.tr,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller.addressPhoneController,
                decoration: InputDecoration(
                  labelText: '${'phone_number'.tr}*',
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),

              const SizedBox(height: 24),
              Text(
                'address_details'.tr,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller.addressLine1Controller,
                decoration: InputDecoration(
                  labelText: 'address_line_1_required'.tr,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller.addressLine2Controller,
                decoration: InputDecoration(
                  labelText: 'address_line_2_optional'.tr,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller.cityController,
                decoration: InputDecoration(
                  labelText: 'city_required'.tr,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller.stateController,
                decoration: InputDecoration(
                  labelText: 'state_province_required'.tr,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller.postalCodeController,
                decoration: InputDecoration(
                  labelText: 'postal_code_optional'.tr,
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 12),

              // Country dropdown
              DropdownButtonFormField<String>(
                value: controller.selectedCountryCode.value,
                decoration: InputDecoration(
                  labelText: 'country_required'.tr,
                  border: const OutlineInputBorder(),
                ),
                isExpanded: true,
                items: controller.countries.map((country) {
                  return DropdownMenuItem(
                    value: country.countryCode,
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: SizedBox(
                            height: 16,
                            width: 24,
                            child: Text(country.flagEmoji),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            country.name,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    controller.selectedCountryCode.value = value;
                  }
                },
              ),

              const SizedBox(height: 24),
              Obx(() => SwitchListTile(
                    title: Text('set_as_default'.tr),
                    value: controller.setAsDefault.value,
                    onChanged: (value) {
                      controller.setAsDefault.value = value;
                    },
                    activeColor: Get.theme.primaryColor,
                  )),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
