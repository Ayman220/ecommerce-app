import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecommerce_app/app/components/badges/rating_badge.dart';
import 'package:ecommerce_app/app/components/buttons/primary_button.dart';
import 'package:ecommerce_app/app/components/buttons/secondary_button.dart';
import 'package:ecommerce_app/app/data/models/review_model.dart';
import 'package:ecommerce_app/app/modules/product/controllers/product_controller.dart';
import 'package:ecommerce_app/app/modules/wishlist/controllers/wishlist_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class ProductDetailView extends GetView<ProductController> {
  const ProductDetailView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildLoadingShimmer();
        }
        
        if (controller.product.value == null) {
          return const Center(child: Text('Product not available'));
        }
        
        return CustomScrollView(
          slivers: [
            _buildAppBar(),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildImageGallery(),
                  _buildProductInfo(),
                  const Divider(),
                  if (_hasSpecifications())
                    _buildSpecifications(),
                  const Divider(),
                  _buildDescription(),
                  const Divider(),
                  _buildReviewsSection(),
                  const Divider(), 
                  _buildRelatedProducts(),
                  const SizedBox(height: 100), // Space for bottom bar
                ],
              ),
            ),
          ],
        );
      }),
      bottomSheet: Obx(() {
        if (controller.isLoading.value || controller.product.value == null) {
          return const SizedBox.shrink();
        }
        return _buildBottomBar();
      }),
    );
  }

  Widget _buildLoadingShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image area
            Container(
              height: 300,
              color: Colors.white,
            ),
            
            // Title and price
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 24,
                    width: double.infinity,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 16,
                    width: 100,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 20,
                    width: 80,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
            
            const Divider(),
            
            // Description
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 20,
                    width: 100,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 100,
                    width: double.infinity,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 0,
      floating: true,
      pinned: true,
      title: Text(
        controller.product.value?.name ?? 'Product Details',
        style: const TextStyle(
          fontSize: 18,
        ),
      ),
      actions: [
        IconButton(
          icon: Obx(() => Icon(
            controller.isFavorite.value 
                ? Icons.favorite 
                : Icons.favorite_border,
            color: controller.isFavorite.value 
                ? Colors.red 
                : null,
          )),
          onPressed: () {
            final product = controller.product.value;
            final productId = controller.productId ?? '';
            
            if (product != null && productId.isNotEmpty) {
              // Create product data for wishlist
              final productData = {
                'name': product.name,
                'images': product.imageUrls,
                'price': product.price,
                'discountedPrice': product.isOnSale ? product.currentPrice : null,
                'isAvailable': product.isInStock,
              };
              
              // Try to find the wishlist controller
              try {
                final wishlistController = Get.find<WishlistController>();
                wishlistController.toggleWishlistStatus(productId, productData);
                // Update local favorite state to match
                controller.toggleFavorite();
              } catch (e) {
                // If wishlist controller not found, use the built-in toggle
                controller.toggleFavorite();
              }
            }
          },
          tooltip: 'Add to Wishlist',
        ),
      ],
    );
  }

  Widget _buildImageGallery() {
    final product = controller.product.value!;
    
    return Column(
      children: [
        // Main image slider
        SizedBox(
          height: 300,
          child: PageView.builder(
            controller: controller.pageController,
            itemCount: product.imageUrls.length,
            onPageChanged: (index) {
              controller.selectedImageIndex.value = index;
            },
            itemBuilder: (context, index) {
              return CachedNetworkImage(
                imageUrl: product.imageUrls[index],
                fit: BoxFit.cover,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(),
                ),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              );
            },
          ),
        ),
        
        // Thumbnail row
        if (product.imageUrls.length > 1)
          Container(
            height: 70,
            margin: const EdgeInsets.only(top: 10),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: product.imageUrls.length,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => controller.changeImage(index),
                  child: Container(
                    width: 60,
                    height: 60,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: controller.selectedImageIndex.value == index
                            ? Theme.of(context).primaryColor
                            : Colors.grey[300]!,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: CachedNetworkImage(
                        imageUrl: product.imageUrls[index],
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildProductInfo() {
    final product = controller.product.value!;
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product name
          Text(
            product.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 4),
          
          // Category
          Text(
            product.categoryName,
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Rating
          Row(
            children: [
              RatingBarIndicator(
                rating: product.rating,
                itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                itemCount: 5,
                itemSize: 18.0,
              ),
              const SizedBox(width: 8),
              Text(
                '(${product.reviewCount} reviews)',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Price
          Row(
            children: [
              Text(
                '\$${product.currentPrice.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(Get.context!).primaryColor,
                ),
              ),
              if (product.isOnSale)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      decoration: TextDecoration.lineThrough,
                      color: Colors.grey,
                    ),
                  ),
                ),
              if (product.isOnSale)
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6, 
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${product.discountPercentage?.toInt()}% OFF',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Stock status
          Row(
            children: [
              Icon(
                product.isInStock
                    ? Icons.check_circle
                    : Icons.error,
                color: product.isInStock
                    ? Colors.green
                    : Colors.red,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                product.isInStock
                    ? 'In Stock (${product.stock} available)'
                    : 'Out of Stock',
                style: TextStyle(
                  color: product.isInStock
                      ? Colors.green
                      : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          // Quantity selector
          if (product.isInStock) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                const Text(
                  'Quantity:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 16),
                _buildQuantitySelector(),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuantitySelector() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: controller.decrementQuantity,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 36,
              minHeight: 36,
            ),
          ),
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: Colors.grey[300]!),
                right: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: Obx(() => Text(
              '${controller.quantity.value}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            )),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: controller.incrementQuantity,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 36,
              minHeight: 36,
            ),
          ),
        ],
      ),
    );
  }

  bool _hasSpecifications() {
    final product = controller.product.value!;
    return product.specifications != null && 
           (product.specifications!.containsKey('sizes') || 
            product.specifications!.containsKey('colors'));
  }

  Widget _buildSpecifications() {
    final product = controller.product.value!;
    final specs = product.specifications!;
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Specifications',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Sizes
          if (specs.containsKey('sizes') && specs['sizes'] is List) ...[
            const Text(
              'Size:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Obx(() => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: (specs['sizes'] as List).map((size) {
                final isSelected = controller.selectedSize.value == size.toString();
                return GestureDetector(
                  onTap: () => controller.selectSize(size.toString()),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(Get.context!).primaryColor
                          : Colors.transparent,
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(Get.context!).primaryColor
                            : Colors.grey[300]!,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      size.toString(),
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            )),
            const SizedBox(height: 16),
          ],
          
          // Colors
          if (specs.containsKey('colors') && specs['colors'] is List) ...[
            const Text(
              'Color:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Obx(() => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: (specs['colors'] as List).map((color) {
                final isSelected = controller.selectedColor.value == color.toString();
                return GestureDetector(
                  onTap: () => controller.selectColor(color.toString()),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(Get.context!).primaryColor
                          : Colors.transparent,
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(Get.context!).primaryColor
                            : Colors.grey[300]!,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      color.toString(),
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            )),
          ],
        ],
      ),
    );
  }

  Widget _buildDescription() {
    final product = controller.product.value!;
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Description',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            product.description,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Reviews',
                    style: Get.textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Obx(() {
                    if (controller.canReview.value && !controller.hasReviewed.value) {
                      return ElevatedButton.icon(
                        onPressed: () => _showReviewDialog(),
                        icon: const Icon(Icons.rate_review),
                        label: const Text('Write a Review'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Get.theme.primaryColor,
                          foregroundColor: Colors.white,
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                ],
              ),
              const SizedBox(height: 8),
              Obx(() {
                final reviewCount = controller.product.value?.reviewCount ?? 0;
                final rating = controller.product.value?.rating ?? 0.0;
                
                return Row(
                  children: [
                    Text(
                      rating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: List.generate(
                            5,
                            (index) => Icon(
                              index < rating.floor()
                                  ? Icons.star
                                  : index < rating.ceil() && index >= rating.floor()
                                      ? Icons.star_half
                                      : Icons.star_outline,
                              color: Colors.amber,
                              size: 20,
                            ),
                          ),
                        ),
                        Text('$reviewCount ${reviewCount == 1 ? 'review' : 'reviews'}'),
                      ],
                    ),
                  ],
                );
              }),
              const SizedBox(height: 16),
              Obx(() {
                if (controller.reviews.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 24.0),
                      child: Text('No reviews yet. Be the first to review!'),
                    ),
                  );
                }
                
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.reviews.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final review = controller.reviews[index];
                    return _buildReviewItem(review);
                  },
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewItem(ReviewModel review) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundImage: review.userAvatar != null
                    ? NetworkImage(review.userAvatar!)
                    : null,
                radius: 18,
                child: review.userAvatar == null
                    ? Text(review.userName[0].toUpperCase())
                    : null,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    review.userName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    _formatReviewDate(review.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Row(
                children: List.generate(
                  5,
                  (index) => Icon(
                    index < review.rating
                        ? Icons.star
                        : Icons.star_outline,
                    color: Colors.amber,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(review.text),
        ],
      ),
    );
  }

  String _formatReviewDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays < 1) {
      if (difference.inHours < 1) {
        return '${difference.inMinutes} minutes ago';
      }
      return '${difference.inHours} hours ago';
    }
    if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    }
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showReviewDialog() {
    showDialog(
      context: Get.context!,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Write a Review',
                  style: Get.textTheme.headlineMedium,
                ),
                const SizedBox(height: 16),
                
                // Modified star rating - using more space-efficient approach
                Obx(() => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    5,
                    (index) => InkWell(
                      onTap: () {
                        controller.reviewRating.value = index + 1.0;
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Icon(
                          index < controller.reviewRating.value
                              ? Icons.star
                              : Icons.star_outline,
                          color: Colors.amber,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                )),
                
                const SizedBox(height: 16),
                TextField(
                  controller: controller.reviewTextController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'Share your experience with this product...',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    Obx(() => ElevatedButton(
                      onPressed: controller.isSubmittingReview.value
                          ? null
                          : () {
                              Get.back();
                              controller.submitReview();
                            },
                      child: controller.isSubmittingReview.value
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Submit'),
                    )),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRelatedProducts() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'You May Also Like',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 220,
            child: Obx(() {
              if (controller.relatedProducts.isEmpty) {
                return const Center(
                  child: Text('No related products'),
                );
              }
              
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: controller.relatedProducts.length,
                itemBuilder: (context, index) {
                  final product = controller.relatedProducts[index];
                  return GestureDetector(
                    onTap: () {
                      Get.offAndToNamed(
                        '/product-detail',
                        arguments: product.id,
                      );
                    },
                    child: Container(
                      width: 160,
                      margin: const EdgeInsets.only(right: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Image with rating badge
                          Stack(
                            children: [
                              // Product image
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: CachedNetworkImage(
                                  imageUrl: product.imageUrls[0],
                                  height: 120,
                                  width: 160,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              
                              // Rating badge (show only if there are reviews)
                              if (product.reviewCount > 0)
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: RatingBadge(
                                    rating: product.rating,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Name
                          Text(
                            product.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Price
                          Text(
                            '\$${product.currentPrice.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha((0.1 * 255).toInt()),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: SecondaryButton(
                text: 'Add to Cart',
                onPressed: controller.addToCart,
                isLoading: controller.isAddingToCart.value,
                height: 48,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: PrimaryButton(
                text: 'Buy Now',
                onPressed: controller.buyNow,
                isLoading: controller.isAddingToCart.value,
                height: 48,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // String _formatDate(DateTime date) {
  //   return '${date.day}/${date.month}/${date.year}';
  // }
}