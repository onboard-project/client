extension StringExt on String {
  String capitalize() {
    if (trim().isNotEmpty) {
      final words = _removeExtraSpaces()
          .split(' ')
          .map((e) => e[0].toUpperCase() + (e.length > 1 ? e.substring(1) : ''))
          .toList();
      return words.join(' ');
    } else {
      return this;
    }
  }

  String _removeExtraSpaces() {
    if (trim().isEmpty) return '';
    return trim().replaceAll(RegExp(' +'), ' ');
  }
}
