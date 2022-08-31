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
}
