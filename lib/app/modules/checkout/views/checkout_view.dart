import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecommerce_app/app/components/buttons/primary_button.dart';
import 'package:ecommerce_app/app/components/buttons/secondary_button.dart';
import 'package:ecommerce_app/app/data/models/address_model.dart';
import 'package:ecommerce_app/app/modules/checkout/controllers/checkout_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class CheckoutView extends GetView<CheckoutController> {
  const CheckoutView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          );
        }

        return _buildCheckoutContent();
      }),
    );
  }

  Widget _buildCheckoutContent() {
    return Column(
      children: [
        // Steps indicator
        _buildStepIndicator(),

        // Content based on current step
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Obx(() {
              switch (controller.currentStep.value) {
                case 0:
                  return _buildCartStep();
                case 1:
                  return _buildShippingStep();
                case 2:
                  return _buildPaymentStep();
                case 3:
                  return _buildSummaryStep();
                default:
                  return const SizedBox.shrink();
              }
            }),
          ),
        ),

        // Navigation buttons
        _buildNavigationButtons(),
      ],
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.05 * 255).toInt()),
            blurRadius: 1,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: List.generate(controller.steps.length, (index) {
          final isActive = controller.currentStep.value >= index;
          final isLast = index == controller.steps.length - 1;

          return Expanded(
            child: Row(
              children: [
                // Circle indicator
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isActive
                              ? Get.theme.colorScheme.primary
                              : Colors.grey[300],
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: isActive ? Colors.white : Colors.grey,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        controller.steps[index],
                        style: TextStyle(
                          color: isActive
                              ? Get.theme.colorScheme.primary
                              : Colors.grey,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                // Connector line
                if (!isLast)
                  Expanded(
                    child: Container(
                      height: 1,
                      color: isActive
                          ? Get.theme.colorScheme.primary
                          : Colors.grey[300],
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCartStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${controller.cartItems.length} ${controller.cartItems.length == 1 ? 'Item' : 'Items'}',
          style: Get.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),

        // Cart items
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controller.cartItems.length,
          separatorBuilder: (_, __) => const Divider(height: 24),
          itemBuilder: (context, index) {
            final item = controller.cartItems[index];
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product image
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: CachedNetworkImage(
                    imageUrl: item.image,
                    width: 80,
                    height: 100,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[200],
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.error),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Product details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: Get.textTheme.titleSmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      if (item.size != null || item.color != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            [
                              if (item.size != null) 'Size: ${item.size}',
                              if (item.color != null) 'Color: ${item.color}',
                            ].join(' • '),
                            style: Get.textTheme.bodySmall,
                          ),
                        ),
                      Row(
                        children: [
                          Text(
                            '\$${item.price.toStringAsFixed(2)}',
                            style: Get.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'Qty: ${item.quantity}',
                            style: Get.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),

        const SizedBox(height: 24),

        // Order summary
        _buildOrderSummary(),
      ],
    );
  }

  Widget _buildShippingStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Saved addresses (if any)
        Obx(() {
          if (controller.savedAddresses.isEmpty) {
            return const SizedBox.shrink();
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Saved Addresses',
                style: Get.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.savedAddresses.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return _buildSavedAddressItem(
                      controller.savedAddresses[index]);
                },
              ),
              const Divider(height: 32),
            ],
          );
        }),

        // New address form or edit existing address
        Text(
          controller.selectedAddressId.value.isEmpty
              ? 'Add New Address'
              : 'Delivery Address',
          style: Get.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),

        Form(
          key: controller.shippingFormKey,
          child: Column(
            children: [
              // Full name
              TextFormField(
                controller: controller.fullNameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  hintText: 'Enter your full name',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your full name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Phone
              TextFormField(
                controller: controller.phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  hintText: 'Enter your phone number',
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  // Remove any non-digit characters for validation
                  final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
                  // Check if the phone number has a reasonable length (between 7 and 15 digits)
                  if (digitsOnly.length < 7 || digitsOnly.length > 15) {
                    return 'Please enter a valid phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Address line 1
              TextFormField(
                controller: controller.addressLine1Controller,
                decoration: const InputDecoration(
                  labelText: 'Address Line 1',
                  hintText: 'Enter your street address',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your street address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Address line 2 (optional)
              TextFormField(
                controller: controller.addressLine2Controller,
                decoration: const InputDecoration(
                  labelText: 'Address Line 2 (Optional)',
                  hintText: 'Apartment, suite, unit, building, floor, etc.',
                ),
              ),
              const SizedBox(height: 16),

              // City
              TextFormField(
                controller: controller.cityController,
                decoration: const InputDecoration(
                  labelText: 'City',
                  hintText: 'Enter your city',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your city';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Row for State and Postal Code
              Row(
                children: [
                  // State
                  Expanded(
                    child: TextFormField(
                      controller: controller.stateController,
                      decoration: const InputDecoration(
                        labelText: 'State/Province',
                        hintText: 'Enter your state',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your state';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Postal code
                  Expanded(
                    child: TextFormField(
                      controller: controller.postalCodeController,
                      decoration: const InputDecoration(
                        labelText: 'Postal Code',
                        hintText: 'Enter postal code',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter postal code';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Country
              TextFormField(
                controller: controller.countryController,
                decoration: const InputDecoration(
                  labelText: 'Country',
                  hintText: 'Enter your country',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your country';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Save address checkbox
              CheckboxListTile(
                title: const Text('Save this address for future use'),
                value: true,
                onChanged: (value) {},
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
              ),
              const SizedBox(height: 8),

              // Set as default checkbox
              CheckboxListTile(
                title: const Text('Set as my default address'),
                value: false,
                onChanged: (value) {},
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Method',
          style: Get.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),

        // Payment methods
        _buildPaymentMethodSelector(),
        const SizedBox(height: 24),

        // Credit card form (shown only if card is selected)
        Obx(() {
          if (controller.selectedPaymentMethod.value == 'card') {
            return _buildCreditCardForm();
          } else {
            return _buildCashOnDeliveryInfo();
          }
        }),

        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 16),

        // Order summary
        _buildOrderSummary(),
      ],
    );
  }

  Widget _buildSummaryStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Shipping address
        Text(
          'Shipping Address',
          style: Get.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: Get.theme.colorScheme.onSurface
                  .withAlpha((0.1 * 255).toInt()),
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                controller.fullNameController.text,
                style: Get.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(controller.phoneController.text),
              const SizedBox(height: 4),
              Text(controller.addressLine1Controller.text),
              if (controller.addressLine2Controller.text.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(controller.addressLine2Controller.text),
              ],
              const SizedBox(height: 2),
              Text(
                '${controller.cityController.text}, ${controller.stateController.text} ${controller.postalCodeController.text}',
              ),
              const SizedBox(height: 2),
              Text(controller.countryController.text),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Payment method
        Text(
          'Payment Method',
          style: Get.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: Get.theme.colorScheme.onSurface
                  .withAlpha((0.1 * 255).toInt()),
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              Icon(
                controller.selectedPaymentMethod.value == 'card'
                    ? Icons.credit_card
                    : Icons.money,
                color: Get.theme.colorScheme.primary,
              ),
              const SizedBox(width: 16),
              Text(
                controller.selectedPaymentMethod.value == 'card'
                    ? 'Credit/Debit Card'
                    : 'Cash on Delivery',
                style: Get.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Order items
        Text(
          'Order Items',
          style: Get.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controller.cartItems.length,
          separatorBuilder: (_, __) => const Divider(height: 24),
          itemBuilder: (context, index) {
            final item = controller.cartItems[index];
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product image
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: CachedNetworkImage(
                    imageUrl: item.image,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[200],
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.error),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Product details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: Get.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      if (item.size != null || item.color != null)
                        Text(
                          [
                            if (item.size != null) 'Size: ${item.size}',
                            if (item.color != null) 'Color: ${item.color}',
                          ].join(' • '),
                          style: Get.textTheme.bodySmall,
                        ),
                    ],
                  ),
                ),

                // Price and quantity
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${item.price.toStringAsFixed(2)}',
                      style: Get.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Qty: ${item.quantity}',
                      style: Get.textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 24),

        // Additional note
        Text(
          'Additional Note',
          style: Get.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller.noteController,
          decoration: const InputDecoration(
            hintText: 'Add a note for your order (optional)',
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 24),

        // Order summary
        _buildOrderSummary(),
      ],
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.surface,
        border: Border.all(
          color: Get.theme.colorScheme.onSurface.withAlpha((0.1 * 255).toInt()),
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Summary',
            style: Get.textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          _buildSummaryRow(
            label: 'Subtotal',
            value: '\$${controller.subtotal.value.toStringAsFixed(2)}',
          ),
          _buildSummaryRow(
            label: 'Shipping',
            value: controller.shipping.value > 0
                ? '\$${controller.shipping.value.toStringAsFixed(2)}'
                : 'Free',
            valueStyle: controller.shipping.value > 0
                ? null
                : TextStyle(
                    color: Get.theme.colorScheme.secondary,
                  ),
          ),
          _buildSummaryRow(
            label: 'Estimated Tax',
            value: '\$${controller.tax.value.toStringAsFixed(2)}',
          ),
          const Divider(height: 24),
          _buildSummaryRow(
            label: 'Total',
            value: '\$${controller.total.value.toStringAsFixed(2)}',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow({
    required String label,
    required String value,
    bool isTotal = false,
    TextStyle? valueStyle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style:
                isTotal ? Get.textTheme.titleMedium : Get.textTheme.bodyMedium,
          ),
          Text(
            value,
            style: valueStyle ??
                (isTotal
                    ? Get.textTheme.titleMedium?.copyWith(
                        color: Get.theme.colorScheme.secondary,
                      )
                    : Get.textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }

  Widget _buildSavedAddressItem(AddressModel address) {
    final isSelected = controller.selectedAddressId.value == address.id;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected
              ? Get.theme.colorScheme.primary
              : Get.theme.colorScheme.onSurface.withAlpha((0.1 * 255).toInt()),
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: RadioListTile<String>(
        title: Text(
          address.fullName,
          style: Get.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          address.formattedAddress,
          style: Get.textTheme.bodySmall,
        ),
        value: address.id,
        groupValue: controller.selectedAddressId.value,
        onChanged: (value) {
          if (value != null) {
            controller.selectAddress(value);
          }
        },
        activeColor: Get.theme.colorScheme.primary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        dense: true,
        secondary: address.isDefault
            ? Chip(
                label: const Text('Default'),
                backgroundColor: Get.theme.colorScheme.primary
                    .withAlpha((0.1 * 255).toInt()),
                labelStyle: TextStyle(
                  fontSize: 12,
                  color: Get.theme.colorScheme.primary,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: EdgeInsets.zero,
              )
            : null,
      ),
    );
  }

  Widget _buildPaymentMethodSelector() {
    return Column(
      children: [
        // Credit Card option
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: controller.selectedPaymentMethod.value == 'card'
                  ? Get.theme.colorScheme.primary
                  : Get.theme.colorScheme.onSurface
                      .withAlpha((0.1 * 255).toInt()),
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: RadioListTile<String>(
            title: const Text('Credit / Debit Card'),
            subtitle: const Text('Pay securely with your card'),
            secondary: const Icon(Icons.credit_card),
            value: 'card',
            groupValue: controller.selectedPaymentMethod.value,
            onChanged: (value) {
              if (value != null) {
                controller.selectPaymentMethod(value);
              }
            },
            activeColor: Get.theme.colorScheme.primary,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        ),
        const SizedBox(height: 16),

        // Cash on Delivery option
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: controller.selectedPaymentMethod.value == 'cod'
                  ? Get.theme.colorScheme.primary
                  : Get.theme.colorScheme.onSurface
                      .withAlpha((0.1 * 255).toInt()),
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: RadioListTile<String>(
            title: const Text('Cash on Delivery'),
            subtitle: const Text('Pay when you receive your items'),
            secondary: const Icon(Icons.money),
            value: 'cod',
            groupValue: controller.selectedPaymentMethod.value,
            onChanged: (value) {
              if (value != null) {
                controller.selectPaymentMethod(value);
              }
            },
            activeColor: Get.theme.colorScheme.primary,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        ),
      ],
    );
  }

  Widget _buildCreditCardForm() {
    return Form(
      key: controller.paymentFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Card Details',
            style: Get.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),

          // Card number
          TextFormField(
            controller: controller.cardNumberController,
            decoration: const InputDecoration(
              labelText: 'Card Number',
              hintText: 'XXXX XXXX XXXX XXXX',
              prefixIcon: Icon(Icons.credit_card),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              _CardNumberInputFormatter(),
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your card number';
              }
              if (value.replaceAll(' ', '').length < 16) {
                return 'Please enter a valid card number';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Cardholder name
          TextFormField(
            controller: controller.cardHolderController,
            decoration: const InputDecoration(
              labelText: 'Cardholder Name',
              hintText: 'Name as it appears on your card',
              prefixIcon: Icon(Icons.person),
            ),
            textCapitalization: TextCapitalization.words,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter cardholder name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Row for expiry and CVV
          Row(
            children: [
              // Expiry date
              Expanded(
                flex: 3,
                child: TextFormField(
                  controller: controller.expiryDateController,
                  decoration: const InputDecoration(
                    labelText: 'Expiry Date',
                    hintText: 'MM/YY',
                    prefixIcon: Icon(Icons.date_range),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    _ExpiryDateInputFormatter(),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    if (value.length < 5) {
                      return 'Invalid date';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),

              // CVV code
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: controller.cvvController,
                  decoration: const InputDecoration(
                    labelText: 'CVV',
                    hintText: 'XXX',
                    prefixIcon: Icon(Icons.lock),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    if (value.length < 3) {
                      return 'Invalid CVV';
                    }
                    return null;
                  },
                  obscureText: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Billing address same as shipping
          CheckboxListTile(
            title: const Text('Billing address same as shipping address'),
            value: true,
            onChanged: (value) {},
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
          ),
          const SizedBox(height: 8),

          // Save card for future purchases
          CheckboxListTile(
            title: const Text('Save card for future purchases'),
            value: false,
            onChanged: (value) {},
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
          ),
        ],
      ),
    );
  }

  Widget _buildCashOnDeliveryInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.surface,
        border: Border.all(
          color: Get.theme.colorScheme.onSurface.withAlpha((0.1 * 255).toInt()),
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.info_outline,
            color: Colors.blue,
            size: 28,
          ),
          const SizedBox(height: 16),
          Text(
            'Cash on Delivery',
            style: Get.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You will pay for your order when it is delivered to your doorstep. Please have the exact amount ready to ensure a smooth delivery.',
            style: Get.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.05 * 255).toInt()),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Back button (hidden on first step)
            if (controller.currentStep.value > 0)
              Expanded(
                child: SecondaryButton(
                  text: 'Back',
                  onPressed: controller.previousStep,
                ),
              ),

            // Spacing
            if (controller.currentStep.value > 0) const SizedBox(width: 16),

            // Next/Place Order button
            Expanded(
              child: PrimaryButton(
                text:
                    controller.currentStep.value == controller.steps.length - 1
                        ? 'Place Order'
                        : 'Next',
                onPressed:
                    controller.currentStep.value == controller.steps.length - 1
                        ? controller.placeOrder
                        : controller.nextStep,
                isLoading: controller.isProcessing.value,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom input formatter for credit card number
class _CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Remove any non-digits
    String value = newValue.text.replaceAll(RegExp(r'\D'), '');
    // Limit to 16 digits
    if (value.length > 16) {
      value = value.substring(0, 16);
    }

    // Add spaces after every 4 digits
    final buffer = StringBuffer();
    for (int i = 0; i < value.length; i++) {
      buffer.write(value[i]);
      if ((i + 1) % 4 == 0 && i != value.length - 1) {
        buffer.write(' ');
      }
    }

    final string = buffer.toString();
    return TextEditingValue(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}

// Custom input formatter for expiry date
class _ExpiryDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Remove non-digits
    String value = newValue.text.replaceAll(RegExp(r'\D'), '');

    // Limit to 4 digits (MMYY)
    if (value.length > 4) {
      value = value.substring(0, 4);
    }

    // Format as MM/YY
    final buffer = StringBuffer();
    for (int i = 0; i < value.length; i++) {
      buffer.write(value[i]);
      if (i == 1 && i != value.length - 1) {
        buffer.write('/');
      }
    }

    final string = buffer.toString();
    return TextEditingValue(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}
