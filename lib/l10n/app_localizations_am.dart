// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Amharic (`am`).
class AppLocalizationsAm extends AppLocalizations {
  AppLocalizationsAm([String locale = 'am']) : super(locale);

  @override
  String get appTitle => 'ዘመናዊ ወጪ መከታተያ';

  @override
  String get navHome => 'መነሻ';

  @override
  String get navTransactions => 'ግብይቶች';

  @override
  String get navBudget => 'በጀት';

  @override
  String get navGoals => 'ግቦች';

  @override
  String get navProfile => 'መገለጫ';

  @override
  String get welcomeBack => 'እንኳን ደህና መጡ,';

  @override
  String get totalBalance => 'ጠቅላላ ሂሳብ';

  @override
  String get earned => 'ገቢ';

  @override
  String get spent => 'ወጪ';

  @override
  String get saved => 'ቁጠባ';

  @override
  String get quickActions => 'ፈጣን ተግባራት';

  @override
  String get addExpense => 'ወጪ ጨምር';

  @override
  String get addIncome => 'ገቢ ጨምር';

  @override
  String get transfer => 'ማዘዋወር';

  @override
  String get scanReceipt => 'ደረሰኝ ቃኝ';

  @override
  String get recentTransactions => 'የቅርብ ጊዜ ግብይቶች';

  @override
  String get seeAll => 'ሁሉንም ይመልከቱ';

  @override
  String get selectType => 'ዓይነት ይምረጡ';

  @override
  String get selectCategory => 'ምድብ ይምረጡ';

  @override
  String get dateTime => 'ቀን እና ሰዓት';

  @override
  String get amount => 'መጠን';

  @override
  String get noteOptional => 'ማስታወሻ (አማራጭ)';

  @override
  String get continueLabel => 'ቀጥል';

  @override
  String get budget => 'በጀት';

  @override
  String get monthly => 'ወርሃዊ';

  @override
  String get yearly => 'ዓመታዊ';

  @override
  String left(String amount) {
    return '$amount ቀርቷል';
  }
}
