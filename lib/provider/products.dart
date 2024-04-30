import 'package:flutter/material.dart';
import 'package:shop_app/model/http_exception.dart';
import 'product.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Products with ChangeNotifier {
  List<Product> _items = [];

  var _showFavorites = false;
  var _token;
  var _userId;

  Products(this._token, this._items, this._userId);

  List<Product> get items {
    if (_showFavorites) {
      return _items.where((element) => element.isFavorite).toList();
    }
    return [..._items];
  }

  void showOnlyFavorites() {
    _showFavorites = true;
    notifyListeners();
  }

  void showAll() {
    _showFavorites = false;
    notifyListeners();
  }


  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    final filterString = filterByUser ? 'orderBy="creatorId"&equalTo="$_userId"' : '' ;
    var url = Uri.parse(
        'https://flutter-update-c17c7-default-rtdb.firebaseio.com/products.json?auth=$_token&$filterString');

    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if(extractedData == null){
        return;
      }
      url = Uri.parse(
          'https://flutter-update-c17c7-default-rtdb.firebaseio.com/userFavorite/$_userId.json?auth=$_token');
      final favoriteResponse = await http.get(url);
      final favoriteData = json.decode(favoriteResponse.body);
      final List<Product> loadedProducts = [];
      extractedData.forEach(
        (prodId, prodData) => loadedProducts.insert(
          0,
          Product(
            id: prodId,
            title: prodData['title'],
            description: prodData['description'],
            price: prodData['price']?.toDouble() ?? 0.0,
            imageUrl: prodData['imageUrl'],
            isFavorite: favoriteData == null ? false : favoriteData[prodId] ?? false,
          ),
        ),
      );
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Product findById(String id) {
    return _items.firstWhere((element) => element.id == id);
  }

  Future<void> addProduct(Product product) async {
    final url = Uri.parse(
        'https://flutter-update-c17c7-default-rtdb.firebaseio.com/products.json?auth=$_token');
    //JSON = Javascript Object Notation
    try {
      final response = await http.post(url,
          body: json.encode({
            'title': product.title,
            'price': product.price,
            'description': product.description,
            'imageUrl': product.imageUrl,
            'creatorId': _userId
          }));
      final _newProduct = Product(
        id: json.decode(response.body)['name'],
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
      );
      _items.insert(0, _newProduct);
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final productIndex = _items.indexWhere((element) => element.id == id);
    if (productIndex >= 0) {
      final url = Uri.parse(
          'https://flutter-update-c17c7-default-rtdb.firebaseio.com/products/$id.json?auth=$_token');
      await http.patch(url,
          body: json.encode({
            'title': newProduct.title,
            'price': newProduct.price,
            'description': newProduct.description,
            'imageUrl': newProduct.imageUrl,
          }));
      _items[productIndex] = newProduct;
      notifyListeners();
    } else {
      print('...');
    }
  }

  Future<void> deleteProduct(String id) async {
    final url = Uri.parse(
        'https://flutter-update-c17c7-default-rtdb.firebaseio.com/products/$id.json?auth=$_token');
    final existingProductIndex =
        _items.indexWhere((product) => product.id == id);
    Product? existingProduct = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      notifyListeners();
      _items.insert(existingProductIndex, existingProduct);
      throw HttpException('Could not delete the product');
    }
    existingProduct = null;
    notifyListeners();
  }
}
