const List<String> _months = <String>[
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

String formatDateTime(DateTime dt) {
  final String month = _months[dt.month - 1];
  final String hour = dt.hour.toString().padLeft(2, '0');
  final String minute = dt.minute.toString().padLeft(2, '0');
  return '${dt.day} $month, $hour:$minute';
}

String formatDateOnly(DateTime dt) {
  final String month = _months[dt.month - 1];
  return '${dt.day} $month ${dt.year}';
}

String formatTimeOnly(int hour, int minute) {
  final String h = hour.toString().padLeft(2, '0');
  final String m = minute.toString().padLeft(2, '0');
  return '$h:$m';
}