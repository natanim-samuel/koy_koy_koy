/// Rule-based auto-categorization for transaction notes/merchant names.
///
/// This is the MVP "smart" feature: keyword-matching against a note or
/// merchant string to suggest a category before the person picks one
/// manually. It's intentionally simple (no ML, no network call) so it
/// works fully offline and is easy to extend — swap [defaultRules] for a
/// user-editable rule set backed by the database if you want people to
/// teach the app their own merchants.
class AutoCategorizer {
  AutoCategorizer({Map<String, List<String>>? rules})
      : _rules = rules ?? defaultRules;

  final Map<String, List<String>> _rules;

  /// Returns the best-matching category name for [input], or null if
  /// nothing matched (caller should fall back to "Uncategorized" and let
  /// the person pick manually).
  String? categorize(String input) {
    if (input.trim().isEmpty) return null;
    final normalized = input.toLowerCase();

    String? bestCategory;
    int bestScore = 0;

    for (final entry in _rules.entries) {
      final score = entry.value.where(normalized.contains).length;
      if (score > bestScore) {
        bestScore = score;
        bestCategory = entry.key;
      }
    }
    return bestCategory;
  }

  /// Default keyword rules. Keep each list lower-case; matching is
  /// substring-based against the lower-cased input.
  static const Map<String, List<String>> defaultRules = {
    'Food & Drinks': [
      'grocery', 'groceries', 'restaurant', 'cafe', 'coffee', 'supermarket',
      'food', 'lunch', 'dinner', 'breakfast', 'bakery', 'market',
    ],
    'Transport': [
      'uber', 'lyft', 'taxi', 'fuel', 'gas station', 'petrol', 'parking',
      'bus', 'train', 'transit', 'ride',
    ],
    'Entertainment': [
      'netflix', 'spotify', 'cinema', 'movie', 'concert', 'game', 'steam',
      'hulu', 'disney+', 'youtube premium',
    ],
    'Bills & Utilities': [
      'electricity', 'electric bill', 'water bill', 'internet', 'wifi',
      'phone bill', 'insurance', 'rent', 'utility', 'utilities',
    ],
    'Shopping': [
      'amazon', 'mall', 'clothing', 'shoes', 'electronics', 'store',
      'shop', 'retail',
    ],
    'Income': [
      'salary', 'payroll', 'freelance', 'invoice', 'bonus', 'refund',
      'deposit', 'payment received',
    ],
  };
}