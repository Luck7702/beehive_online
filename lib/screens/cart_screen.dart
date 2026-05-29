import 'package:flutter/material.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Cart'), backgroundColor: Colors.transparent, elevation: 0),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: 2, // Sample size for local layout preview
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFF2A2A2A),
                      child: Icon(Icons.fastfood, color: Colors.white),
                    ),
                    title: Text(index == 0 ? 'Es Kopi Susu Aren' : 'Chitato Sapi Panggang'),
                    subtitle: Text(index == 0 ? 'Rp 15.000' : 'Rp 11.000'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(icon: const Icon(Icons.remove_circle_outline), onPressed: () {}),
                        const Text('1', style: TextStyle(fontSize: 16)),
                        IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: () {}),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Color(0xFF1E1E1E),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
            ),
            child: Column(
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total Payment', style: TextStyle(fontSize: 16, color: Colors.grey)),
                    Text('Rp 26.000', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/checkout'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Proceed to Checkout', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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