import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_picker/country_picker.dart';
import 'package:country_picker/src/country.dart';
import 'package:ecommerce_app/app/components/notifications/custom_toast.dart';
import 'package:ecommerce_app/app/data/models/address_model.dart';
import 'package:ecommerce_app/app/data/models/cart_item_model.dart';
import 'package:ecommerce_app/app/data/models/order_model.dart';
import 'package:ecommerce_app/app/data/services/auth_service.dart';
import 'package:ecommerce_app/app/routes/app_pages.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

class CheckoutController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Form controllers
  final fullNameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressLine1Controller = TextEditingController();
  final addressLine2Controller = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final postalCodeController = TextEditingController();
  final countryController = TextEditingController();
  final cardNumberController = TextEditingController();
  final cardHolderController = TextEditingController();
  final expiryDateController = TextEditingController();
  final cvvController = TextEditingController();
  final noteController = TextEditingController();
  
  // Form keys
  final shippingFormKey = GlobalKey<FormState>();
  final paymentFormKey = GlobalKey<FormState>();
  
  // Observables
  final RxInt currentStep = 0.obs;
  final RxBool isLoading = true.obs;
  final RxBool isProcessing = false.obs;
  final RxList<CartItemModel> cartItems = <CartItemModel>[].obs;
  final RxList<AddressModel> savedAddresses = <AddressModel>[].obs;
  final RxString selectedAddressId = ''.obs;
  final RxString selectedPaymentMethod = 'card'.obs;
  final RxDouble subtotal = 0.0.obs;
  final RxDouble shipping = 0.0.obs;
  final RxDouble tax = 0.0.obs;
  final RxDouble total = 0.0.obs;
  final RxBool isAddingNewAddress = false.obs;
  final RxBool saveAddress = true.obs;
  final RxBool setAsDefault = false.obs;
  final RxString selectedCountryCode = 'AE'.obs; // Default to UAE
  List<Country> countries = [];
  
  // Steps
  final List<String> steps = [
    'Shopping Bag',
    'Shipping',
    'Payment',
    'Summary'
  ];
  
  @override
  void onInit() {
    super.onInit();
    loadCountries();
    loadSavedAddresses();
    loadCheckoutData();
  }
  
  @override
  void onClose() {
    // Dispose of controllers
    fullNameController.dispose();
    phoneController.dispose();
    addressLine1Controller.dispose();
    addressLine2Controller.dispose();
    cityController.dispose();
    stateController.dispose();
    postalCodeController.dispose();
    countryController.dispose();
    cardNumberController.dispose();
    cardHolderController.dispose();
    expiryDateController.dispose();
    cvvController.dispose();
    noteController.dispose();
    
    super.onClose();
  }
  
  // Load checkout data
  void loadCheckoutData() async {
    final User? currentUser = _authService.currentUser;
    if (currentUser == null) {
      isLoading.value = false;
      _showAuthRequiredMessage();
      return;
    }
    
    try {
      isLoading.value = true;
      
      // Load cart items
      final cartSnapshot = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('cart')
          .get();
          
      if (cartSnapshot.docs.isEmpty) {
        CustomToast.info('Your cart is empty');
        Get.back();
        return;
      }
      
      cartItems.value = cartSnapshot.docs
          .map((doc) => CartItemModel.fromFirestore(doc))
          .toList();
      
      // Calculate totals
      _calculateTotals();
      
      // Load saved addresses
      final addressSnapshot = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('addresses')
          .get();
          
      savedAddresses.value = addressSnapshot.docs
          .map((doc) => AddressModel.fromFirestore(doc))
          .toList();
      
      // Set default address if available
      if (savedAddresses.isNotEmpty) {
        final defaultAddress = savedAddresses.firstWhereOrNull(
          (addr) => addr.isDefault
        );
        
        if (defaultAddress != null) {
          selectedAddressId.value = defaultAddress.id;
          _populateAddressForm(defaultAddress);
        }
      }
      
      // Load user info
      final userDoc = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .get();
          
      if (userDoc.exists) {
        final userData = userDoc.data();
        if (userData != null) {
          fullNameController.text = userData['name'] ?? '';
          phoneController.text = userData['phone'] ?? '';
        }
      }
    } catch (e) {
      CustomToast.error('Failed to load checkout data');
    } finally {
      isLoading.value = false;
    }
  }
  
  void _populateAddressForm(AddressModel address) {
    fullNameController.text = address.fullName;
    phoneController.text = address.phone;
    addressLine1Controller.text = address.addressLine1;
    addressLine2Controller.text = address.addressLine2 ?? '';
    cityController.text = address.city;
    stateController.text = address.state;
    postalCodeController.text = address.postalCode;
    countryController.text = address.country;
  }
  
  void _showAuthRequiredMessage() {
    Future.delayed(const Duration(milliseconds: 300), () {
      Get.dialog(
        Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Sign In Required',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Please sign in to proceed with checkout.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF555555),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Get.offAllNamed(Routes.login),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF333333),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'SIGN IN',
                      style: TextStyle(
                        fontSize: 14,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
  
  void _calculateTotals() {
    // Calculate subtotal
    subtotal.value = cartItems.fold(
      0, 
      (total, item) => total + (item.price * item.quantity)
    );
    
    // Calculate shipping based on subtotal
    if (subtotal.value > 100) {
      shipping.value = 0; // Free shipping for orders over $100
    } else if (subtotal.value > 0) {
      shipping.value = 10; // $10 shipping fee
    } else {
      shipping.value = 0; // No shipping fee for empty cart
    }
    
    // Calculate tax (example: 8% tax rate)
    tax.value = subtotal.value * 0.08;
    
    // Calculate total
    total.value = subtotal.value + shipping.value + tax.value;
  }
  
  void selectAddress(String addressId) {
    selectedAddressId.value = addressId;
    isAddingNewAddress.value = false;
    
    // Populate form with selected address data
    final address = savedAddresses.firstWhere((addr) => addr.id == addressId);
    fullNameController.text = address.fullName;
    phoneController.text = address.phone;
    addressLine1Controller.text = address.addressLine1;
    addressLine2Controller.text = address.addressLine2 ?? '';
    cityController.text = address.city;
    stateController.text = address.state;
    postalCodeController.text = address.postalCode;
    
    // Find matching country by name
    try {
      final matchingCountry = countries.firstWhere(
        (c) => c.name.toLowerCase() == address.country.toLowerCase(),
        orElse: () => countries.firstWhere(
          (c) => c.countryCode == 'AE',
          orElse: () => countries.first,
        ),
      );
      selectedCountryCode.value = matchingCountry.countryCode;
    } catch (e) {
      // Default to UAE if there's any issue
      selectedCountryCode.value = 'AE';
    }
  }
  
  void selectPaymentMethod(String method) {
    selectedPaymentMethod.value = method;
  }
  
  bool validateShippingForm() {
    return shippingFormKey.currentState?.validate() ?? false;
  }
  
  bool validatePaymentForm() {
    if (selectedPaymentMethod.value == 'card') {
      return paymentFormKey.currentState?.validate() ?? false;
    }
    return true; // Cash on delivery doesn't need validation
  }
  
  // Next step
  void nextStep() {
    // If this is the shipping step, handle address saving before proceeding
    if (currentStep.value == 1) {
      if (selectedAddressId.value.isEmpty || isAddingNewAddress.value) {
        // Validate form before proceeding
        if (shippingFormKey.currentState?.validate() ?? false) {
          // Save address if requested
          if (saveAddress.value) {
            saveShippingAddress();
          }
          currentStep.value++;
        }
      } else {
        // If using existing address, just proceed
        currentStep.value++;
      }
    } else {
      // For other steps, just proceed or validate as needed
      currentStep.value++;
    }
  }
  
  // Previous step
  void previousStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
    }
  }
  
  // Place order
  Future<void> placeOrder() async {
    final User? currentUser = _authService.currentUser;
    if (currentUser == null) return;
    
    if (cartItems.isEmpty) {
      CustomToast.error('Your cart is empty');
      return;
    }
    
    try {
      isProcessing.value = true;
      
      // Get selected country name from country code
      final selectedCountry = countries.firstWhere(
        (c) => c.countryCode == selectedCountryCode.value,
        orElse: () => countries.first,
      );
      
      // Create shipping address
      final shippingAddress = AddressModel(
        id: selectedAddressId.value.isNotEmpty
            ? selectedAddressId.value
            : const Uuid().v4(),
        fullName: fullNameController.text,
        phone: phoneController.text,
        addressLine1: addressLine1Controller.text,
        addressLine2: addressLine2Controller.text.isEmpty
            ? null
            : addressLine2Controller.text,
        city: cityController.text,
        state: stateController.text,
        postalCode: postalCodeController.text,
        country: selectedCountry.name, // Use the name from the country object
        isDefault: false,
      );
      
      // Generate unique order ID
      final orderId = const Uuid().v4();
      
      // Verify stock availability and get updated stock information
      final stockUpdateBatch = _firestore.batch();
      final List<CartItemModel> confirmedItems = [];
      
      // Check each item's stock and prepare stock updates
      for (final item in cartItems) {
        // Get current product data to check stock
        final productDoc = await _firestore
            .collection('products')
            .doc(item.productId)
            .get();
            
        if (!productDoc.exists) {
          CustomToast.error('Product ${item.name} is no longer available');
          isProcessing.value = false;
          return;
        }
        
        final productData = productDoc.data()!;
        
        // Check if we need to track inventory by variant (size/color)
        final bool hasInventoryByVariant = productData['inventoryByVariant'] == true;
        
        if (hasInventoryByVariant) {
          // Get variants collection for this product
          final variantQuery = await _firestore
              .collection('products')
              .doc(item.productId)
              .collection('variants')
              .where('size', isEqualTo: item.size)
              .where('color', isEqualTo: item.color)
              .limit(1)
              .get();
              
          if (variantQuery.docs.isEmpty) {
            CustomToast.error('Selected variant of ${item.name} is no longer available');
            isProcessing.value = false;
            return;
          }
          
          final variantDoc = variantQuery.docs.first;
          final currentStock = variantDoc.data()['stock'] ?? 0;
          
          if (currentStock < item.quantity) {
            CustomToast.error('Not enough stock for ${item.name} (${item.size}, ${item.color})');
            isProcessing.value = false;
            return;
          }
          
          // Update variant stock
          stockUpdateBatch.update(
            variantDoc.reference,
            {'stock': FieldValue.increment(-item.quantity)}
          );
        } else {
          // Check main product stock
          final currentStock = productData['stock'] ?? 0;
          
          if (currentStock < item.quantity) {
            CustomToast.error('Not enough stock for ${item.name}');
            isProcessing.value = false;
            return;
          }
          
          // Update main product stock
          stockUpdateBatch.update(
            productDoc.reference,
            {'stock': FieldValue.increment(-item.quantity)}
          );
        }
        
        // Add to confirmed items
        confirmedItems.add(item);
      }
      
      // Create order with confirmed items
      final order = OrderModel(
        id: orderId,
        userId: currentUser.uid,
        items: confirmedItems,
        shippingAddress: shippingAddress,
        paymentMethod: selectedPaymentMethod.value,
        subtotal: subtotal.value,
        shipping: shipping.value,
        tax: tax.value,
        total: total.value,
        status: 'pending',
        note: noteController.text.isNotEmpty ? noteController.text : null,
        createdAt: DateTime.now(),
      );
      
      // Save order to Firestore
      await _firestore
          .collection('orders')
          .doc(orderId)
          .set(order.toMap());
          
      // Save order reference to user's orders
      await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('orders')
          .doc(orderId)
          .set({
            'orderId': orderId,
            'total': total.value,
            'status': 'pending',
            'createdAt': Timestamp.now(),
          });
      
      // Apply stock updates
      await stockUpdateBatch.commit();
          
      // Clear cart
      final cartDocs = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('cart')
          .get();
          
      // Create a batch to delete all items
      final batch = _firestore.batch();
      
      for (final doc in cartDocs.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
      
      // Show success message
      CustomToast.success('Order placed successfully');
      
      // Navigate to order confirmation
      Get.offAllNamed(Routes.home);
      
    } catch (e) {
      CustomToast.error('Failed to place order: ${e.toString()}');
    } finally {
      isProcessing.value = false;
    }
  }
  
  // Load countries from the country_picker package
  void loadCountries() {
    // Get all countries from CountryService
    countries = CountryService().getAll();
    
    // Set default country to UAE (or your preferred default)
    if (countries.isNotEmpty) {
      try {
        // Find UAE in the list
        selectedCountryCode.value = 'AE';
      } catch (e) {
        // If UAE is not found for some reason, use the first country
        if (countries.isNotEmpty) {
          selectedCountryCode.value = countries.first.countryCode;
        }
      }
    }
  }
  
  // Load user's saved addresses
  Future<void> loadSavedAddresses() async {
    try {
      isLoading.value = true;
      
      // Check if user is logged in
      final user = _authService.currentUser;
      if (user == null) {
        return;
      }
      
      // Get addresses from Firestore
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('addresses')
          .get();
          
      final loadedAddresses = snapshot.docs
          .map((doc) => AddressModel.fromFirestore(doc))
          .toList();
          
      savedAddresses.value = loadedAddresses;
      
      // Select default address if available
      final defaultAddress = savedAddresses.firstWhereOrNull((addr) => addr.isDefault);
      if (defaultAddress != null) {
        selectAddress(defaultAddress.id);
      }
    } catch (e) {
      print('Error loading addresses: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  // Edit an existing address
  void editAddress(AddressModel address) {
    selectAddress(address.id);
    isAddingNewAddress.value = true;
  }
  
  // Clear shipping form for new address
  void clearShippingForm() {
    fullNameController.clear();
    phoneController.clear();
    addressLine1Controller.clear();
    addressLine2Controller.clear();
    cityController.clear();
    stateController.clear();
    postalCodeController.clear();
    selectedCountryCode.value = 'AE'; // Default to UAE
    saveAddress.value = true;
    setAsDefault.value = savedAddresses.isEmpty; // Set default if first address
    isAddingNewAddress.value = true;
  }
  
  // Save the current shipping address
  Future<void> saveShippingAddress() async {
    final user = _authService.currentUser;
    if (user == null) return;
    
    try {
      // Get country name from selected country code
      final selectedCountry = countries.firstWhere(
        (c) => c.countryCode == selectedCountryCode.value,
        orElse: () => countries.first,
      );
      
      String addressId;
      bool isUpdating = selectedAddressId.value.isNotEmpty;
      
      if (isUpdating) {
        addressId = selectedAddressId.value;
      } else {
        addressId = const Uuid().v4();
      }
      
      // Create address model
      final addressData = AddressModel(
        id: addressId,
        fullName: fullNameController.text.trim(),
        phone: phoneController.text.trim(),
        addressLine1: addressLine1Controller.text.trim(),
        addressLine2: addressLine2Controller.text.trim().isNotEmpty 
            ? addressLine2Controller.text.trim() 
            : null,
        city: cityController.text.trim(),
        state: stateController.text.trim(),
        postalCode: postalCodeController.text.trim(),
        country: selectedCountry.name,
        isDefault: setAsDefault.value,
      );
      
      // If setting as default, update other addresses
      if (setAsDefault.value) {
        await _updateDefaultAddressStatus(user.uid, addressId);
      }
      
      // Save to Firestore
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('addresses')
          .doc(addressId)
          .set(addressData.toMap());
          
      // Refresh addresses list
      await loadSavedAddresses();
      
    } catch (e) {
      print('Error saving address: $e');
    }
  }
  
  // Helper to update default status
  Future<void> _updateDefaultAddressStatus(String userId, String exceptAddressId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('addresses')
        .get();
        
    for (final doc in snapshot.docs) {
      if (doc.id != exceptAddressId) {
        await doc.reference.update({'isDefault': false});
      }
    }
  }
}