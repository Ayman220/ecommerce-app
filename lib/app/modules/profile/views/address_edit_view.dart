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
        title: Text(address == null ? 'Add New Address' : 'Edit Address'),
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
                  tooltip: 'Save',
                )),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Contact Information',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller.fullNameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name*',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller.addressPhoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number*',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),

              const SizedBox(height: 24),
              const Text(
                'Address Details',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller.addressLine1Controller,
                decoration: const InputDecoration(
                  labelText: 'Address Line 1*',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller.addressLine2Controller,
                decoration: const InputDecoration(
                  labelText: 'Address Line 2 (Optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller.cityController,
                decoration: const InputDecoration(
                  labelText: 'City*',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller.stateController,
                decoration: const InputDecoration(
                  labelText: 'State/Province*',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller.postalCodeController,
                decoration: const InputDecoration(
                  labelText: 'Postal/ZIP Code (Optional)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 12),

              // Country dropdown
              DropdownButtonFormField<String>(
                value: controller.selectedCountryCode.value,
                decoration: const InputDecoration(
                  labelText: 'Country*',
                  border: OutlineInputBorder(),
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
                    title: const Text('Set as default address'),
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
