
import 'package:flutter/cupertino.dart';

class CartItem {
  final String id;
  final String title;
  final int quantity;
  final double price;

  CartItem(
      {required this.id,
      required this.title,
      required this.quantity,
      required this.price});
}

class Cart with ChangeNotifier {
  late Map<String, CartItem> _items = {};

  Map<String, CartItem> get items {
    return {..._items};
  }

  int get itemCount {
    return _items.length;
  }

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, value) {
      total += value.price * value.quantity;
    });
    return total;
  }

  void addItem(String productId, String title, double price){
    if (_items.containsKey(productId)) {
      _items.update(
          productId,
          (ex) => CartItem(
              id: ex.id,
              title: ex.title,
              quantity: ex.quantity + 1,
              price: ex.price));
    } else {
      _items.putIfAbsent(
        productId,
        () {
          return CartItem(
            id: DateTime.now().toString(),
            title: title,
            quantity: 1,
            price: price,
          );
        },
      );
    }
    notifyListeners();
  }

  void removeSingleItem(String id) {
    if (!_items.containsKey(id)) {
      return;
    }
    if (_items[id]!.quantity > 1) {
      _items.update(
        id,
        (ex) => CartItem(
            id: ex.id,
            title: ex.title,
            quantity: ex.quantity - 1,
            price: ex.price),
      );
    } else {
      _items.remove(id);
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void clear() {
    _items = {};
    notifyListeners();
  }
}
