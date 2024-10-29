import 'package:flutter/material.dart';

IconData getIcon(int index) {
  switch (index) {
    case 1:
      return Icons.sports_basketball_rounded;
    case 2:
      return Icons.local_pizza;
    case 3:
      return Icons.movie;
    case 4:
      return Icons.school;
    case 5:
      return Icons.miscellaneous_services;
    default:
      return Icons.train;
  }
}
