import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services//api_service_product.dart';
import '../widgets/product_form.dart';

class ProductListScreen extends StatefulWidget {
  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  late Future<List<Product>> _futureProducts;

  @override
  void initState() {
    super.initState();
    _refreshProducts();
  }

  void _refreshProducts() {
    setState(() {
      _futureProducts = ApiServiceProduct.getProducts();
    });
  }

  void _showProductForm({Product? product}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => ProductForm(
        product: product,
        onSave: (name, data) async {
          if (product == null) {
            await ApiServiceProduct.createProduct(name, data);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Producto creado')));
          } else {
            await ApiServiceProduct.updateProduct(product.id, name, data);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Producto actualizado')));
          }
          _refreshProducts();
          Navigator.pop(context);
        },
      ),
    );
  }

  void _deleteProduct(String id) async {
    await ApiServiceProduct.deleteProduct(id);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Producto eliminado')));
    _refreshProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Productos'),
      ),
      body: FutureBuilder<List<Product>>(
        future: _futureProducts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());
          else if (snapshot.hasError)
            return Center(child: Text('Error: ${snapshot.error}'));
          else if (!snapshot.hasData || snapshot.data!.isEmpty)
            return Center(child: Text('No hay productos'));

          final products = snapshot.data!;
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ListTile(
                title: Text(product.name),
                subtitle: Text(product.data.toString()),
                onTap: () => _showDetails(product),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () => _showProductForm(product: product),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => _deleteProduct(product.id),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _showProductForm(),
      ),
    );
  }

  void _showDetails(Product product) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Detalles del Producto', style: Theme.of(context).textTheme.titleLarge),
              SizedBox(height: 16),
              Text('Nombre: ${product.name}'),
              SizedBox(height: 8),
              Text('Datos: ${product.data.toString()}'),
            ],
          ),
        ),
      ),
    );
  }
}
