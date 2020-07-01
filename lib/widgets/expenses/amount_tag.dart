import 'package:flutter/material.dart';

class AmountTag extends StatelessWidget {
  final String amount;
  AmountTag(this.amount);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.5),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(5.0)),
      child: Text(
        '₹$amount',
        style: TextStyle(
            color: Colors.green[600],
            fontSize: 15,
            fontWeight: FontWeight.bold),
      ),
    );
  }
}
