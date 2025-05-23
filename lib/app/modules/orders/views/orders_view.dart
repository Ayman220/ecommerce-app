import 'package:ecommerce_app/app/components/empty_state.dart';
import 'package:ecommerce_app/app/components/loading_indicator.dart';
import 'package:ecommerce_app/app/data/models/order_model.dart';
import 'package:ecommerce_app/app/modules/orders/controllers/orders_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecommerce_app/app/routes/app_pages.dart';
import 'package:intl/intl.dart';

class OrdersView extends GetView<OrdersController> {
  const OrdersView({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('my_orders'.tr),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOrderFilters(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: LoadingIndicator());
              }
              
              if (controller.orders.isEmpty) {
                return EmptyState(
                  icon: Icons.shopping_bag_outlined,
                  title: 'no_orders_found'.tr,
                  subtitle: 'no_orders_yet'.tr,
                  buttonText: 'start_shopping'.tr,
                  onButtonPressed: () => Get.offAllNamed(Routes.home),
                );
              }
              
              return RefreshIndicator(
                onRefresh: () async {
                  controller.loadOrders();
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.orders.length,
                  itemBuilder: (context, index) {
                    return _buildOrderCard(controller.orders[index]);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
  
  Widget _buildOrderFilters() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      scrollDirection: Axis.horizontal,
      child: Obx(() => Row(
        children: [
          _filterChip('filter_all'.tr, 'all'),
          _filterChip('filter_pending'.tr, 'pending'),
          _filterChip('filter_processing'.tr, 'processing'),
          _filterChip('filter_shipped'.tr, 'shipped'),
          _filterChip('filter_delivered'.tr, 'delivered'),
          _filterChip('filter_cancelled'.tr, 'cancelled'),
        ],
      )),
    );
  }
  
  Widget _filterChip(String label, String value) {
    final isSelected = controller.selectedFilter.value == value;
    
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => controller.setFilter(value),
        selectedColor: Get.theme.colorScheme.primary.withAlpha((0.1 * 255).toInt()),
        labelStyle: TextStyle(
          color: isSelected 
              ? Get.theme.colorScheme.primary
              : Get.theme.colorScheme.onSurface,
          fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
        ),
        checkmarkColor: Get.theme.colorScheme.primary,
        side: BorderSide(
          color: isSelected 
              ? Get.theme.colorScheme.primary
              : Get.theme.colorScheme.secondary.withAlpha((0.5 * 255).toInt()),
          width: isSelected ? 1.5 : 1.0,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
  
  Widget _buildOrderCard(OrderModel order) {
    final currencyFormatter = NumberFormat.currency(symbol: '\$');
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: Theme.of(Get.context!).colorScheme.primary,
        ),
      ),
      child: InkWell(
        onTap: () => controller.viewOrderDetails(order.id),
        child: Column(
          children: [
            // Order header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(Get.context!).colorScheme.secondary.withAlpha((0.1 * 255).toInt()),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'order_number'.tr.replaceAll('@id', order.id.substring(0, 8).toUpperCase()),
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'order_date'.tr.replaceAll('@date', DateFormat('MMM dd, yyyy').format(order.createdAt)),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  _buildStatusChip(order.status),
                ],
              ),
            ),
            
            // Order items preview
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: order.items.length > 2 ? 2 : order.items.length,
              itemBuilder: (context, index) {
                final item = order.items[index];
                return ListTile(
                  dense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      image: DecorationImage(
                        image: NetworkImage(item.image),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  title: Text(
                    item.name,
                    style: const TextStyle(fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    '${item.size ?? ''} ${item.color ?? ''}'.trim(),
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: Text(
                    'item_quantity_price'.tr.replaceAll('@quantity', item.quantity.toString())
                        .replaceAll('@price', currencyFormatter.format(item.price)),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              },
            ),
            
            // Show if there are more items
            if (order.items.length > 2)
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
                child: Text(
                  'more_items'.tr.replaceAll('@count', (order.items.length - 2).toString()),
                  style: TextStyle(
                    fontSize: 12,
                    color: Get.theme.colorScheme.primary,
                  ),
                ),
              ),
            
            // Total and action buttons
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Colors.grey[200]!,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'total_label'.tr,
                        style: const TextStyle(fontSize: 12),
                      ),
                      Text(
                        'total_price'.tr.replaceAll('@price', currencyFormatter.format(order.total)),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      if (order.status == 'pending')
                        OutlinedButton(
                          onPressed: () {
                            _showCancelConfirmation(order.id);
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                          ),
                          child: Text('cancel_button'.tr),
                        ),
                      const SizedBox(width: 8),
                      FilledButton.tonal(
                        onPressed: () => controller.viewOrderDetails(order.id),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        child: Text('details_button'.tr),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatusChip(String status) {
    Color chipColor;
    IconData chipIcon;
    
    switch (status.toLowerCase()) {
      case 'pending':
        chipColor = Colors.blue;
        chipIcon = Icons.hourglass_empty;
        break;
      case 'processing':
        chipColor = Colors.orange;
        chipIcon = Icons.sync;
        break;
      case 'shipped':
        chipColor = Colors.indigo;
        chipIcon = Icons.local_shipping;
        break;
      case 'delivered':
        chipColor = Colors.green;
        chipIcon = Icons.check_circle;
        break;
      case 'cancelled':
        chipColor = Colors.red;
        chipIcon = Icons.cancel;
        break;
      default:
        chipColor = Colors.grey;
        chipIcon = Icons.help_outline;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withAlpha((0.1 * 255).toInt()),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            chipIcon,
            size: 12,
            color: chipColor,
          ),
          const SizedBox(width: 4),
          Text(
            _getStatusLabel(status),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: chipColor,
            ),
          ),
        ],
      ),
    );
  }
  
  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'status_pending'.tr;
      case 'processing':
        return 'status_processing'.tr;
      case 'shipped':
        return 'status_shipped'.tr;
      case 'delivered':
        return 'status_delivered'.tr;
      case 'cancelled':
        return 'status_cancelled'.tr;
      default:
        return 'status_unknown'.tr;
    }
  }
  
  void _showCancelConfirmation(String orderId) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Colors.amber,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'cancel_order_title'.tr,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'cancel_order_message'.tr,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // Use a column instead of a row for the buttons
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FilledButton(
                    onPressed: () async {
                      Get.back();
                      await controller.cancelOrder(orderId);
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: Text('yes_cancel_order'.tr),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => Get.back(),
                    child: Text('no_keep_order'.tr),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}