import 'package:flutter/services.dart';

class AdminInputValidation {
  AdminInputValidation._();

  static final RegExp _emailPattern = RegExp(
    r"^[A-Za-z0-9.!#$%&'()*+/=?^_`{|}~-]+@[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?(?:\.[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?)+$",
  );

  static final List<TextInputFormatter> safeTextFormatters = [
    FilteringTextInputFormatter.deny(RegExp(r'[\n\r\t]')),
  ];

  static List<TextInputFormatter> textFormatters(int maxLength) => [
        ...safeTextFormatters,
        LengthLimitingTextInputFormatter(maxLength),
      ];

  static List<TextInputFormatter> integerFormatters({int maxDigits = 9}) => [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(maxDigits),
      ];

  static List<TextInputFormatter> decimalFormatters({
    int maxIntegerDigits = 5,
    int decimalPlaces = 2,
    bool allowNegative = false,
  }) => [
        _DecimalShapeFormatter(
          maxIntegerDigits: maxIntegerDigits,
          decimalPlaces: decimalPlaces,
          allowNegative: allowNegative,
        ),
      ];

  static String? requiredText(
    String? value, {
    required String field,
    int minLength = 1,
    int maxLength = 120,
  }) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return '$field is required';
    if (text.length < minLength) {
      return '$field must be at least $minLength characters';
    }
    if (text.length > maxLength) {
      return '$field must be $maxLength characters or fewer';
    }
    return null;
  }

  static String? optionalText(
    String? value, {
    required String field,
    int minLength = 1,
    int maxLength = 120,
  }) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    if (text.length < minLength) {
      return '$field must be at least $minLength characters';
    }
    if (text.length > maxLength) {
      return '$field must be $maxLength characters or fewer';
    }
    return null;
  }

  static String? email(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Email is required';
    if (text.length > 254 || !_emailPattern.hasMatch(text)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? boundedNumber(
    String? value, {
    required String field,
    required double min,
    required double max,
    bool required = false,
    String? unit,
  }) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return required ? '$field is required' : null;

    final number = double.tryParse(text);
    if (number == null || !number.isFinite) return 'Enter a valid number';
    if (number < min || number > max) {
      final suffix = unit == null || unit.isEmpty ? '' : ' $unit';
      return '$field must be between ${_clean(min)} and ${_clean(max)}$suffix';
    }
    return null;
  }

  static String? boundedInteger(
    String? value, {
    required String field,
    required int min,
    required int max,
  }) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return '$field is required';
    final number = int.tryParse(text);
    if (number == null) return 'Enter a whole number';
    if (number < min || number > max) {
      return '$field must be between $min and $max';
    }
    return null;
  }

  static String? coordinate(
    String? value, {
    required String field,
    required double min,
    required double max,
  }) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    return boundedNumber(
      text,
      field: field,
      min: min,
      max: max,
    );
  }

  static String _clean(double value) {
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value.toString();
  }
}

class _DecimalShapeFormatter extends TextInputFormatter {
  const _DecimalShapeFormatter({
    required this.maxIntegerDigits,
    required this.decimalPlaces,
    required this.allowNegative,
  });

  final int maxIntegerDigits;
  final int decimalPlaces;
  final bool allowNegative;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    if (text.isEmpty) return newValue;

    final sign = allowNegative ? '-?' : '';
    final expression = RegExp(
      '^$sign\\d{0,$maxIntegerDigits}(?:\\.\\d{0,$decimalPlaces})?\$',
    );

    return expression.hasMatch(text) ? newValue : oldValue;
  }
}
