import 'package:flutter/material.dart';

class myBadge extends StatelessWidget {
  myBadge({
    required this.child,
    required this.value,
    this.color = Colors.amber,
  });

  final Widget child;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        child,
        Container(
          padding: EdgeInsets.all(1.0),
          // color: Theme.of(context).accentColor,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: color != null ? color : Colors.amber,
          ),
          constraints: BoxConstraints(
            minWidth: 16,
            minHeight: 16,
          ),
          child: Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
            ),
          ),
        ),
      ],
    );
  }
}
