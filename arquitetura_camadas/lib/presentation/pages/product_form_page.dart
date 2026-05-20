import 'package:flutter/material.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../viewmodels/product_form_viewmodel.dart';

class ProductFormPage extends StatefulWidget {
  final ProductRepository repository;
  final Product? editingProduct;

  const ProductFormPage({
    super.key,
    required this.repository,
    this.editingProduct,
  });

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final ProductFormViewModel _viewModel;

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _categoryController;
  late final TextEditingController _thumbnailController;

  @override
  void initState() {
    super.initState();
    _viewModel = ProductFormViewModel(
      repository: widget.repository,
      editingProduct: widget.editingProduct,
    );
    final p = widget.editingProduct;
    _titleController = TextEditingController(text: p?.title ?? '');
    _descriptionController =
        TextEditingController(text: p?.description ?? '');
    _priceController =
        TextEditingController(text: p != null ? p.price.toString() : '');
    _categoryController = TextEditingController(text: p?.category ?? '');
    _thumbnailController = TextEditingController(text: p?.thumbnail ?? '');

    _viewModel.addListener(_onStateChange);
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onStateChange);
    _viewModel.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
    _thumbnailController.dispose();
    super.dispose();
  }

  void _onStateChange() {
    if (!mounted) return;
    final state = _viewModel.state;

    if (state is ProductFormSuccess) {
      Navigator.of(context).pop(state.product);
    } else if (state is ProductFormError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(state.message), backgroundColor: Colors.red),
      );
    }
    setState(() {});
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    _viewModel.save(
      title: _titleController.text,
      description: _descriptionController.text,
      price: double.parse(_priceController.text.replaceAll(',', '.')),
      category: _categoryController.text,
      thumbnail: _thumbnailController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = _viewModel.state is ProductFormLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(
            _viewModel.isEditing ? 'Editar Produto' : 'Novo Produto'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _field(
                controller: _titleController,
                label: 'Nome',
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Informe o nome'
                    : null,
              ),
              const SizedBox(height: 12),
              _field(
                controller: _descriptionController,
                label: 'Descrição',
                maxLines: 3,
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Informe a descrição'
                    : null,
              ),
              const SizedBox(height: 12),
              _field(
                controller: _priceController,
                label: 'Preço',
                keyboardType: const TextInputType.numberWithOptions(
                    decimal: true),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Informe o preço';
                  }
                  final parsed =
                      double.tryParse(v.replaceAll(',', '.'));
                  if (parsed == null || parsed <= 0) {
                    return 'Preço inválido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              _field(
                controller: _categoryController,
                label: 'Categoria',
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Informe a categoria'
                    : null,
              ),
              const SizedBox(height: 12),
              _field(
                controller: _thumbnailController,
                label: 'URL da imagem (opcional)',
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: isLoading ? null : _submit,
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white),
                        )
                      : Text(_viewModel.isEditing
                          ? 'Salvar'
                          : 'Cadastrar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
    );
  }
}
