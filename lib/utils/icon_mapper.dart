import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class IconMapper {
  static IconData fromString(String iconName) {
    switch (iconName) {
      // Analgésicos
      case 'bandaids':
        return PhosphorIconsFill.bandaids;
      // Antibióticos
      case 'shieldPlus':
        return PhosphorIconsFill.shieldPlus;

      // Cardiovasculares
      case 'heartbeat':
        return PhosphorIconsFill.heartbeat;
      // Escalas / otros
      default:
        return PhosphorIconsFill.pill;
    }
  }
}
