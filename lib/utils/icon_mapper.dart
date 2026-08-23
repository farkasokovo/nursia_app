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
      // Antiinflamatorios
      case 'thermometer':
        return PhosphorIconsFill.thermometer;
      // Diuréticos / Anticoagulantes
      case 'drop':
        return PhosphorIconsFill.drop;
      // Insulinas
      case 'syringe':
        return PhosphorIconsFill.syringe;
      // Protectores gástricos
      case 'shield':
        return PhosphorIconsFill.shield;
      // Antieméticos
      case 'pill':
        return PhosphorIconsFill.pill;
      // Broncodilatadores
      case 'wind':
        return PhosphorIconsFill.wind;
      // Escalas / otros
      default:
        return PhosphorIconsFill.syringe;
    }
  }
}
