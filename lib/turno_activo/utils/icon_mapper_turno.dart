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
      // Aquí irás agregando más conforme crezca tu JSON
      default:
        return PhosphorIconsRegular.clipboardText;
    }
  }
}
