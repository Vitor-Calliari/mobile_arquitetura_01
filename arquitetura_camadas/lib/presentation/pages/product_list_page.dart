import 'package:flutter/material.dart';
import '../../core/sessions/session_manager.dart';
import '../../data/datasources/product_local_datasource.dart';
import '../../data/datasources/product_remote_datasource.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../viewmodels/favorites_viewmodel.dart';
import '../viewmodels/product_state.dart';
import '../viewmodels/product_viewmodel.dart';
import '../widgets/product_tile.dart';
import 'login_page.dart';
import 'product_detail_page.dart';
import 'product_form_page.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  late final ProductRepository _repository;
  late final ProductViewModel _viewModel;
  late final FavoritesViewModel _favoritesViewModel;

  @override
  void initState() {
    super.initState();

    _repository = ProductRepositoryImpl(
      remoteDataSource: ProductRemoteDataSource(),
      localDataSource: ProductLocalDataSource(),
    );

    _viewModel = ProductViewModel(_repository);
    _favoritesViewModel = FavoritesViewModel();

    _viewModel.addListener(_onStateChange);
    _favoritesViewModel.addListener(_onStateChange);
    _viewModel.loadProducts();
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onStateChange);
    _favoritesViewModel.removeListener(_onStateChange);
    _viewModel.dispose();
    _favoritesViewModel.dispose();
    super.dispose();
  }

  void _onStateChange() {
    if (mounted) setState(() {});
  }

  void _logout() {
    SessionManager.instance.clear();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (_) => false, // limpa toda a pilha de navegação
    );
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sair'),
        content: const Text('Deseja encerrar a sessão?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
    if (confirmed == true) _logout();
  }

  void _openDetail(Product product) {
    Navigator.of(context).push(
      MaterialPageRoute(
          builder: (_) => ProductDetailPage(product: product)),
    );
  }

  Future<void> _openForm({Product? product}) async {
    final saved = await Navigator.of(context).push<Product>(
      MaterialPageRoute(
        builder: (_) => ProductFormPage(
          repository: _repository,
          editingProduct: product,
        ),
      ),
    );
    if (saved != null) _viewModel.upsertProduct(saved);
  }

  Future<void> _confirmDelete(Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir produto'),
        content: Text('Deseja excluir "${product.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style:
                FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await _viewModel.deleteProduct(product.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produto excluído.')),
        );
      } catch (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Falha ao excluir. Tente novamente.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = SessionManager.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Produtos'),
            if (user != null)
              Text(
                'Olá, ${user.fullName}',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.white70),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Recarregar',
            onPressed: _viewModel.loadProducts,
          ),
          if (user != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: _confirmLogout,
                child: Tooltip(
                  message: 'Sair (${user.username})',
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.white24,
                    foregroundImage: NetworkImage(user.image),
                    child: Text(
                      user.firstName[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Sair',
              onPressed: _confirmLogout,
            ),
        ],
      ),
      body: _buildBody(_viewModel.state),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        tooltip: 'Novo produto',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(ProductState state) {
    return switch (state) {
      ProductLoading() =>
        const Center(child: CircularProgressIndicator()),
      ProductSuccess(
        products: final products,
        fromCache: final fromCache
      ) =>
        _buildProductList(
          products,
          banner: fromCache ? _cacheBanner() : null,
        ),
      ProductError(
        message: final message,
        cachedProducts: final cached
      ) =>
        cached != null && cached.isNotEmpty
            ? _buildProductList(cached, banner: _errorBanner(message))
            : _buildFullError(message),
    };
  }

  Widget _buildProductList(List<Product> products, {Widget? banner}) {
    return Column(
      children: [
        if (banner != null) banner,
        Expanded(
          child: ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ProductTile(
                product: product,
                isFavorite:
                    _favoritesViewModel.isFavorite(product.id),
                onToggleFavorite: () =>
                    _favoritesViewModel.toggleFavorite(product.id),
                onTap: () => _openDetail(product),
                onEdit: () => _openForm(product: product),
                onDelete: () => _confirmDelete(product),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFullError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _viewModel.loadProducts,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _errorBanner(String message) {
    return MaterialBanner(
      backgroundColor: Colors.red.shade50,
      leading: const Icon(Icons.warning_amber, color: Colors.red),
      content: Text('$message Exibindo dados anteriores.',
          style: const TextStyle(color: Colors.red)),
      actions: [
        TextButton(
          onPressed: _viewModel.loadProducts,
          child: const Text('Tentar novamente'),
        ),
      ],
    );
  }

  Widget _cacheBanner() {
    return MaterialBanner(
      backgroundColor: Colors.amber.shade50,
      leading: const Icon(Icons.cached, color: Colors.orange),
      content: const Text('Exibindo dados do cache local.',
          style: TextStyle(color: Colors.orange)),
      actions: [
        TextButton(
          onPressed: _viewModel.loadProducts,
          child: const Text('Atualizar'),
        ),
      ],
    );
  }
}