import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class IconMapper {
  static IconData getIcon(String nombre) {
    switch (nombre) {
      case 'bathtub':
        return PhosphorIconsRegular.bathtub;
      case 'bandage':
        return PhosphorIconsRegular.bandaids;
      case 'drop':
        return PhosphorIconsRegular.drop;
      case 'heartbeat':
        return PhosphorIconsRegular.heartbeat;
      case 'wheelchair':
        return PhosphorIconsRegular.wheelchair;
      case 'syringe':
        return PhosphorIconsRegular.syringe;
      case 'clipboardText':
        return PhosphorIconsRegular.clipboardText;
      case 'forkKnife':
        return PhosphorIconsRegular.forkKnife;
      case 'testTube':
        return PhosphorIconsRegular.testTube;
      case 'wind':
        return PhosphorIconsRegular.wind;
      case 'shieldPlus':
        return PhosphorIconsRegular.shieldPlus;
      // Aquí irás agregando más conforme crezca tu JSON
      default:
        return PhosphorIconsRegular.clipboardText;
    }
  }
}
