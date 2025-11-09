import 'package:flutter/cupertino.dart';

class TransactionItem {
  final String name;
  final IconData icon;
  final Color color;
  final PageRouteBuilder Function(Widget) transitionBuilder;

  TransactionItem(this.name, this.icon, this.color, this.transitionBuilder);
}