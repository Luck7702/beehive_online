import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/time_format.dart';

class WorkerBulletinScreen extends StatefulWidget {
  const WorkerBulletinScreen({super.key});

  @override
  State<WorkerBulletinScreen> createState() => _WorkerBulletinScreenState();
}

class _WorkerBulletinScreenState extends State<WorkerBulletinScreen> {
  late Future<List<Map<String, dynamic>>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _ordersFuture = ApiService.getOrders();
  }

  void _refreshOrders() {
    setState(() {
      _ordersFuture = ApiService.getOrders();
    });
  }

  String _nextStatus(String current) {
    switch (current) {
      case 'placed':
        return 'processed';
      case 'processed':
        return 'done';
      default:
        return current;
    }
  }

  String _statusLabel(String status) {
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

  Color _statusColor(String status) {
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

  String _actionButtonLabel(String status) {
    switch (status) {
      case 'placed':
        return 'Start Processing';
      case 'processed':
        return 'Mark as Done';
      default:
        return '';
    }
  }

  Future<void> _advanceOrder(int orderId, String currentStatus) async {
    final next = _nextStatus(currentStatus);
    final success = await ApiService.updateOrderStatus(orderId, next);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order #$orderId updated to ${_statusLabel(next)}'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 1),
        ),
      );
      _refreshOrders();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update order')),
      );
    }
  }

  Future<void> _verifyPayment(int orderId, String status) async {
    final success = await ApiService.verifyPayment(orderId, status);
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment marked as $status')),
      );
      _refreshOrders();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update payment status')),
      );
    }
  }

  void _showProofFullScreen(String proofUrl, int orderId) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.all(12),
        child: Stack(
          children: [
            InteractiveViewer(
              minScale: 0.5,
              maxScale: 4,
              child: Center(
                child: Image.network(
                  proofUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (ctx, child, progress) => progress == null
                      ? child
                      : const SizedBox(height: 200, child: Center(child: CircularProgressIndicator())),
                  errorBuilder: (ctx, err, stack) => const Padding(
                    padding: EdgeInsets.all(40),
                    child: Icon(Icons.broken_image, size: 64, color: Colors.white54),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Positioned(
              bottom: 8,
              left: 12,
              child: Text('Order #$orderId payment proof',
                  style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Bulletin', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshOrders,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ApiService.logout();
              Navigator.pushNamedAndRemoveUntil(context, '/welcome', (route) => false);
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: _refreshOrders, child: const Text('Retry')),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No orders yet', style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            );
          }

          final orders = snapshot.data!;

          // Group orders by status for bulletin layout
          final awaitingVerification = orders.where((o) => o['payment_status'] == 'awaiting_verification').toList();
          final placedOrders = orders.where((o) => o['order_status'] == 'placed').toList();
          final processedOrders = orders.where((o) => o['order_status'] == 'processed').toList();
          final doneOrders = orders.where((o) => o['order_status'] == 'done').toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary cards
                Row(
                  children: [
                    _buildSummaryCard('Placed', placedOrders.length, const Color(0xFFF59E0B)),
                    const SizedBox(width: 12),
                    _buildSummaryCard('Processing', processedOrders.length, const Color(0xFF3B82F6)),
                    const SizedBox(width: 12),
                    _buildSummaryCard('Done', doneOrders.length, const Color(0xFF10B981)),
                  ],
                ),
                const SizedBox(height: 24),

                if (awaitingVerification.isNotEmpty) ...[
                  _buildSectionHeader('🔍 Payment Verifications', awaitingVerification.length),
                  const SizedBox(height: 8),
                  ...awaitingVerification.map((o) => _buildVerificationCard(o)),
                  const SizedBox(height: 24),
                ],

                if (placedOrders.isNotEmpty) ...[
                  _buildSectionHeader('📋 New Orders', placedOrders.length),
                  const SizedBox(height: 8),
                  ...placedOrders.map((o) => _buildOrderCard(o)),
                  const SizedBox(height: 24),
                ],

                if (processedOrders.isNotEmpty) ...[
                  _buildSectionHeader('🔧 Being Processed', processedOrders.length),
                  const SizedBox(height: 8),
                  ...processedOrders.map((o) => _buildOrderCard(o)),
                  const SizedBox(height: 24),
                ],

                if (doneOrders.isNotEmpty) ...[
                  _buildSectionHeader('✅ Completed', doneOrders.length),
                  const SizedBox(height: 8),
                  ...doneOrders.map((o) => _buildOrderCard(o)),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(String title, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text('$count', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(title, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Text(
      '$title ($count)',
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildVerificationCard(Map<String, dynamic> order) {
    final orderId = order['id'] as int;
    final studentName = order['student_name'] ?? 'Unknown';
    final proofUrl = order['payment_proof_url'];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Verify QRIS Payment - Order #$orderId', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Text('From: $studentName', style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.schedule, size: 14, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  '${formatDateTime(order['created_at'])}  ·  ${timeAgo(order['created_at'])}',
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (proofUrl != null)
              Center(
                child: GestureDetector(
                  onTap: () => _showProofFullScreen(proofUrl, orderId),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      proofUrl,
                      height: 150,
                      fit: BoxFit.cover,
                      loadingBuilder: (ctx, child, progress) => progress == null
                          ? child
                          : const SizedBox(height: 150, child: Center(child: CircularProgressIndicator())),
                      errorBuilder: (ctx, err, stack) => const SizedBox(
                        height: 150,
                        child: Center(child: Icon(Icons.broken_image, size: 50, color: Colors.grey)),
                      ),
                    ),
                  ),
                ),
              )
            else
              const Text('No payment proof uploaded yet.', style: TextStyle(color: Colors.grey)),
            if (proofUrl != null)
              const Padding(
                padding: EdgeInsets.only(top: 6),
                child: Text('Tap receipt to enlarge', style: TextStyle(fontSize: 11, color: Colors.grey)),
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _verifyPayment(orderId, 'failed'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade100, foregroundColor: Colors.red),
                    child: const Text('Reject'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _verifyPayment(orderId, 'verified'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text('Approve'),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  // Renders the line items (product + quantity + line subtotal) for an order.
  // This is the core of the bulletin: it tells the worker what to prepare.
  Widget _buildOrderItems(Map<String, dynamic> order) {
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

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final status = order['order_status'] as String;
    final orderId = order['id'] as int;
    final studentName = order['student_name'] ?? 'Unknown';
    final studentNim = order['student_nim'] ?? '';
    final building = order['delivery_building'] ?? '';
    final floor = order['delivery_floor'] ?? '';
    final room = order['delivery_room'] ?? '';
    final totalPrice = order['total_price'] ?? 0;
    final canAdvance = status == 'placed' || status == 'processed';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Order #$orderId', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor(status).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _statusLabel(status),
                    style: TextStyle(color: _statusColor(status), fontWeight: FontWeight.w600, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Order time
            Row(
              children: [
                const Icon(Icons.schedule, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  '${formatDateTime(order['created_at'])}  ·  ${timeAgo(order['created_at'])}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Student info
            Row(
              children: [
                const Icon(Icons.person_outline, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text('$studentName ($studentNim)', style: const TextStyle(color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 6),

            // Delivery location
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text('$building, Floor $floor, Room $room', style: const TextStyle(color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 6),

            // Total
            Row(
              children: [
                const Icon(Icons.payments_outlined, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text('Rp $totalPrice', style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),

            // Ordered items — what the worker actually needs to prepare
            _buildOrderItems(order),

            // Action button
            if (canAdvance) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _advanceOrder(orderId, status),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _statusColor(_nextStatus(status)),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(_actionButtonLabel(status), style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
