import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/models.dart';

class ProductsService extends ChangeNotifier {
  final String _baseUrl =
      'flutter-varios-10bf4-default-rtdb.europe-west1.firebasedatabase.app';

  final List<Product> products = [];

  Product? selectedProduct;

  bool isLoading = true;
  bool isSaving = false;

  ProductsService() {
    loadProducts();
  }

  Future<List<Product>> loadProducts() async {
    isLoading = true;
    notifyListeners();
    final url = Uri.https(_baseUrl, 'products.json');
    final res = await http.get(url);

    final Map<String, dynamic> productsMap = jsonDecode(res.body);
    productsMap.forEach((key, value) {
      final tempProduct = Product.fromMap(value);
      tempProduct.id = key;
      products.add(tempProduct);
    });
    isLoading = false;
    notifyListeners();
    return products;
  }

  saveOrCreateProduct(Product product) async {
    isSaving = true;
    notifyListeners();

    if (product.id == null) {
    } else {
      await updateProduct(product);
      final index = products.indexWhere((element) => element.id == product.id);
      products[index] = product;
    }

    isSaving = false;
    notifyListeners();
  }

  Future<String> updateProduct(Product product) async {
    final url = Uri.https(_baseUrl, 'products/${product.id}.json');
    final res = await http.put(url, body: product.toJson());
    final decodedData = res.body;
    return product.id!;
  }
}
