import 'package:flutter/material.dart';

class Expense {
  final String id;
  final String title;
  final String description;
  final double amount;
  final String image;
  final bool isFavorite;
  final String userEmail;
  final String userId;
  final DateTime createdAt;

  Expense(
      {@required this.id,
      @required this.title,
      this.description,
      @required this.amount,
      @required this.image,
      this.isFavorite = false,
      @required this.userEmail,
      @required this.userId,
      @required this.createdAt});
}
