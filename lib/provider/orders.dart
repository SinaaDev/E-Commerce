import 'package:flutter/material.dart';

import '../provider/cart.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    required this.id,
    required this.amount,
    required this.products,
    required this.dateTime,
  });
}



class Orders with ChangeNotifier {
  late List<OrderItem> _orders = [];
  var _token;
  var _userId;

  Orders(this._token,this._userId, this._orders);

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchAndSetOrders() async {
    final url = Uri.parse(
        'https://flutter-update-c17c7-default-rtdb.firebaseio.com/orders/$_userId.json?auth=$_token');
    final response = await http.get(url);
    final List<OrderItem> loadedOrders = [];
    final extractedData = json.decode(response.body) as Map<String, dynamic>;
    if(extractedData == null || extractedData.isEmpty){
      throw Exception('No data available on the server');
    }
    extractedData.forEach((orderId, orderData) {
      loadedOrders.insert(
          0,
          OrderItem(
              id: orderId,
              amount: orderData['amount'],
              products: (orderData['products'] as List<dynamic>)
                  .map((item) => CartItem(
                      id: item['id'],
                      title: item['title'],
                      quantity: item['quantity'],
                      price: item['price']))
                  .toList(),
              dateTime: DateTime.parse(orderData['dateTime'])));
    });
    _orders = loadedOrders;
    notifyListeners();
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final time = DateTime.now();
    final url = Uri.parse(
        'https://flutter-update-c17c7-default-rtdb.firebaseio.com/orders/$_userId.json?auth=$_token');
    final response = await http.post(url,
        body: json.encode({
          'amount': total,
          'dateTime': time.toIso8601String(),
          'products': cartProducts
              .map((cp) => {
                    'id': cp.id,
                    'title': cp.title,
                    'quantity': cp.quantity,
                    'price': cp.price
                  })
              .toList()
        }));
    _orders.insert(
      0,
      OrderItem(
        id: json.decode(response.body)['name'],
        amount: total,
        products: cartProducts,
        dateTime: time,
      ),
    );
    notifyListeners();
  }
}
