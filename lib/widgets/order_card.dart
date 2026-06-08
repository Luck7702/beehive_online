import 'package:flutter/material.dart';
import '../utils/time_format.dart';

/// A single order on the worker side: who ordered it, where to deliver, the line
/// items to prepare, and — when [onAdvance] is provided — a button to move it to
/// the next status. Shared by the live bulletin and the completed-orders history
/// (which passes no [onAdvance], since those orders are terminal).
class OrderCard extends StatelessWidget {
  final Map<String, dynamic> order;
  final VoidCallback? onAdvance;

  const OrderCard({super.key, required this.order, this.onAdvance});

  static String nextStatus(String current) {
    switch (current) {
      case 'placed':
        return 'processed';
      case 'processed':
        return 'done';
      default:
        return current;
    }
  }

  static String statusLabel(String status) {
    switch (status) {
      case 'placed':
        return '📋 Placed';
      case 'processed':
        return '🔧 Processed';
      case 'done':
        return '✅ Done';
      case 'cancelled':
        return '❌ Cancelled';
      default:
        return status;
    }
  }

  static Color statusColor(String status) {
    switch (status) {
      case 'placed':
        return const Color(0xFFF59E0B); // amber
      case 'processed':
        return const Color(0xFF3B82F6); // blue
      case 'done':
        return const Color(0xFF10B981); // green
      case 'cancelled':
        return const Color(0xFFEF4444); // red
      default:
        return Colors.grey;
    }
  }

  static String actionButtonLabel(String status) {
    switch (status) {
      case 'placed':
        return 'Start Processing';
      case 'processed':
        return 'Mark as Done';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = order['order_status'] as String;
    final orderId = order['id'] as int;
    final studentName = order['student_name'] ?? 'Unknown';
    final studentNim = order['student_nim'] ?? '';
    final building = order['delivery_building'] ?? '';
    final floor = order['delivery_floor'] ?? '';
    final room = order['delivery_room'] ?? '';
    final totalPrice = order['total_price'] ?? 0;
    final canAdvance = onAdvance != null && (status == 'placed' || status == 'processed');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row: order id + status pill
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Order #$orderId', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor(status).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusLabel(status),
                    style: TextStyle(color: statusColor(status), fontWeight: FontWeight.w600, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _infoRow(Icons.schedule, '${formatDateTime(order['created_at'])}  ·  ${timeAgo(order['created_at'])}'),
            const SizedBox(height: 6),
            _infoRow(Icons.person_outline, '$studentName ($studentNim)'),
            const SizedBox(height: 6),
            _infoRow(Icons.location_on_outlined, '$building, Floor $floor, Room $room'),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.payments_outlined, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text('Rp $totalPrice', style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),

            // Ordered items — what the worker actually needs to prepare
            _buildItems(),

            if (canAdvance) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onAdvance,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: statusColor(nextStatus(status)),
                    foregroundColor: Colors.white,
                  ),
                  child: Text(actionButtonLabel(status), style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 6),
        Expanded(child: Text(text, style: const TextStyle(color: Colors.grey))),
      ],
    );
  }

  Widget _buildItems() {
    final items = (order['items'] as List?) ?? const [];
    if (items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 12),
        child: Text(
          'No item details available for this order.',
          style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic, fontSize: 13),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        const Divider(height: 1),
        const SizedBox(height: 10),
        const Text('Items', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 8),
        ...items.map((raw) {
          final item = raw as Map<String, dynamic>;
          final qty = (item['quantity'] as num?)?.toInt() ?? 0;
          final unit = (item['price_at_purchase'] as num?)?.toInt() ?? 0;
          final name = item['product_name']?.toString() ?? 'Unknown item';
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$qty×',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFFB45309)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(name, style: const TextStyle(fontSize: 14))),
                Text('Rp ${unit * qty}', style: const TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
          );
        }),
      ],
    );
  }
}
