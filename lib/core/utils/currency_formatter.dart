import 'package:intl/intl.dart';

/// Formats amounts using the app's selected locale/currency.
///
/// Wraps [NumberFormat.currency] so screens never hand-roll "$" or "Br"
/// prefixes — swapping currency (e.g. USD -> ETB) is then a one-line
/// change wherever [CurrencyFormatter] is constructed (typically once,
/// in a settings-backed provider).
class CurrencyFormatter {
  CurrencyFormatter({required String locale, required String currencyCode})
      : _format = NumberFormat.currency(
    locale: locale,
    name: currencyCode,
    symbol: _symbolFor(currencyCode),
  );

  final NumberFormat _format;

  String format(num amount) => _format.format(amount);

  /// Signed variant: "+$2,354.00" for income, "-$84.50" for expenses.
  String formatSigned(num amount, {required bool isIncome}) {
    final sign = isIncome ? '+' : '-';
    return '$sign${_format.format(amount.abs())}';
  }

  static String _symbolFor(String currencyCode) {
    switch (currencyCode) {
      case 'USD':
        return '\$';
      case 'ETB':
        return 'Br ';
      default:
        return '$currencyCode ';
    }
  }
}