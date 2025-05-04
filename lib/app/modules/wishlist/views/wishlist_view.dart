import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecommerce_app/app/components/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/wishlist_controller.dart';
import 'package:ecommerce_app/app/widgets/keyboard_dismisser.dart';

class WishlistView extends GetView<WishlistController> {
  const WishlistView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return KeyboardDismisser(
      child: Scaffold(
        appBar: AppBar(
          title: Text('my_wishlist'.tr),
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: LoadingIndicator(),
            );
          }
          
          if (controller.wishlistItems.isEmpty) {
            return _buildEmptyWishlist();
          }
          
          return _buildWishlistItems();
        }),
      ),
    );
  }
  
  Widget _buildEmptyWishlist() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 72,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'empty_wishlist_title'.tr,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'empty_wishlist_message'.tr,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Get.back(),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: Text('browse_products'.tr),
          ),
        ],
      ),
    );
  }
  
  Widget _buildWishlistItems() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: controller.wishlistItems.length,
      separatorBuilder: (context, index) => const Divider(height: 32),
      itemBuilder: (context, index) {
        final item = controller.wishlistItems[index];
        return _buildWishlistItemCard(item);
      },
    );
  }
  
  Widget _buildWishlistItemCard(item) {
    print(item.toJson());
    final bool isOnSale = item.discountedPrice != null;
    
    return InkWell(
      onTap: () => controller.goToProductDetail(item.productId),
      borderRadius: BorderRadius.circular(8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: item.imageUrl,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.grey[200],
                child: const Center(
                  child: LoadingIndicator(),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[200],
                child: const Icon(Icons.image_not_supported, size: 40),
              ),
            ),
          ),
          const SizedBox(width: 16),
          
          // Product details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                
                // Price information
                Row(
                  children: [
                    Text(
                      isOnSale 
                          ? 'product_price'.tr.replaceAll('@price', item.discountedPrice!.toStringAsFixed(2))
                          : 'product_price'.tr.replaceAll('@price', item.price.toStringAsFixed(2)),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Get.theme.colorScheme.primary,
                      ),
                    ),
                    if (isOnSale)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          'product_price'.tr.replaceAll('@price', item.price.toStringAsFixed(2)),
                          style: const TextStyle(
                            fontSize: 14,
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Action buttons
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: ElevatedButton.icon(
                        onPressed: () => controller.removeFromWishlist(item.id),
                        icon: const Icon(Icons.delete_outline, size: 16),
                        label: Text('remove'.tr, style: const TextStyle(fontSize: 12)),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: ElevatedButton.icon(
                        onPressed: () => controller.goToProductDetail(item.productId),
                        icon: const Icon(Icons.shopping_bag_outlined, size: 16),
                        label: Text('view'.tr, style: const TextStyle(fontSize: 12)),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
}