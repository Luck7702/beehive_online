import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import '../providers/cart_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Friendly display labels for the Indonesian category values stored on products.
  static const Map<String, String> _categoryLabels = {
    'makanan': 'Food',
    'minuman': 'Drinks',
    'snack': 'Snacks',
  };

  List<Product> _allProducts = [];
  bool _isLoading = true;
  String? _error;

  String _selectedCategory = 'All';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final products = await ApiService.getProducts();
      if (!mounted) return;
      setState(() {
        _allProducts = products;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  // 'All' plus each distinct category present in the loaded products.
  List<String> get _categories {
    final seen = <String>{};
    final cats = <String>['All'];
    for (final p in _allProducts) {
      if (p.category.isNotEmpty && seen.add(p.category.toLowerCase())) {
        cats.add(p.category);
      }
    }
    return cats;
  }

  List<Product> get _filteredProducts {
    final query = _searchQuery.trim().toLowerCase();
    return _allProducts.where((p) {
      final matchesCategory = _selectedCategory == 'All' ||
          p.category.toLowerCase() == _selectedCategory.toLowerCase();
      final matchesSearch =
          query.isEmpty || p.name.toLowerCase().contains(query);
      return matchesCategory && matchesSearch;
    }).toList();
  }

  String _categoryLabel(String category) {
    if (category == 'All') return 'All';
    return _categoryLabels[category.toLowerCase()] ??
        (category[0].toUpperCase() + category.substring(1));
  }

  void _logout() {
    ApiService.logout();
    Navigator.pushNamedAndRemoveUntil(context, '/welcome', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BeeHive Online', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Consumer<CartProvider>(
            builder: (_, cart, ch) => Badge(
              label: Text(cart.itemCount.toString()),
              backgroundColor: BeehiveColors.yellow,
              textColor: BeehiveColors.ink,
              isLabelVisible: cart.itemCount > 0,
              child: ch!,
            ),
            child: IconButton(
              icon: const Icon(Icons.shopping_cart_outlined),
              onPressed: () => Navigator.pushNamed(context, '/cart'),
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle_outlined),
            onSelected: (value) {
              if (value == 'history') {
                Navigator.pushNamed(context, '/order_history');
              } else if (value == 'logout') {
                _logout();
              }
            },
            itemBuilder: (context) => [
              if (ApiService.userName != null)
                PopupMenuItem<String>(
                  enabled: false,
                  child: Text(
                    'Signed in as ${ApiService.userName}',
                    style: const TextStyle(color: Colors.black54, fontSize: 13),
                  ),
                ),
              const PopupMenuItem<String>(
                value: 'history',
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.receipt_long_outlined),
                  title: Text('Order History'),
                ),
              ),
              const PopupMenuItem<String>(
                value: 'logout',
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.logout),
                  title: Text('Log Out'),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadProducts,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Promo banner
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: BeehiveColors.blue.withValues(alpha: 0.28),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(gradient: BeehiveColors.brandGradient),
                    child: Stack(
                      children: [
                        // Soft decorative circles for depth
                        Positioned(right: -24, top: -28, child: _decorCircle(110, 0.12)),
                        Positioned(right: 48, bottom: -40, child: _decorCircle(96, 0.08)),
                        Padding(
                          padding: const EdgeInsets.all(22),
                          child: Row(
                            children: [
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Free Delivery This Week!',
                                        style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: -0.3)),
                                    SizedBox(height: 6),
                                    Text('No minimum order to any building or floor.',
                                        style: TextStyle(color: Colors.white70, height: 1.4)),
                                  ],
                                ),
                              ),
                              Container(
                                width: 54,
                                height: 54,
                                decoration: const BoxDecoration(color: BeehiveColors.yellow, shape: BoxShape.circle),
                                child: const Icon(Icons.local_shipping_rounded, color: BeehiveColors.blueDark),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Search bar
              TextField(
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: const InputDecoration(
                  hintText: 'Search products...',
                  prefixIcon: Icon(Icons.search, color: BeehiveColors.muted),
                ),
              ),
              const SizedBox(height: 20),

              const Text('Categories', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              // Horizontal categories row (derived from real product data)
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: _categories.map((cat) {
                    final isSelected = cat == _selectedCategory;
                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(_categoryLabel(cat)),
                        selected: isSelected,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : BeehiveColors.ink,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        showCheckmark: false,
                        onSelected: (_) => setState(() => _selectedCategory = cat),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),
              const Text('Available Products', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              _buildProductsSection(),
            ],
          ),
        ),
      ),
    );
  }

  // Faint translucent circle used to add depth to the promo banner.
  Widget _decorCircle(double size, double opacity) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: opacity),
          shape: BoxShape.circle,
        ),
      );

  Widget _buildProductsSection() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Icon(Icons.cloud_off, size: 48, color: Colors.grey),
              const SizedBox(height: 12),
              Text('Could not load products.\n$_error',
                  textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _loadProducts, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    final products = _filteredProducts;
    if (products.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text('No products match your search', style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) => _buildProductCard(products[index]),
    );
  }

  Widget _buildProductImage(String? url) {
    const fallback = Center(
      child: Icon(Icons.fastfood_outlined, size: 40, color: BeehiveColors.blue),
    );
    if (url == null) return fallback;
    return Image.network(
      url,
      fit: BoxFit.cover,
      loadingBuilder: (ctx, child, progress) => progress == null
          ? child
          : const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      errorBuilder: (ctx, err, stack) => fallback,
    );
  }

  Widget _buildProductCard(Product prod) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: BeehiveColors.blueTint,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: _buildProductImage(ApiService.imageUrl(prod.imageUrl)),
              ),
            ),
            const SizedBox(height: 8),
            Text(prod.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 4),
            Text(prod.formattedPrice, style: const TextStyle(color: BeehiveColors.blue, fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Provider.of<CartProvider>(context, listen: false).addItem(prod);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Added ${prod.name} to cart'),
                      duration: const Duration(seconds: 1),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  textStyle: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                ),
                icon: const Icon(Icons.add_shopping_cart, size: 16),
                label: const Text('Add to Cart'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
