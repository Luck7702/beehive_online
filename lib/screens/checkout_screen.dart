import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../theme.dart';
import '../providers/cart_provider.dart';
import '../services/api_service.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _buildingController = TextEditingController(text: 'Main Tower');
  final _floorController = TextEditingController();
  final _roomController = TextEditingController();
  
  String _paymentMethod = 'COD';
  bool _isLoading = false;

  Future<void> _confirmOrder() async {
    if (_floorController.text.isEmpty || _roomController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out your target classroom details')),
      );
      return;
    }

    final cart = Provider.of<CartProvider>(context, listen: false);
    final items = cart.items.values.map((item) => <String, dynamic>{
      'product_id': item.product.id,
      'quantity': item.quantity,
      'price': item.product.price,
    }).toList();

    setState(() => _isLoading = true);

    int? orderId;
    if (ApiService.token != null) {
      orderId = await ApiService.placeOrder(
        totalPrice: cart.totalAmount,
        building: _buildingController.text,
        floor: _floorController.text,
        room: _roomController.text,
        items: items,
        paymentMethod: _paymentMethod,
      );
    } else {
      // Not authenticated demo
      orderId = 999;
    }

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (orderId != null) {
      if (_paymentMethod == 'QRIS') {
        _showQrisUploadDialog(orderId, cart);
      } else {
        _showSuccessDialog(cart);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to place order. Please try again.')),
      );
    }
  }

  void _showQrisUploadDialog(int orderId, CartProvider cart) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        bool uploading = false;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Complete QRIS Payment'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Please scan the QR code below and upload your payment receipt.'),
                    const SizedBox(height: 16),
                    Image.network(
                      '${dotenv.env['BASE_URL'] ?? 'http://10.0.2.2:3000'}/imgs/qris.jpg', // 10.0.2.2 is localhost for Android Emulator
                      height: 200,
                      errorBuilder: (ctx, err, stack) => const Icon(Icons.qr_code, size: 100),
                    ),
                    const SizedBox(height: 16),
                    Text('Total Amount: Rp ${cart.totalAmount}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 16),
                    if (uploading) const CircularProgressIndicator(),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: uploading ? null : () {
                    // They canceled upload, order is stuck at pending
                    cart.clear();
                    Navigator.pop(context);
                    Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                  },
                  child: const Text('Do it Later'),
                ),
                ElevatedButton(
                  onPressed: uploading ? null : () async {
                    final ImagePicker picker = ImagePicker();
                    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                    
                    if (image != null) {
                      setState(() => uploading = true);
                      bool success = await ApiService.uploadPaymentProof(orderId, image.path);
                      setState(() => uploading = false);
                      
                      if (success) {
                        if (!context.mounted) return;
                        Navigator.pop(context);
                        _showSuccessDialog(cart);
                      } else {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Failed to upload proof.')),
                        );
                      }
                    }
                  },
                  child: const Text('Upload Receipt'),
                ),
              ],
            );
          }
        );
      },
    );
  }

  void _showSuccessDialog(CartProvider cart) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Order Placed Successfully! 🎉'),
        content: Text(
          'Your items are being prepared for delivery to '
          '${_buildingController.text}, Floor ${_floorController.text}, '
          'Room ${_roomController.text}.\n\n'
          'Total: Rp ${cart.totalAmount}',
        ),
        actions: [
          TextButton(
            onPressed: () {
              cart.clear();
              Navigator.of(context).pop();
              Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
            },
            child: const Text('Back to Home'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final cartItems = cart.items.values.toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout Details'), backgroundColor: Colors.transparent, elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Delivery Location', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: _buildingController,
              decoration: const InputDecoration(labelText: 'Building / Gedung'),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _floorController,
                    decoration: const InputDecoration(labelText: 'Floor / Lantai', hintText: 'e.g., 3'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _roomController,
                    decoration: const InputDecoration(labelText: 'Room / Ruangan', hintText: 'e.g., 302'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Text('Payment Method', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: BeehiveColors.border),
                borderRadius: BorderRadius.circular(14),
              ),
              child: RadioGroup<String>(
                groupValue: _paymentMethod,
                onChanged: (value) => setState(() => _paymentMethod = value!),
                child: const Column(
                  children: [
                    RadioListTile<String>(
                      title: Text('Cash on Delivery (COD)'),
                      value: 'COD',
                    ),
                    Divider(height: 1),
                    RadioListTile<String>(
                      title: Text('QRIS'),
                      value: 'QRIS',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text('Order Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Card(
              margin: const EdgeInsets.symmetric(vertical: 12),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    ...cartItems.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text('${item.product.name} x${item.quantity}')),
                          Text('Rp ${item.totalPrice}'),
                        ],
                      ),
                    )),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Items Subtotal', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('Rp ${cart.totalAmount}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _confirmOrder,
                child: _isLoading
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: BeehiveColors.ink, strokeWidth: 2))
                  : Text('Place Order ($_paymentMethod)'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}