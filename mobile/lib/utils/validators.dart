final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

String? validateRequired(String? value, String label) {
  if (value == null || value.trim().isEmpty) return '$label wajib diisi';
  return null;
}

String? validateEmail(String? value) {
  final required = validateRequired(value, 'Email');
  if (required != null) return required;
  if (!_emailPattern.hasMatch(value!.trim())) {
    return 'Format email tidak valid';
  }
  return null;
}

String? validateMinLength(String? value, int min, String label) {
  final required = validateRequired(value, label);
  if (required != null) return required;
  if (value!.length < min) {
    return '$label minimal $min karakter';
  }
  return null;
}

String? validatePassword(String? value) {
  return validateRequired(value, 'Password');
}

String? validateNewPassword(String? value) {
  return validateMinLength(value, 6, 'Password');
}

String? validateConfirmPassword(String? value, String password) {
  final required = validateRequired(value, 'Konfirmasi password');
  if (required != null) return required;
  if (value != password) return 'Konfirmasi password tidak sama';
  return null;
}

String? validateOptionalUrl(String? value) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) return null;
  final uri = Uri.tryParse(text);
  if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
    return 'Masukkan URL gambar yang valid';
  }
  if (uri.scheme != 'http' && uri.scheme != 'https') {
    return 'URL harus diawali http:// atau https://';
  }
  return null;
}
