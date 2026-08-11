// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Smart Expense Tracker';

  @override
  String get navHome => 'Home';

  @override
  String get navTransactions => 'Transactions';

  @override
  String get navBudget => 'Budget';

  @override
  String get navGoals => 'Goals';

  @override
  String get navProfile => 'Profile';

  @override
  String get welcomeBack => 'Welcome,';

  @override
  String get totalBalance => 'Total Balance';

  @override
  String get earned => 'Earned';

  @override
  String get spent => 'Spent';

  @override
  String get saved => 'Saved';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get addExpense => 'Add Expense';

  @override
  String get addIncome => 'Add Income';

  @override
  String get transfer => 'Transfer';

  @override
  String get scanReceipt => 'Scan Receipt';

  @override
  String get recentTransactions => 'Recent Transactions';

  @override
  String get seeAll => 'See All';

  @override
  String get selectType => 'Select Type';

  @override
  String get selectCategory => 'Select Category';

  @override
  String get dateTime => 'Date & Time';

  @override
  String get amount => 'Amount';

  @override
  String get noteOptional => 'Note (Optional)';

  @override
  String get continueLabel => 'Continue';

  @override
  String get budget => 'Budget';

  @override
  String get monthly => 'Monthly';

  @override
  String get yearly => 'Yearly';

  @override
  String left(String amount) {
    return '$amount left';
  }
}
