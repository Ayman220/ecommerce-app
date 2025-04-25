import 'package:ecommerce_app/app/components/buttons/primary_button.dart';
import 'package:ecommerce_app/app/components/buttons/secondary_button.dart';
import 'package:ecommerce_app/app/data/models/cart_item_model.dart';
import 'package:ecommerce_app/app/modules/cart/controllers/cart_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CartView extends GetView<CartController> {
  const CartView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Bag'),
        actions: [
          Obx(() {
            if (controller.cartItems.isEmpty) {
              return const SizedBox.shrink();
            }
            
            return IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: controller.clearCart,
              tooltip: 'Clear bag',
            );
          }),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
          );
        }
        
        if (controller.cartItems.isEmpty) {
          return _buildEmptyCart();
        }
        
        return _buildCartContent();
      }),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          // Use an elegant shopping bag icon
          Icon(
            Icons.shopping_bag_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 32),
          Text(
            'Your shopping bag is empty',
            style: Get.textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Text(
            'Items you add to your bag will appear here',
            style: Get.textTheme.bodyMedium?.copyWith(
              color: Get.theme.colorScheme.onSurface.withAlpha((0.6 * 255).toInt()),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: 200,
            child: PrimaryButton(
              text: 'Start Shopping',
              onPressed: controller.continueShopping,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartContent() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                // Display number of items
                Text(
                  '${controller.cartItems.length} ${controller.cartItems.length == 1 ? 'Item' : 'Items'}',
                  style: Get.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Cart items list
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.cartItems.length,
                  separatorBuilder: (_, __) => const Divider(height: 48),
                  itemBuilder: (context, index) {
                    final item = controller.cartItems[index];
                    return _buildCartItem(item);
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Summary section
                _buildOrderSummary(),
                
                const SizedBox(height: 16),
                
                // Checkout button
                SizedBox(
                  width: double.infinity,
                  child: PrimaryButton(
                    text: 'Proceed to Checkout',
                    onPressed: controller.proceedToCheckout,
                    isLoading: controller.isProcessingCheckout.value,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Continue shopping button
                SizedBox(
                  width: double.infinity,
                  child: SecondaryButton(
                    text: 'Continue Shopping',
                    onPressed: controller.continueShopping,
                  ),
                ),
                
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCartItem(CartItemModel item) {
    return Dismissible(
      key: Key('cart-item-${item.id}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => controller.removeItem(item.id),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(
          Icons.delete_outline,
          color: Colors.white,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image
          GestureDetector(
            onTap: () => Get.toNamed('/product-detail', arguments: item.productId),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: CachedNetworkImage(
                imageUrl: item.image,
                width: 100,
                height: 130,
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
          ),
          
          const SizedBox(width: 16),
          
          // Product details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: Get.textTheme.titleMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 8),
                
                if (item.size != null || item.color != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      [
                        if (item.size != null) 'Size: ${item.size}',
                        if (item.color != null) 'Color: ${item.color}',
                      ].join(' • '),
                      style: Get.textTheme.bodySmall,
                    ),
                  ),
                
                Text(
                  '\$${item.price.toStringAsFixed(2)}',
                  style: Get.textTheme.titleMedium?.copyWith(
                    color: Get.theme.colorScheme.secondary,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Quantity selector
                Row(
                  children: [
                    Text(
                      'Quantity:',
                      style: Get.textTheme.bodySmall,
                    ),
                    const SizedBox(width: 16),
                    _buildQuantitySelector(item),
                    // Reduced the spacing here
                    const SizedBox(width: 4),
                    
                    // Remove button - made more compact
                    InkWell(
                      onTap: () => controller.removeItem(item.id),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: const Icon(
                          Icons.delete_outline,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantitySelector(CartItemModel item) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Get.theme.colorScheme.onSurface.withAlpha((0.2 * 255).toInt()),
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildQuantityButton(
            icon: Icons.remove,
            onPressed: () => controller.updateQuantity(
              item.id, 
              item.quantity - 1,
            ),
          ),
          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              '${item.quantity}',
              style: Get.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          
          _buildQuantityButton(
            icon: Icons.add,
            onPressed: () => controller.updateQuantity(
              item.id, 
              item.quantity + 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Icon(
          icon,
          size: 16,
          color: Get.theme.colorScheme.onSurface,
        ),
      ),
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
            style: isTotal
                ? Get.textTheme.titleMedium
                : Get.textTheme.bodyMedium,
          ),
          Text(
            value,
            style: valueStyle ?? (isTotal
                ? Get.textTheme.titleMedium?.copyWith(
                    color: Get.theme.colorScheme.secondary,
                  )
                : Get.textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
