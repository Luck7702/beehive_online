import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/order_card.dart';

/// Worker-facing history of completed (done / cancelled) orders. These are kept
/// out of the live bulletin and loaded here one page at a time as the worker
/// scrolls, so the list stays fast no matter how many past orders pile up.
class WorkerHistoryScreen extends StatefulWidget {
  const WorkerHistoryScreen({super.key});

  @override
  State<WorkerHistoryScreen> createState() => _WorkerHistoryScreenState();
}

class _WorkerHistoryScreenState extends State<WorkerHistoryScreen> {
  final List<Map<String, dynamic>> _orders = [];
  final ScrollController _scrollController = ScrollController();

  int _page = 1;
  bool _hasMore = true;
  bool _isLoading = false;
  bool _firstLoad = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadMore();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoading || !_hasMore) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final result = await ApiService.getCompletedOrders(page: _page);
      if (!mounted) return;
      setState(() {
        _orders.addAll(result.orders);
        _hasMore = result.hasMore;
        _page += 1;
        _firstLoad = false;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _firstLoad = false;
        _isLoading = false;
      });
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _orders.clear();
      _page = 1;
      _hasMore = true;
      _firstLoad = true;
      _error = null;
    });
    await _loadMore();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Completed Orders', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_firstLoad && _isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null && _orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text('Error: $_error', textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadMore, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (_orders.isEmpty) {
      return RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 140),
            Center(
              child: Column(
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No completed orders yet', style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: _orders.length + 1,
        itemBuilder: (context, index) {
          if (index < _orders.length) {
            return OrderCard(order: _orders[index]);
          }
          return _buildFooter();
        },
      ),
    );
  }

  // Bottom-of-list indicator: spinner while loading the next page, a retry on
  // error, or an end-of-history marker once everything is loaded.
  Widget _buildFooter() {
    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: TextButton(onPressed: _loadMore, child: const Text('Retry loading more')),
        ),
      );
    }
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (!_hasMore) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: Text('— End of history —', style: TextStyle(color: Colors.grey))),
      );
    }
    return const SizedBox.shrink();
  }
}
