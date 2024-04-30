import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/cart.dart';

class CartItem extends StatelessWidget {
  final String id;
  final String productId;
  final double price;
  final String title;
  final int quantity;

  const CartItem({
    super.key,
    required this.id,
    required this.price,
    required this.title,
    required this.quantity,
    required this.productId,
  });

  @override
  Widget build(BuildContext context) {
    final total = price * quantity;
    return Dismissible(
      key: ValueKey(id),
      background: Container(
        color: Theme
            .of(context)
            .errorColor,
        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 15),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(
            Icons.delete,
            color: Colors.white,
            size: 40,
          ),
        ),
        alignment: Alignment.centerRight,
      ),
      confirmDismiss: (direction) =>
          showDialog(
            context: context,
            builder: (ctx) =>
                AlertDialog(
                  title: Text('Are you sure?'),
                  content: Text('Do you want to remove the item form cart?'),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.of(ctx).pop(false);
                        },
                        child: Text('No')),
                    TextButton(
                        onPressed: () {
                          Navigator.of(ctx).pop(true);
                        },
                        child: Text('Yes')),
                  ],
                ),
          ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        Provider.of<Cart>(context, listen: false).removeItem(productId);
      },
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 15),
        child: Padding(
          padding: EdgeInsets.all(8),
          child: ListTile(
            leading: CircleAvatar(
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: FittedBox(child: Text('\$$price')),
              ),
            ),
            title: Text(title),
            subtitle: Text('Total: ${total}'),
            trailing: Text('$quantity x'),
          ),
        ),
      ),
    );
  }
}
