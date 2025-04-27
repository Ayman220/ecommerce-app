import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_picker/country_picker.dart';
import 'package:ecommerce_app/app/components/notifications/custom_toast.dart';
import 'package:ecommerce_app/app/data/models/address_model.dart';
import 'package:ecommerce_app/app/data/services/auth_service.dart';
import 'package:ecommerce_app/app/routes/app_pages.dart';
import 'package:ecommerce_app/app/modules/profile/views/address_edit_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class ProfileController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  final RxBool isLoading = false.obs;
  final RxBool isUpdating = false.obs;
  final RxBool isLoadingAddresses = false.obs;

  // Form controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  
  // Address form controllers
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController addressPhoneController = TextEditingController();
  final TextEditingController addressLine1Controller = TextEditingController();
  final TextEditingController addressLine2Controller = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController postalCodeController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  
  // User data
  final Rx<User?> currentUser = Rx<User?>(null);
  final RxMap<String, dynamic> userData = <String, dynamic>{}.obs;
  final RxString profileImageUrl = ''.obs;
  
  // Addresses
  final RxList<AddressModel> addresses = <AddressModel>[].obs;

  // Additional properties
  final RxBool setAsDefault = false.obs;
  final RxString selectedCountryCode = ''.obs;
  List<Country> countries = [];
  
  @override
  void onInit() {
    super.onInit();
    // Load countries when controller initializes
    loadCountries();
    currentUser.value = _authService.currentUser;
    
    if (currentUser.value != null) {
      loadUserData();
      loadAddresses();
    } else {
      Get.offAllNamed(Routes.login);
    }
  }
  
  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    fullNameController.dispose();
    addressPhoneController.dispose();
    addressLine1Controller.dispose();
    addressLine2Controller.dispose();
    cityController.dispose();
    stateController.dispose();
    postalCodeController.dispose();
    countryController.dispose();
    super.onClose();
  }
  
  // Load user's saved addresses
  Future<void> loadAddresses() async {
    if (currentUser.value == null) return;
    
    try {
      isLoadingAddresses.value = true;
      
      final snapshot = await _firestore
          .collection('users')
          .doc(currentUser.value!.uid)
          .collection('addresses')
          .get();
      
      final loadedAddresses = snapshot.docs
          .map((doc) => AddressModel.fromFirestore(doc))
          .toList();
      
      addresses.value = loadedAddresses;
    } catch (e) {
      CustomToast.error('Failed to load addresses');
    } finally {
      isLoadingAddresses.value = false;
    }
  }
  
  // Initialize form with address data
  void initAddressForm(AddressModel address) {
    fullNameController.text = address.fullName;
    addressPhoneController.text = address.phone;
    addressLine1Controller.text = address.addressLine1;
    addressLine2Controller.text = address.addressLine2 ?? '';
    cityController.text = address.city;
    stateController.text = address.state;
    postalCodeController.text = address.postalCode;
    final matchingCountry = countries.firstWhere(
      (c) => c.name.toLowerCase() == address.country.toLowerCase(),
      orElse: () => countries.firstWhere(
        (c) => c.countryCode == 'AE', 
        orElse: () => countries.first
      ),
    );
    selectedCountryCode.value = matchingCountry.countryCode;
    setAsDefault.value = address.isDefault;
  }

  // Clear address form
  void clearAddressForm() {
    fullNameController.clear();
    addressPhoneController.clear();
    addressLine1Controller.clear();
    addressLine2Controller.clear();
    cityController.clear();
    stateController.clear();
    postalCodeController.clear();
    // Use UAE as the default country
    selectedCountryCode.value = 'AE';
    
    // If this is the first address, make it default
    setAsDefault.value = addresses.isEmpty;
  }

  // Add a new address
  Future<void> addAddress() async {
    // Validate required fields
    if (!validateAddressForm()) {
      return;
    }
    
    try {
      isUpdating.value = true;
      
      final addressId = const Uuid().v4();
      
      // Get country name from selected country code
      final selectedCountry = countries.firstWhere(
        (c) => c.countryCode == selectedCountryCode.value,
        orElse: () => countries.first,
      );

      final newAddress = AddressModel(
        id: addressId,
        fullName: fullNameController.text.trim(),
        phone: addressPhoneController.text.trim(),
        addressLine1: addressLine1Controller.text.trim(),
        addressLine2: addressLine2Controller.text.trim().isEmpty 
            ? null 
            : addressLine2Controller.text.trim(),
        city: cityController.text.trim(),
        state: stateController.text.trim(),
        postalCode: postalCodeController.text.trim(),
        country: selectedCountry.name,
        isDefault: setAsDefault.value,
      );
      
      // If setting as default, update existing default address
      if (setAsDefault.value) {
        await updateDefaultAddressStatus(addressId);
      }
      
      // Add new address to Firestore
      await _firestore
          .collection('users')
          .doc(currentUser.value!.uid)
          .collection('addresses')
          .doc(addressId)
          .set(newAddress.toMap());
      
      // Refresh addresses list
      await loadAddresses();
      
      Get.back();
      CustomToast.success('Address added successfully');
    } catch (e) {
      CustomToast.error('Failed to add address');
    } finally {
      isUpdating.value = false;
    }
  }

  // Update an existing address
  Future<void> updateAddress(String addressId) async {
    // Validate required fields
    if (!validateAddressForm()) {
      return;
    }
    
    try {
      isUpdating.value = true;
      
      // Get country name from selected country code
      final selectedCountry = countries.firstWhere(
        (c) => c.countryCode == selectedCountryCode.value,
        orElse: () => countries.first,
      );

      final updatedAddress = AddressModel(
        id: addressId,
        fullName: fullNameController.text.trim(),
        phone: addressPhoneController.text.trim(),
        addressLine1: addressLine1Controller.text.trim(),
        addressLine2: addressLine2Controller.text.trim().isEmpty 
            ? null 
            : addressLine2Controller.text.trim(),
        city: cityController.text.trim(),
        state: stateController.text.trim(),
        postalCode: postalCodeController.text.trim(),
        country: selectedCountry.name,
        isDefault: setAsDefault.value,
      );
      
      // If setting as default, update existing default address
      if (setAsDefault.value) {
        await updateDefaultAddressStatus(addressId);
      }
      
      // Update address in Firestore
      await _firestore
          .collection('users')
          .doc(currentUser.value!.uid)
          .collection('addresses')
          .doc(addressId)
          .update(updatedAddress.toMap());
      
      // Refresh addresses list
      await loadAddresses();
      
      Get.back();
      CustomToast.success('Address updated successfully');
    } catch (e) {
      CustomToast.error('Failed to update address');
    } finally {
      isUpdating.value = false;
    }
  }

  // Validate address form
  bool validateAddressForm() {
    if (fullNameController.text.trim().isEmpty) {
      CustomToast.error('Please enter full name');
      return false;
    }
    
    if (addressPhoneController.text.trim().isEmpty) {
      CustomToast.error('Please enter phone number');
      return false;
    }
    
    if (addressLine1Controller.text.trim().isEmpty) {
      CustomToast.error('Please enter address line 1');
      return false;
    }
    
    if (cityController.text.trim().isEmpty) {
      CustomToast.error('Please enter city');
      return false;
    }
    
    if (stateController.text.trim().isEmpty) {
      CustomToast.error('Please enter state');
      return false;
    }
    
    // Postal code is now optional
    
    if (selectedCountryCode.value.isEmpty) {
      CustomToast.error('Please select a country');
      return false;
    }
    
    return true;
  }

  // Delete an address
  Future<void> deleteAddress(String addressId) async {
    try {
      isUpdating.value = true;
      
      // Check if this is the default address
      final address = addresses.firstWhere((a) => a.id == addressId);
      
      // Delete address from Firestore
      await _firestore
          .collection('users')
          .doc(currentUser.value!.uid)
          .collection('addresses')
          .doc(addressId)
          .delete();
      
      // If deleted address was default and there are other addresses
      if (address.isDefault && addresses.length > 1) {
        // Set first remaining address as default
        final firstRemainingAddress = addresses.firstWhere((a) => a.id != addressId);
        await _firestore
            .collection('users')
            .doc(currentUser.value!.uid)
            .collection('addresses')
            .doc(firstRemainingAddress.id)
            .update({'isDefault': true});
      }
      
      // Refresh addresses list
      await loadAddresses();
      
      CustomToast.success('Address deleted successfully');
    } catch (e) {
      CustomToast.error('Failed to delete address');
    } finally {
      isUpdating.value = false;
    }
  }
  
  // Set an address as default
  Future<void> setDefaultAddress(String addressId) async {
    try {
      isUpdating.value = true;
      
      // Update all other addresses to not be default
      await updateDefaultAddressStatus(addressId);
      
      // Set the selected address as default
      await _firestore
          .collection('users')
          .doc(currentUser.value!.uid)
          .collection('addresses')
          .doc(addressId)
          .update({'isDefault': true});
      
      // Refresh addresses list
      await loadAddresses();
      
      CustomToast.success('Default address updated');
    } catch (e) {
      CustomToast.error('Failed to set default address');
    } finally {
      isUpdating.value = false;
    }
  }
  
  // Helper to update default status of all addresses
  Future<void> updateDefaultAddressStatus(String exceptAddressId) async {
    // Get all addresses
    final snapshot = await _firestore
        .collection('users')
        .doc(currentUser.value!.uid)
        .collection('addresses')
        .get();
    
    // Update all addresses to not be default except the specified one
    for (final doc in snapshot.docs) {
      if (doc.id != exceptAddressId) {
        await doc.reference.update({'isDefault': false});
      }
    }
  }
  
  void loadUserData() async {
    if (currentUser.value == null) return;
    
    try {
      isLoading.value = true;
      
      final doc = await _firestore
          .collection('users')
          .doc(currentUser.value!.uid)
          .get();
      
      if (doc.exists && doc.data() != null) {
        userData.value = doc.data()!;
        
        // Set form data
        nameController.text = userData['name'] ?? currentUser.value?.displayName ?? '';
        emailController.text = userData['email'] ?? currentUser.value?.email ?? '';
        phoneController.text = userData['phone'] ?? '';
        
        // Set profile image
        profileImageUrl.value = userData['photoURL'] ?? currentUser.value?.photoURL ?? '';
      }
    } catch (e) {
      CustomToast.error('Failed to load user data');
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> updateProfile() async {
    if (currentUser.value == null) return;
    
    try {
      isUpdating.value = true;
      
      final updatedData = {
        'name': nameController.text.trim(),
        'phone': phoneController.text.trim(),
      };
      
      // Update auth profile
      await _authService.updateUserProfile(
        uid: currentUser.value!.uid,
        name: nameController.text.trim(),
        phoneNumber: phoneController.text.trim(),
      );
      
      // Update Firestore document
      await _firestore
          .collection('users')
          .doc(currentUser.value!.uid)
          .update(updatedData);
      
      // Update local user data
      userData['name'] = nameController.text.trim();
      userData['phone'] = phoneController.text.trim();
      
      CustomToast.success('Profile updated successfully');
    } catch (e) {
      CustomToast.error('Failed to update profile');
    } finally {
      isUpdating.value = false;
    }
  }
  
  Future<void> updateProfilePicture() async {
    if (currentUser.value == null) return;
    
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      try {
        isUpdating.value = true;
        
        // For now, let's show a message to implement your preferred storage method
        CustomToast.info('Image storage needs to be implemented');
        
        // For demo purposes, we'll just update the UI with a placeholder
        final String demoImageUrl = "https://ui-avatars.com/api/?name=${nameController.text.trim().replaceAll(' ', '+')}&background=random";
        
        // Update Firestore document with the placeholder
        await _firestore
            .collection('users')
            .doc(currentUser.value!.uid)
            .update({
              'photoURL': demoImageUrl,
            });
        
        // Update local data
        profileImageUrl.value = demoImageUrl;
        
        CustomToast.success('Profile updated with placeholder image');
      } catch (e) {
        CustomToast.error('Failed to update profile picture');
      } finally {
        isUpdating.value = false;
      }
    }
  }
  
  Future<void> changePassword() async {
    // Show a dialog to enter new password
    Get.dialog(
      AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => password = value,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (password.isEmpty || password.length < 6) {
                CustomToast.error('Password must be at least 6 characters');
                return;
              }
              
              Get.back();
              try {
                isUpdating.value = true;
                await _authService.updatePassword(newPassword: password);
                CustomToast.success('Password updated successfully');
              } catch (e) {
                CustomToast.error('Failed to update password: ${e.toString()}');
              } finally {
                isUpdating.value = false;
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
  
  // Store password temporarily
  String password = '';

  // This method navigates to the address edit screen
  void navigateToAddressEdit([AddressModel? address]) {
    // If editing an existing address, initialize form with existing data
    if (address != null) {
      initAddressForm(address);
    } else {
      // Otherwise clear the form for a new address
      clearAddressForm();
    }
    
    // Navigate to the address edit view
    Get.to(
      () => AddressEditView(address: address),
      transition: Transition.rightToLeft,
      duration: const Duration(milliseconds: 250),
    );
  }

  // Load countries from the package
  void loadCountries() {
    countries = CountryService().getAll();
    // Set default country to UAE
    selectedCountryCode.value = 'AE';
  }
}