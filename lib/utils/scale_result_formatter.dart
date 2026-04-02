class ScaleResultFormatter {
  static String formatWithNV({required Map<String, int?> parameters}) {
    final hayNV = parameters.values.contains(null);

    if (!hayNV) {
      final total = parameters.values.whereType<int>().reduce((a, b) => a + b);

      return "$total pts";
    }

    return parameters.entries
        .map((entry) => "${entry.key} (${entry.value ?? "NV"})")
        .join("\n");
  }
}
