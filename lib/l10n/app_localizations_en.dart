// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Namikibun';

  @override
  String get appSubtitle => 'Visualize your mood waves';

  @override
  String get home => 'Home';

  @override
  String get stats => 'Stats';

  @override
  String get settings => 'Settings';

  @override
  String get todayRecordPrompt => 'Let\'s record today\'s mood';

  @override
  String get todayAverageMood => 'Today\'s average mood';

  @override
  String recordCount(int count) {
    return '$count records';
  }

  @override
  String get streak => 'Streak';

  @override
  String streakDays(int days) {
    return '$days-day streak';
  }

  @override
  String get days => 'days';

  @override
  String monthYear(int year, int month) {
    return '$month/$year';
  }

  @override
  String get weekdayMon => 'Mon';

  @override
  String get weekdayTue => 'Tue';

  @override
  String get weekdayWed => 'Wed';

  @override
  String get weekdayThu => 'Thu';

  @override
  String get weekdayFri => 'Fri';

  @override
  String get weekdaySat => 'Sat';

  @override
  String get weekdaySun => 'Sun';

  @override
  String get morning => 'Morning';

  @override
  String get afternoon => 'Afternoon';

  @override
  String get evening => 'Evening';

  @override
  String get tapToRecord => 'Tap to record';

  @override
  String get addRecord => 'Add record';

  @override
  String get moodGood => 'Good';

  @override
  String get moodBad => 'Bad';

  @override
  String get tryAddingAnother => 'Try adding another record';

  @override
  String get tapToRecordToday => 'Tap to record today\'s mood';

  @override
  String slotMood(String slotName) {
    return '$slotName\'s mood';
  }

  @override
  String get chooseMood => 'Choose your current mood';

  @override
  String get moodVeryBad => 'Very bad';

  @override
  String get moodBadLabel => 'Bad';

  @override
  String get moodNormal => 'Normal';

  @override
  String get moodGoodLabel => 'Good';

  @override
  String get moodVeryGood => 'Very good';

  @override
  String get quickNote => 'Quick note';

  @override
  String get tags => 'Tags';

  @override
  String get photo => 'Photo';

  @override
  String get addPhoto => 'Add photo';

  @override
  String get addPhotoPremium => 'Add photo (Premium)';

  @override
  String get save => 'Save';

  @override
  String get update => 'Update';

  @override
  String get tagWork => 'Work';

  @override
  String get tagExercise => 'Exercise';

  @override
  String get tagMeals => 'Meals';

  @override
  String get tagSocial => 'Social';

  @override
  String get tagWeather => 'Weather';

  @override
  String get tagOther => 'Other';

  @override
  String get weeklySummary => 'This Week\'s Summary';

  @override
  String get thisWeekAverage => 'This week\'s average';

  @override
  String get vsLastWeek => 'vs last week';

  @override
  String get averageMoodByTime => 'Average mood by time';

  @override
  String get monthlyMoodTrend => 'Monthly mood trend';

  @override
  String get averageMoodByTag => 'Average mood by tag';

  @override
  String get tagCorrelationInsights => 'Tag correlation insights';

  @override
  String get thisMonthHighlights => 'This month\'s highlights';

  @override
  String get bestDay => 'Best day';

  @override
  String get worstDay => 'Worst day';

  @override
  String get dayOfWeekPattern => 'Day of week pattern';

  @override
  String get monthlyComparison => 'Monthly comparison';

  @override
  String get lastMonth => 'Last month';

  @override
  String get thisMonth => 'This month';

  @override
  String get noData => 'No data';

  @override
  String tagDaysMoodHigher(String tag, String sign, String value) {
    return 'On days with \"$tag\", mood is $sign$value';
  }

  @override
  String get watchVideoToUnlock => 'Watch video to unlock 24h';

  @override
  String get unlockWithPremium => 'Unlock with Premium';

  @override
  String get unlockWithPremiumShort => 'Unlock with Premium';

  @override
  String get unlocked => 'Unlocked';

  @override
  String get remaining => 'remaining';

  @override
  String get hours => 'hours';

  @override
  String get detailedAnalytics => 'Detailed analytics';

  @override
  String get detailedAnalyticsDesc =>
      'Monthly comparison, tag correlation, day pattern';

  @override
  String get statsMinDays => 'Record for 3+ days\nto see statistics';

  @override
  String dayLabel(int day) {
    return '$day';
  }

  @override
  String average(String value) {
    return 'Avg $value';
  }

  @override
  String improvedFromLastMonth(String value) {
    return '+$value from last month';
  }

  @override
  String declinedFromLastMonth(String value) {
    return '$value from last month';
  }

  @override
  String get slotManagement => 'Slot Management';

  @override
  String get tagManagement => 'Tag Management';

  @override
  String get notifications => 'Notifications';

  @override
  String get theme => 'Theme';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSystem => 'System';

  @override
  String get security => 'Security';

  @override
  String get passcodeLock => 'Passcode Lock';

  @override
  String get passcodeLockDesc => 'Require lock on app launch';

  @override
  String get store => 'Store';

  @override
  String get openStore => 'Open Store';

  @override
  String get purchased => 'Purchased';

  @override
  String get version => 'Version';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get privacyPolicyDesc => 'All data is stored on your device';

  @override
  String get renameSlot => 'Rename Slot';

  @override
  String get addSlot => 'Add Slot';

  @override
  String get slotName => 'Slot name';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get deleteSlotConfirm => 'Delete this slot?';

  @override
  String deleteSlotConfirmDetail(String name) {
    return 'Delete \"$name\"?\nPast records will be kept.';
  }

  @override
  String get addTag => 'Add Tag';

  @override
  String get editTag => 'Edit Tag';

  @override
  String get tagName => 'Tag name';

  @override
  String get chooseColor => 'Choose color';

  @override
  String get deleteTag => 'Delete Tag';

  @override
  String deleteTagConfirmDetail(String name) {
    return 'Delete \"$name\"?\nPast records will not be affected.';
  }

  @override
  String get deleteRecord => 'Delete record';

  @override
  String get deleteRecordConfirm => 'Delete this record?';

  @override
  String get edit => 'Edit';

  @override
  String get slotHintExample => 'e.g. After work';

  @override
  String get tagHintExample => 'e.g. Reading';

  @override
  String get add => 'Add';

  @override
  String get tagAlreadyExists => 'A tag with that name already exists';

  @override
  String notificationTime(String time) {
    return 'Notify $time';
  }

  @override
  String get recorded => 'Recorded';

  @override
  String get selectSlot => 'Select slot';

  @override
  String get deleteSlot => 'Delete slot';

  @override
  String get other => 'Other';

  @override
  String get namikibunStore => 'Namikibun Store';

  @override
  String get namikibunPremium => 'Namikibun Premium';

  @override
  String get freeTrialDays => '7-day free trial, auto-charged after';

  @override
  String autoChargeNotice(String monthlyPrice, String yearlyPrice) {
    return 'After the free trial ends, you will be automatically charged $monthlyPrice/month (monthly plan) or $yearlyPrice/year (yearly plan). You can cancel anytime.';
  }

  @override
  String get monthly => 'Monthly';

  @override
  String get yearly => 'Yearly';

  @override
  String get perMonth => 'per month';

  @override
  String get savePercent => 'Save';

  @override
  String get noAds => 'No ads';

  @override
  String get unlimitedSlots => 'Unlimited slots';

  @override
  String get photoAttachment => 'Photo attachment';

  @override
  String get removeAdsOnly => 'Remove ads only';

  @override
  String get oneTimePurchase => 'One-time purchase';

  @override
  String get forThoseWhoJustWantRemoveAds =>
      'For those who just want to remove ads';

  @override
  String get restorePurchases => 'Restore purchases';

  @override
  String get restoringPurchases => 'Restoring purchases...';

  @override
  String get termsOfUse => 'Terms of use';

  @override
  String get premiumMember => 'Premium member';

  @override
  String get premiumRegister => 'Register Premium';

  @override
  String get premiumActiveDesc => 'All features available';

  @override
  String get premiumInactiveDesc =>
      'No ads, unlimited slots, detailed analytics';

  @override
  String get perMonthPrice => '~\$3.30/mo — Save 31%';

  @override
  String yearlyPrice(String price) {
    return 'Yearly $price';
  }

  @override
  String monthlyPrice(String price) {
    return 'Monthly $price';
  }

  @override
  String get welcomeToNamikibun => 'Welcome to Namikibun';

  @override
  String get onboardingDesc1 =>
      'Record your daily mood waves\nand observe your mind\'s rhythm';

  @override
  String get recordMoodIn5Levels => 'Record mood in 5 levels';

  @override
  String get reviewOnCalendar => 'Review on calendar';

  @override
  String get onboardingDesc3 =>
      'See your monthly mood waves at a glance\nAnalyze trends with stats and graphs';

  @override
  String get letsGetStarted => 'Let\'s get started';

  @override
  String get onboardingDesc4 =>
      'Record your mood in morning,\nafternoon, and evening';

  @override
  String get getStarted => 'Get started';

  @override
  String get skip => 'Skip';

  @override
  String get next => 'Next';

  @override
  String get enterPasscode => 'Enter passcode';

  @override
  String get newPasscode => 'New passcode';

  @override
  String get confirmPasscode => 'Confirm passcode';

  @override
  String get passcodesDoNotMatch => 'Passcodes don\'t match';

  @override
  String get useBiometricAuth => 'Use biometric auth';

  @override
  String get unlockApp => 'Unlock app';

  @override
  String get incorrectPasscode => 'Incorrect passcode';

  @override
  String get setPasscode => 'Set passcode';

  @override
  String get reenterPasscode => 'Re-enter passcode';

  @override
  String get disablePasscode => 'Disable passcode';

  @override
  String get enterCurrentPasscode => 'Enter your current passcode';

  @override
  String get passcodeLabel => 'Passcode';

  @override
  String get letsRecordMood => 'Let\'s record your mood';

  @override
  String get loading => 'Loading...';

  @override
  String get errorOccurred => 'An error occurred';

  @override
  String get error => 'Error';

  @override
  String errorWithMessage(String message) {
    return 'Error: $message';
  }

  @override
  String get tagLoadFailed => 'Failed to load tags';

  @override
  String get memoHint => 'The meeting was long';

  @override
  String get debugOptions => 'Developer Options';

  @override
  String get debugDisable => 'Disable debug mode';

  @override
  String get debugDisableDesc => 'For testing release behavior';

  @override
  String get premiumStatus => 'Premium status';

  @override
  String get premiumActive => 'Active';

  @override
  String get premiumInactive => 'Inactive';

  @override
  String get adFreeStatus => 'Ad-free status';

  @override
  String get notPurchased => 'Not purchased';

  @override
  String get videoUnlockStatus => 'Video unlock status';

  @override
  String get videoUnlocked => 'Unlocked';

  @override
  String get videoLocked => 'Locked';

  @override
  String get resetFirstLaunch => 'Reset first launch';

  @override
  String get resetFirstLaunchDone => 'First launch date has been reset';

  @override
  String get resetVideoTimestamp => 'Reset video';

  @override
  String get resetVideoTimestampDone => 'Video timestamp has been reset';

  @override
  String get resetOnboarding => 'Reset onboarding';

  @override
  String get resetOnboardingDone => 'Onboarding has been reset';

  @override
  String get notificationTitle => 'Namikibun';

  @override
  String notificationBody(String slotName) {
    return 'Let\'s record your $slotName mood';
  }

  @override
  String get notificationChannelName => 'Mood Reminder';

  @override
  String get notificationChannelDesc => 'Mood recording reminder notifications';

  @override
  String get language => 'Language';

  @override
  String get languageJapanese => '日本語';

  @override
  String get languageEnglish => 'English';

  @override
  String get slotFilterAll => 'All';

  @override
  String get moodByTimeSlot => 'Mood by time slot';

  @override
  String get slotFilterPremiumDesc => 'Select a slot to view mood by time';

  @override
  String get premiumOnlyFeature => 'This feature is Premium only';

  @override
  String displayDate(int month, int day, String weekday) {
    return '$month/$day ($weekday)';
  }
}
