const _months = [
  'Januari',
  'Februari',
  'Maret',
  'April',
  'Mei',
  'Juni',
  'Juli',
  'Agustus',
  'September',
  'Oktober',
  'November',
  'Desember',
];

String formatPostDate(DateTime? date, {DateTime? now}) {
  if (date == null) return '';
  final localDate = date.toLocal();
  final reference = (now ?? DateTime.now()).toLocal();
  final difference = reference.difference(localDate);

  if (difference.isNegative || difference.inMinutes < 1) {
    return 'Baru saja';
  }
  if (difference.inMinutes < 60) {
    return '${difference.inMinutes} menit lalu';
  }
  if (difference.inHours < 24) {
    return '${difference.inHours} jam lalu';
  }
  if (difference.inDays < 7) {
    return '${difference.inDays} hari lalu';
  }
  return formatFullDate(localDate);
}

String formatFullDate(DateTime date) {
  final local = date.toLocal();
  return '${local.day} ${_months[local.month - 1]} ${local.year}';
}
