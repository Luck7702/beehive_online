import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../providers/cart_provider.dart';
import '../services/api_service.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  // Compact +/- control used in the quantity stepper.
  Widget _qtyButton(IconData icon, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(icon, size: 18, color: BeehiveColors.blue),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final cartItems = cart.items.values.toList();
    final cartKeys = cart.items.keys.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (cart.itemCount > 0)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              onPressed: () {
                cart.clear();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cart cleared'), duration: Duration(seconds: 1)),
                );
              },
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: cartItems.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('Your cart is empty', style: TextStyle(fontSize: 18, color: Colors.grey)),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      final productId = cartKeys[index];
                      return Dismissible(
                        key: ValueKey(productId),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.red[400],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) => cart.removeItem(productId),
                        child: Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: BeehiveColors.blueTint,
                              backgroundImage: ApiService.imageUrl(item.product.imageUrl) != null
                                  ? NetworkImage(ApiService.imageUrl(item.product.imageUrl)!)
                                  : null,
                              child: ApiService.imageUrl(item.product.imageUrl) == null
                                  ? const Icon(Icons.fastfood, color: BeehiveColors.blue)
                                  : null,
                            ),
                            title: Text(item.product.name),
                            subtitle: Text(item.product.formattedPrice, style: const TextStyle(color: BeehiveColors.blue, fontWeight: FontWeight.w600)),
                            trailing: Container(
                              decoration: BoxDecoration(
                                color: BeehiveColors.blueTint,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _qtyButton(Icons.remove, () => cart.decreaseQuantity(productId)),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 6),
                                    child: Text('${item.quantity}',
                                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: BeehiveColors.ink)),
                                  ),
                                  _qtyButton(Icons.add, () => cart.addItem(item.product)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Payment', style: TextStyle(fontSize: 16, color: BeehiveColors.muted)),
                    Text('Rp ${cart.totalAmount}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: BeehiveColors.ink)),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: cartItems.isEmpty ? null : () => Navigator.pushNamed(context, '/checkout'),
                    child: const Text('Proceed to Checkout'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}