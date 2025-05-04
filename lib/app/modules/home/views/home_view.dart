import 'package:ecommerce_app/app/modules/cart/controllers/cart_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:ecommerce_app/app/components/inputs/custom_text_field.dart';
import 'package:ecommerce_app/app/modules/home/controllers/home_controller.dart';
import 'package:ecommerce_app/app/routes/app_pages.dart';
import 'package:ecommerce_app/app/widgets/keyboard_dismisser.dart';
import 'package:ecommerce_app/app/data/models/product_model.dart';
import 'package:shimmer/shimmer.dart';
import 'package:badges/badges.dart' as badges;
import 'package:ecommerce_app/app/components/badges/rating_badge.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return KeyboardDismisser(
      child: Scaffold(
        appBar: _buildAppBar(),
        body: RefreshIndicator(
          onRefresh: () async => controller.refreshData(),
          child: Obx(() {
            if (controller.isSearching.value) {
              return _buildSearchResults();
            }
            return _buildHomeContent();
          }),
        ),
        bottomNavigationBar: _buildBottomNavBar(),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Obx(() {
        if (controller.isSearching.value) {
          return CustomTextField(
            controller: controller.searchController,
            hintText: 'search_products'.tr,
            prefixIcon: const Icon(Icons.search),
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear),
              onPressed: controller.clearSearch,
            ),
            textInputAction: TextInputAction.search,
          );
        }
        return Text('app_name'.tr);
      }),
      actions: [
        Obx(() {
          if (!controller.isSearching.value) {
            return IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => controller.isSearching.value = true,
            );
          }
          return const SizedBox.shrink();
        }),
        Obx(() {
          final cartController = Get.find<CartController>();
          final count = cartController.cartItemCount.value;

          return badges.Badge(
            showBadge: count > 0, // Only show badge if count > 0
            position: badges.BadgePosition.topEnd(top: 5, end: 5),
            badgeContent: Text(
              '$count', // Display the actual count
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
            child: IconButton(
              icon: const Icon(Icons.shopping_cart_outlined),
              onPressed: () => Get.toNamed(Routes.cart),
            ),
          );
        }),
        IconButton(
          icon: const Icon(Icons.person_outline),
          onPressed: () {
            // Show account menu
            showModalBottomSheet(
              context: Get.context!,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              builder: (context) => _buildAccountMenu(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAccountMenu() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.shopping_bag_outlined),
            title: Text('my_orders'.tr),
            onTap: () {
              Get.back();
              Get.toNamed(Routes.orders);
            },
          ),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: Text('my_profile'.tr),
            onTap: () {
              Get.back(); // Close the drawer
              Get.toNamed(Routes.profile);
            },
          ),
          ListTile(
            leading: const Icon(Icons.favorite_border),
            title: Text('wishlist'.tr),
            onTap: () {
              Get.back(); // Close the drawer
              Get.toNamed(Routes.wishlist);
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: Text('settings'.tr),
            onTap: () {
              Get.back(); // Close the drawer
              Get.toNamed(Routes.settings);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: Text('logout'.tr, style: const TextStyle(color: Colors.red)),
            onTap: () {
              Get.back();
              controller.logout();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHomeContent() {
    return Obx(() {
      if (controller.isLoading.value) {
        return _buildLoadingShimmer();
      }

      return ListView(
        controller: controller.scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 10),
        children: [
          _buildHeroSlider(),
          const SizedBox(height: 24),
          _buildSectionTitle('categories'.tr),
          const SizedBox(height: 8),
          _buildCategoriesRow(),
          const SizedBox(height: 24),
          _buildSectionTitle('featured_products'.tr),
          const SizedBox(height: 8),
          _buildFeaturedProductsGrid(),
          const SizedBox(height: 24),
          _buildSectionTitle('new_arrivals'.tr),
          const SizedBox(height: 8),
          _buildNewArrivalsGrid(),
          const SizedBox(height: 32),
        ],
      );
    });
  }

  Widget _buildLoadingShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            height: 180,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 100,
                  height: 20,
                  color: Colors.white,
                ),
                Container(
                  width: 50,
                  height: 20,
                  color: Colors.white,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (_, __) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Container(
                  width: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 150,
                  height: 20,
                  color: Colors.white,
                ),
                Container(
                  width: 50,
                  height: 20,
                  color: Colors.white,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemBuilder: (_, __) => Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSlider() {
    return Obx(() {
      if (controller.featuredProducts.isEmpty) {
        return const SizedBox.shrink();
      }

      return CarouselSlider(
        options: CarouselOptions(
          height: 200,
          viewportFraction: 0.9,
          initialPage: 0,
          enableInfiniteScroll: true,
          autoPlay: true,
          autoPlayInterval: const Duration(seconds: 4),
          autoPlayAnimationDuration: const Duration(milliseconds: 800),
          enlargeCenterPage: true,
        ),
        items: controller.featuredProducts.take(5).map((product) {
          return Builder(
            builder: (BuildContext context) {
              return GestureDetector(
                onTap: () => Get.toNamed(
                  Routes.productDetail,
                  arguments: product.id,
                ),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.symmetric(horizontal: 5.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Stack(
                    children: [
                      // Product image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          product.imageUrls[0],
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      // Gradient overlay
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Color.fromRGBO(0, 0, 0, 0.7),
                            ],
                          ),
                        ),
                      ),
                      // Product info
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    '\$${product.currentPrice.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (product.isOnSale)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                      child: Text(
                                        '\$${product.price.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 14,
                                          decoration:
                                              TextDecoration.lineThrough,
                                        ),
                                      ),
                                    ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'shop_now'.tr,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Sale badge
                      if (product.isOnSale)
                        Positioned(
                          top: 16,
                          left: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${product.discountPercentage?.toInt() ?? 0}% ${'off'.tr}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        }).toList(),
      );
    });
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title.tr,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          TextButton(
            onPressed: () {
              // Navigate to all products or categories
            },
            child: Text(
              'see_all'.tr,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesRow() {
    return SizedBox(
      height: 100,
      child: Obx(() {
        if (controller.categories.isEmpty) {
          return Center(
            child: Text('no_categories_available'.tr),
          );
        }

        return ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: controller.categories.length,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemBuilder: (context, index) {
            final category = controller.categories[index];
            final isSelected = controller.selectedCategoryIndex.value == index;

            return GestureDetector(
              onTap: () => controller.selectCategory(index),
              child: Container(
                width: 80,
                margin: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context)
                          .colorScheme
                          .primary
                          .withAlpha((0.1 * 255).toInt())
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).dividerColor,
                    width: 1.5,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: NetworkImage(category.imageUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      category.name,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildFeaturedProductsGrid() {
    return Obx(() {
      if (controller.featuredProducts.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text('no_featured_products'.tr),
          ),
        );
      }

      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio:
                0.65, // Changed from 0.75 to 0.65 for more vertical space
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: controller.featuredProducts.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemBuilder: (context, index) {
            final product = controller.featuredProducts[index];
            return _buildProductCard(product);
          },
        ),
      );
    });
  }

  Widget _buildNewArrivalsGrid() {
    return Obx(() {
      if (controller.newArrivals.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text('no_new_arrivals'.tr),
          ),
        );
      }

      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio:
                0.65, // Changed from 0.75 to 0.65 for more vertical space
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: controller.newArrivals.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemBuilder: (context, index) {
            final product = controller.newArrivals[index];
            return _buildProductCard(product);
          },
        ),
      );
    });
  }

  Widget _buildProductCard(ProductModel product) {
    return GestureDetector(
      onTap: () => Get.toNamed(
        Routes.productDetail,
        arguments: product.id,
      ),
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image with rating badge
            Stack(
              children: [
                // Product image
                AspectRatio(
                  aspectRatio: 1,
                  child: _buildProductImage(product.imageUrls[0]),
                ),

                // Show rating badge if there are reviews
                if (product.reviewCount > 0)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: RatingBadge(
                      rating: product.rating,
                    ),
                  ),

                // Show discount badge if on sale
                if (product.isOnSale)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${product.discountPercentage?.toInt()}% ${'off'.tr}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // Rest of the card remains the same
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      product.categoryName,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Text(
                          '\$${product.currentPrice.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Theme.of(Get.context!).colorScheme.primary,
                          ),
                        ),
                        if (product.isOnSale)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Text(
                              '\$${product.price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 12,
                                decoration: TextDecoration.lineThrough,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage(String? imageUrl) {
    // Check if URL is valid
    bool isValidUrl = imageUrl != null &&
        imageUrl.isNotEmpty &&
        (imageUrl.startsWith('http://') || imageUrl.startsWith('https://'));

    if (!isValidUrl) {
      // Return placeholder if URL is invalid
      return Container(
        color: Colors.grey[300],
        child: const Center(
          child: Icon(Icons.image, size: 50, color: Colors.grey),
        ),
      );
    }

    // If URL is valid, load the image with error handling
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                : null,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        // Fallback for runtime errors
        return Container(
          color: Colors.grey[300],
          child: const Center(
            child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
          ),
        );
      },
    );
  }

  Widget _buildSearchResults() {
    return Obx(() {
      if (controller.searchQuery.value.length < 2) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search,
                size: 80,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 16),
              Text(
                'type_at_least_two_characters'.tr,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
            ],
          ),
        );
      }

      if (controller.searchResults.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off,
                size: 80,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 16),
              Text(
                '${'no_products_found'.tr} "${controller.searchQuery.value}"',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
            ],
          ),
        );
      }

      return ListView.separated(
        itemCount: controller.searchResults.length,
        padding: const EdgeInsets.all(16),
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          final product = controller.searchResults[index];
          return ListTile(
            contentPadding:
                const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                product.imageUrls[0],
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
            ),
            title: Text(
              product.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.categoryName,
                  style: const TextStyle(fontSize: 12),
                ),

                // Show rating if available
                if (product.reviewCount > 0)
                  Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.star,
                            size: 14,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            product.rating.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                          ),
                          if (product.isOnSale)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Text(
                                '\$${product.price.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  decoration: TextDecoration.lineThrough,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                        ],
                      )),
              ],
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => Get.toNamed(
              Routes.productDetail,
              arguments: product.id,
            ),
          );
        },
      );
    });
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: 0,
      type: BottomNavigationBarType.fixed,
      onTap: (index) {
        switch (index) {
          case 0: // Home - already here
            break;
          case 1: // Categories
            // Show categories screen or modal
            break;
          case 2: // Cart
            Get.toNamed(Routes.cart);
            break;
          case 3: // Profile/Account
            showModalBottomSheet(
              context: Get.context!,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              builder: (context) => _buildAccountMenu(),
            );
            break;
        }
      },
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.home_outlined),
          activeIcon: const Icon(Icons.home),
          label: 'home'.tr,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.category_outlined),
          activeIcon: const Icon(Icons.category),
          label: 'categories'.tr,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.shopping_cart_outlined),
          activeIcon: const Icon(Icons.shopping_cart),
          label: 'cart'.tr,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.person_outline),
          activeIcon: const Icon(Icons.person),
          label: 'account'.tr,
        ),
      ],
    );
  }
}
