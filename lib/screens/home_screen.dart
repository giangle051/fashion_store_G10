import 'package:flutter/material.dart';

import '../models/fashion_product_model.dart';
import '../services/firestore_service.dart';
import '../widgets/fashion_product_card.dart';

enum HomeDataStatus { loading, success, error }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  HomeDataStatus _status = HomeDataStatus.loading;
  List<FashionProduct> _products = <FashionProduct>[];
  String _errorMessage = '';
  int _currentIndex = 0;
  bool _simulateError = false; // Phục vụ yêu cầu: "giả lập tình huống mất mạng"

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _status = HomeDataStatus.loading;
      _errorMessage = '';
    });

    await Future.delayed(const Duration(seconds: 10));

    try {
      if (_simulateError) {
        throw Exception('Mất kết nối mạng (Giả lập). Vui lòng kiểm tra lại!');
      }

      final products = await _firestoreService.fetchFashionProducts();
      if (!mounted) {
        return;
      }

      setState(() {
        _products = products;
        _status = HomeDataStatus.success;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _status = HomeDataStatus.error;
        _errorMessage = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  void _retryFetch() {
    _loadProducts();
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 12),
          Text('Đang tải dữ liệu...'),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.wifi_off_rounded,
              size: 56,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 14),
            Text(
              'Không thể tải dữ liệu',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _retryFetch,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessState(List<FashionProduct> products) {
    return RefreshIndicator(
      onRefresh: _loadProducts,
      child: GridView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
        itemCount: products.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.55,
        ),
        itemBuilder: (context, index) {
          return FashionProductCard(product: products[index]);
        },
      ),
    );
  }

  Widget _buildPlaceholderTab(IconData icon, String label) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 38),
          const SizedBox(height: 10),
          Text(label, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }

  Widget _buildHomeTab() {
    switch (_status) {
      case HomeDataStatus.loading:
        return _buildLoadingState();
      case HomeDataStatus.error:
        return _buildErrorState();
      case HomeDataStatus.success:
        if (_products.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Chưa có dữ liệu sản phẩm',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _retryFetch,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Thử lại'),
                ),
              ],
            ),
          );
        }

        return _buildSuccessState(_products);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tabBodies = <Widget>[
      _buildHomeTab(),
      _buildPlaceholderTab(Icons.favorite_border, 'Wishlist'),
      _buildPlaceholderTab(Icons.shopping_cart_outlined, 'Cart'),
      _buildPlaceholderTab(Icons.person_outline, 'Profile'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('TH3 - Lê Thu Giang - 2351060438'),
        actions: [
          IconButton(
            icon: Icon(
              _simulateError ? Icons.wifi_off_rounded : Icons.wifi_rounded,
              color: _simulateError
                  ? Theme.of(context).colorScheme.error
                  : null,
            ),
            tooltip: _simulateError
                ? 'Tắt giả lập lỗi'
                : 'Bật giả lập lỗi mạng',
            onPressed: () {
              setState(() {
                _simulateError = !_simulateError;
              });
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _simulateError
                        ? 'Đã BẬT giả lập mất mạng. Kéo xuống để tải lại.'
                        : 'Đã TẮT giả lập mất mạng. Kéo xuống để tải lại.',
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );

              if (_currentIndex == 0) {
                _loadProducts();
              }
            },
          ),
        ],
      ),
      body: IndexedStack(index: _currentIndex, children: tabBodies),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            label: 'Wishlist',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_cart_outlined),
            label: 'Cart',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
