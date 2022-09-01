import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../models/models.dart';

class ProductsService extends ChangeNotifier {
  final String _baseUrl =
      'flutter-varios-10bf4-default-rtdb.europe-west1.firebasedatabase.app';

  final List<Product> products = [];

  Product? selectedProduct;

  bool isLoading = true;
  bool isSaving = false;

  XFile? newPictureFile;

  final storage = const FlutterSecureStorage();

  ProductsService() {
    loadProducts();
  }

  Future<List<Product>> loadProducts() async {
    isLoading = true;
    notifyListeners();
    final url = Uri.https(_baseUrl, 'products.json',
        {'auth': await storage.read(key: 'token') ?? ''});
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
      await createProduct(product);
    } else {
      await updateProduct(product);
      final index = products.indexWhere((element) => element.id == product.id);
      products[index] = product;
    }

    isSaving = false;
    notifyListeners();
  }

  Future<String> updateProduct(Product product) async {
    final url = Uri.https(_baseUrl, 'products/${product.id}.json',
        {'auth': await storage.read(key: 'token') ?? ''});
    await http.put(url, body: product.toJson());

    return product.id!;
  }

  Future<String> createProduct(Product product) async {
    final url = Uri.https(_baseUrl, 'products.json',
        {'auth': await storage.read(key: 'token') ?? ''});
    final res = await http.post(url, body: product.toJson());
    final decodedData = jsonDecode(res.body);
    products.add(product);
    product.id = decodedData['name'];

    return product.id!;
  }

  updateSelectedProductImage(String path) {
    selectedProduct!.picture = path;
    newPictureFile = XFile(path);
    notifyListeners();
  }

  Future<String?> uploadImage() async {
    if (newPictureFile == null) return '';
    isSaving = true;
    notifyListeners();

    final url = Uri.parse(
        'https://api.cloudinary.com/v1_1/deb3smp4p/image/upload?upload_preset=umjmw92k');
    final imageUploadRequest = http.MultipartRequest('POST', url);
    final file =
        await http.MultipartFile.fromPath('file', newPictureFile!.path);
    imageUploadRequest.files.add(file);
    final streamResponse = await imageUploadRequest.send();
    final res = await http.Response.fromStream(streamResponse);

    if (res.statusCode != 200 && res.statusCode != 201) return null;

    newPictureFile = null;

    final decodedData = json.decode(res.body);
    return decodedData['secure_url'];
  }
}
