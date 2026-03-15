import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In ja, this message translates to:
  /// **'波きぶん'**
  String get appTitle;

  /// No description provided for @appSubtitle.
  ///
  /// In ja, this message translates to:
  /// **'気分の浮き沈みを可視化'**
  String get appSubtitle;

  /// No description provided for @home.
  ///
  /// In ja, this message translates to:
  /// **'ホーム'**
  String get home;

  /// No description provided for @stats.
  ///
  /// In ja, this message translates to:
  /// **'統計'**
  String get stats;

  /// No description provided for @settings.
  ///
  /// In ja, this message translates to:
  /// **'設定'**
  String get settings;

  /// No description provided for @todayRecordPrompt.
  ///
  /// In ja, this message translates to:
  /// **'今日の気分を記録しましょう'**
  String get todayRecordPrompt;

  /// No description provided for @todayAverageMood.
  ///
  /// In ja, this message translates to:
  /// **'今日の平均気分'**
  String get todayAverageMood;

  /// No description provided for @recordCount.
  ///
  /// In ja, this message translates to:
  /// **'{count}件の記録'**
  String recordCount(int count);

  /// No description provided for @streak.
  ///
  /// In ja, this message translates to:
  /// **'連続記録'**
  String get streak;

  /// No description provided for @streakDays.
  ///
  /// In ja, this message translates to:
  /// **'連続{days}日記録中'**
  String streakDays(int days);

  /// No description provided for @days.
  ///
  /// In ja, this message translates to:
  /// **'日'**
  String get days;

  /// No description provided for @monthYear.
  ///
  /// In ja, this message translates to:
  /// **'{year}年{month}月'**
  String monthYear(int year, int month);

  /// No description provided for @weekdayMon.
  ///
  /// In ja, this message translates to:
  /// **'月'**
  String get weekdayMon;

  /// No description provided for @weekdayTue.
  ///
  /// In ja, this message translates to:
  /// **'火'**
  String get weekdayTue;

  /// No description provided for @weekdayWed.
  ///
  /// In ja, this message translates to:
  /// **'水'**
  String get weekdayWed;

  /// No description provided for @weekdayThu.
  ///
  /// In ja, this message translates to:
  /// **'木'**
  String get weekdayThu;

  /// No description provided for @weekdayFri.
  ///
  /// In ja, this message translates to:
  /// **'金'**
  String get weekdayFri;

  /// No description provided for @weekdaySat.
  ///
  /// In ja, this message translates to:
  /// **'土'**
  String get weekdaySat;

  /// No description provided for @weekdaySun.
  ///
  /// In ja, this message translates to:
  /// **'日'**
  String get weekdaySun;

  /// No description provided for @morning.
  ///
  /// In ja, this message translates to:
  /// **'朝'**
  String get morning;

  /// No description provided for @afternoon.
  ///
  /// In ja, this message translates to:
  /// **'昼'**
  String get afternoon;

  /// No description provided for @evening.
  ///
  /// In ja, this message translates to:
  /// **'夜'**
  String get evening;

  /// No description provided for @tapToRecord.
  ///
  /// In ja, this message translates to:
  /// **'タップして記録'**
  String get tapToRecord;

  /// No description provided for @addRecord.
  ///
  /// In ja, this message translates to:
  /// **'記録を追加'**
  String get addRecord;

  /// No description provided for @moodGood.
  ///
  /// In ja, this message translates to:
  /// **'良い'**
  String get moodGood;

  /// No description provided for @moodBad.
  ///
  /// In ja, this message translates to:
  /// **'悪い'**
  String get moodBad;

  /// No description provided for @tryAddingAnother.
  ///
  /// In ja, this message translates to:
  /// **'もう1つ記録してみましょう'**
  String get tryAddingAnother;

  /// No description provided for @tapToRecordToday.
  ///
  /// In ja, this message translates to:
  /// **'タップして今日の気分を記録しましょう'**
  String get tapToRecordToday;

  /// No description provided for @slotMood.
  ///
  /// In ja, this message translates to:
  /// **'{slotName}の気分'**
  String slotMood(String slotName);

  /// No description provided for @chooseMood.
  ///
  /// In ja, this message translates to:
  /// **'今の気分を選んでください'**
  String get chooseMood;

  /// No description provided for @moodVeryBad.
  ///
  /// In ja, this message translates to:
  /// **'とても悪い'**
  String get moodVeryBad;

  /// No description provided for @moodBadLabel.
  ///
  /// In ja, this message translates to:
  /// **'悪い'**
  String get moodBadLabel;

  /// No description provided for @moodNormal.
  ///
  /// In ja, this message translates to:
  /// **'普通'**
  String get moodNormal;

  /// No description provided for @moodGoodLabel.
  ///
  /// In ja, this message translates to:
  /// **'良い'**
  String get moodGoodLabel;

  /// No description provided for @moodVeryGood.
  ///
  /// In ja, this message translates to:
  /// **'とても良い'**
  String get moodVeryGood;

  /// No description provided for @quickNote.
  ///
  /// In ja, this message translates to:
  /// **'ひとことメモ'**
  String get quickNote;

  /// No description provided for @tags.
  ///
  /// In ja, this message translates to:
  /// **'タグ'**
  String get tags;

  /// No description provided for @photo.
  ///
  /// In ja, this message translates to:
  /// **'写真'**
  String get photo;

  /// No description provided for @addPhoto.
  ///
  /// In ja, this message translates to:
  /// **'写真を追加'**
  String get addPhoto;

  /// No description provided for @addPhotoPremium.
  ///
  /// In ja, this message translates to:
  /// **'写真を追加（プレミアム）'**
  String get addPhotoPremium;

  /// No description provided for @save.
  ///
  /// In ja, this message translates to:
  /// **'保存'**
  String get save;

  /// No description provided for @update.
  ///
  /// In ja, this message translates to:
  /// **'更新'**
  String get update;

  /// No description provided for @tagWork.
  ///
  /// In ja, this message translates to:
  /// **'仕事'**
  String get tagWork;

  /// No description provided for @tagExercise.
  ///
  /// In ja, this message translates to:
  /// **'運動'**
  String get tagExercise;

  /// No description provided for @tagMeals.
  ///
  /// In ja, this message translates to:
  /// **'食事'**
  String get tagMeals;

  /// No description provided for @tagSocial.
  ///
  /// In ja, this message translates to:
  /// **'人間関係'**
  String get tagSocial;

  /// No description provided for @tagWeather.
  ///
  /// In ja, this message translates to:
  /// **'天気'**
  String get tagWeather;

  /// No description provided for @tagOther.
  ///
  /// In ja, this message translates to:
  /// **'その他'**
  String get tagOther;

  /// No description provided for @weeklySummary.
  ///
  /// In ja, this message translates to:
  /// **'今週のサマリー'**
  String get weeklySummary;

  /// No description provided for @thisWeekAverage.
  ///
  /// In ja, this message translates to:
  /// **'今週の平均'**
  String get thisWeekAverage;

  /// No description provided for @vsLastWeek.
  ///
  /// In ja, this message translates to:
  /// **'先週比'**
  String get vsLastWeek;

  /// No description provided for @averageMoodByTime.
  ///
  /// In ja, this message translates to:
  /// **'時間帯別の平均気分'**
  String get averageMoodByTime;

  /// No description provided for @monthlyMoodTrend.
  ///
  /// In ja, this message translates to:
  /// **'月全体の気分推移'**
  String get monthlyMoodTrend;

  /// No description provided for @averageMoodByTag.
  ///
  /// In ja, this message translates to:
  /// **'タグ別平均気分'**
  String get averageMoodByTag;

  /// No description provided for @tagCorrelationInsights.
  ///
  /// In ja, this message translates to:
  /// **'タグ相関インサイト'**
  String get tagCorrelationInsights;

  /// No description provided for @thisMonthHighlights.
  ///
  /// In ja, this message translates to:
  /// **'今月のハイライト'**
  String get thisMonthHighlights;

  /// No description provided for @bestDay.
  ///
  /// In ja, this message translates to:
  /// **'最高の日'**
  String get bestDay;

  /// No description provided for @worstDay.
  ///
  /// In ja, this message translates to:
  /// **'最低の日'**
  String get worstDay;

  /// No description provided for @dayOfWeekPattern.
  ///
  /// In ja, this message translates to:
  /// **'曜日別パターン'**
  String get dayOfWeekPattern;

  /// No description provided for @monthlyComparison.
  ///
  /// In ja, this message translates to:
  /// **'月別比較'**
  String get monthlyComparison;

  /// No description provided for @lastMonth.
  ///
  /// In ja, this message translates to:
  /// **'先月'**
  String get lastMonth;

  /// No description provided for @thisMonth.
  ///
  /// In ja, this message translates to:
  /// **'今月'**
  String get thisMonth;

  /// No description provided for @noData.
  ///
  /// In ja, this message translates to:
  /// **'データなし'**
  String get noData;

  /// No description provided for @tagDaysMoodHigher.
  ///
  /// In ja, this message translates to:
  /// **'「{tag}」タグの日は平均気分が{sign}{value}'**
  String tagDaysMoodHigher(String tag, String sign, String value);

  /// No description provided for @watchVideoToUnlock.
  ///
  /// In ja, this message translates to:
  /// **'動画を見て24h解放'**
  String get watchVideoToUnlock;

  /// No description provided for @unlockWithPremium.
  ///
  /// In ja, this message translates to:
  /// **'プレミアムで常時解放'**
  String get unlockWithPremium;

  /// No description provided for @unlockWithPremiumShort.
  ///
  /// In ja, this message translates to:
  /// **'プレミアムで解放'**
  String get unlockWithPremiumShort;

  /// No description provided for @unlocked.
  ///
  /// In ja, this message translates to:
  /// **'解放中'**
  String get unlocked;

  /// No description provided for @remaining.
  ///
  /// In ja, this message translates to:
  /// **'残り'**
  String get remaining;

  /// No description provided for @hours.
  ///
  /// In ja, this message translates to:
  /// **'時間'**
  String get hours;

  /// No description provided for @detailedAnalytics.
  ///
  /// In ja, this message translates to:
  /// **'詳細分析'**
  String get detailedAnalytics;

  /// No description provided for @detailedAnalyticsDesc.
  ///
  /// In ja, this message translates to:
  /// **'月別比較・タグ相関・曜日別パターン'**
  String get detailedAnalyticsDesc;

  /// No description provided for @statsMinDays.
  ///
  /// In ja, this message translates to:
  /// **'3日以上記録すると\n統計が表示されます'**
  String get statsMinDays;

  /// No description provided for @dayLabel.
  ///
  /// In ja, this message translates to:
  /// **'{day}日'**
  String dayLabel(int day);

  /// No description provided for @average.
  ///
  /// In ja, this message translates to:
  /// **'平均 {value}'**
  String average(String value);

  /// No description provided for @improvedFromLastMonth.
  ///
  /// In ja, this message translates to:
  /// **'先月より +{value} 改善'**
  String improvedFromLastMonth(String value);

  /// No description provided for @declinedFromLastMonth.
  ///
  /// In ja, this message translates to:
  /// **'先月より {value} 低下'**
  String declinedFromLastMonth(String value);

  /// No description provided for @slotManagement.
  ///
  /// In ja, this message translates to:
  /// **'スロット管理'**
  String get slotManagement;

  /// No description provided for @tagManagement.
  ///
  /// In ja, this message translates to:
  /// **'タグ管理'**
  String get tagManagement;

  /// No description provided for @notifications.
  ///
  /// In ja, this message translates to:
  /// **'通知設定'**
  String get notifications;

  /// No description provided for @theme.
  ///
  /// In ja, this message translates to:
  /// **'テーマ'**
  String get theme;

  /// No description provided for @themeLight.
  ///
  /// In ja, this message translates to:
  /// **'ライト'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In ja, this message translates to:
  /// **'ダーク'**
  String get themeDark;

  /// No description provided for @themeSystem.
  ///
  /// In ja, this message translates to:
  /// **'システム'**
  String get themeSystem;

  /// No description provided for @security.
  ///
  /// In ja, this message translates to:
  /// **'セキュリティ'**
  String get security;

  /// No description provided for @passcodeLock.
  ///
  /// In ja, this message translates to:
  /// **'パスコードロック'**
  String get passcodeLock;

  /// No description provided for @passcodeLockDesc.
  ///
  /// In ja, this message translates to:
  /// **'アプリ起動時にロックを要求'**
  String get passcodeLockDesc;

  /// No description provided for @store.
  ///
  /// In ja, this message translates to:
  /// **'ストア'**
  String get store;

  /// No description provided for @openStore.
  ///
  /// In ja, this message translates to:
  /// **'ストアを開く'**
  String get openStore;

  /// No description provided for @purchased.
  ///
  /// In ja, this message translates to:
  /// **'購入済み'**
  String get purchased;

  /// No description provided for @version.
  ///
  /// In ja, this message translates to:
  /// **'バージョン'**
  String get version;

  /// No description provided for @privacyPolicy.
  ///
  /// In ja, this message translates to:
  /// **'プライバシーポリシー'**
  String get privacyPolicy;

  /// No description provided for @privacyPolicyDesc.
  ///
  /// In ja, this message translates to:
  /// **'データはすべて端末内に保存されます'**
  String get privacyPolicyDesc;

  /// No description provided for @renameSlot.
  ///
  /// In ja, this message translates to:
  /// **'スロット名を変更'**
  String get renameSlot;

  /// No description provided for @addSlot.
  ///
  /// In ja, this message translates to:
  /// **'スロットを追加'**
  String get addSlot;

  /// No description provided for @slotName.
  ///
  /// In ja, this message translates to:
  /// **'スロット名'**
  String get slotName;

  /// No description provided for @cancel.
  ///
  /// In ja, this message translates to:
  /// **'キャンセル'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In ja, this message translates to:
  /// **'削除'**
  String get delete;

  /// No description provided for @deleteSlotConfirm.
  ///
  /// In ja, this message translates to:
  /// **'このスロットを削除しますか？'**
  String get deleteSlotConfirm;

  /// No description provided for @deleteSlotConfirmDetail.
  ///
  /// In ja, this message translates to:
  /// **'「{name}」を削除しますか？\n過去の記録はそのまま残ります。'**
  String deleteSlotConfirmDetail(String name);

  /// No description provided for @addTag.
  ///
  /// In ja, this message translates to:
  /// **'タグを追加'**
  String get addTag;

  /// No description provided for @editTag.
  ///
  /// In ja, this message translates to:
  /// **'タグを編集'**
  String get editTag;

  /// No description provided for @tagName.
  ///
  /// In ja, this message translates to:
  /// **'タグ名'**
  String get tagName;

  /// No description provided for @chooseColor.
  ///
  /// In ja, this message translates to:
  /// **'色を選択'**
  String get chooseColor;

  /// No description provided for @deleteTag.
  ///
  /// In ja, this message translates to:
  /// **'タグを削除'**
  String get deleteTag;

  /// No description provided for @deleteTagConfirmDetail.
  ///
  /// In ja, this message translates to:
  /// **'「{name}」を削除しますか？\n過去の記録からは削除されません。'**
  String deleteTagConfirmDetail(String name);

  /// No description provided for @deleteRecord.
  ///
  /// In ja, this message translates to:
  /// **'記録を削除'**
  String get deleteRecord;

  /// No description provided for @deleteRecordConfirm.
  ///
  /// In ja, this message translates to:
  /// **'この記録を削除しますか？'**
  String get deleteRecordConfirm;

  /// No description provided for @edit.
  ///
  /// In ja, this message translates to:
  /// **'編集'**
  String get edit;

  /// No description provided for @slotHintExample.
  ///
  /// In ja, this message translates to:
  /// **'例: 仕事後'**
  String get slotHintExample;

  /// No description provided for @tagHintExample.
  ///
  /// In ja, this message translates to:
  /// **'例: 読書'**
  String get tagHintExample;

  /// No description provided for @add.
  ///
  /// In ja, this message translates to:
  /// **'追加'**
  String get add;

  /// No description provided for @tagAlreadyExists.
  ///
  /// In ja, this message translates to:
  /// **'同じ名前のタグが既に存在します'**
  String get tagAlreadyExists;

  /// No description provided for @notificationTime.
  ///
  /// In ja, this message translates to:
  /// **'通知 {time}'**
  String notificationTime(String time);

  /// No description provided for @recorded.
  ///
  /// In ja, this message translates to:
  /// **'記録済み'**
  String get recorded;

  /// No description provided for @selectSlot.
  ///
  /// In ja, this message translates to:
  /// **'スロットを選択'**
  String get selectSlot;

  /// No description provided for @deleteSlot.
  ///
  /// In ja, this message translates to:
  /// **'スロットを削除'**
  String get deleteSlot;

  /// No description provided for @other.
  ///
  /// In ja, this message translates to:
  /// **'その他'**
  String get other;

  /// No description provided for @namikibunStore.
  ///
  /// In ja, this message translates to:
  /// **'波きぶん ストア'**
  String get namikibunStore;

  /// No description provided for @namikibunPremium.
  ///
  /// In ja, this message translates to:
  /// **'波きぶんプレミアム'**
  String get namikibunPremium;

  /// No description provided for @freeTrialDays.
  ///
  /// In ja, this message translates to:
  /// **'7日間無料体験'**
  String get freeTrialDays;

  /// No description provided for @monthly.
  ///
  /// In ja, this message translates to:
  /// **'月額'**
  String get monthly;

  /// No description provided for @yearly.
  ///
  /// In ja, this message translates to:
  /// **'年額'**
  String get yearly;

  /// No description provided for @perMonth.
  ///
  /// In ja, this message translates to:
  /// **'月あたり'**
  String get perMonth;

  /// No description provided for @savePercent.
  ///
  /// In ja, this message translates to:
  /// **'お得'**
  String get savePercent;

  /// No description provided for @noAds.
  ///
  /// In ja, this message translates to:
  /// **'広告完全非表示'**
  String get noAds;

  /// No description provided for @unlimitedSlots.
  ///
  /// In ja, this message translates to:
  /// **'スロット無制限'**
  String get unlimitedSlots;

  /// No description provided for @photoAttachment.
  ///
  /// In ja, this message translates to:
  /// **'写真添付'**
  String get photoAttachment;

  /// No description provided for @removeAdsOnly.
  ///
  /// In ja, this message translates to:
  /// **'広告除去のみ'**
  String get removeAdsOnly;

  /// No description provided for @oneTimePurchase.
  ///
  /// In ja, this message translates to:
  /// **'買い切り'**
  String get oneTimePurchase;

  /// No description provided for @forThoseWhoJustWantRemoveAds.
  ///
  /// In ja, this message translates to:
  /// **'サブスクなしで広告だけ消したい方へ'**
  String get forThoseWhoJustWantRemoveAds;

  /// No description provided for @restorePurchases.
  ///
  /// In ja, this message translates to:
  /// **'購入を復元'**
  String get restorePurchases;

  /// No description provided for @restoringPurchases.
  ///
  /// In ja, this message translates to:
  /// **'購入を復元中...'**
  String get restoringPurchases;

  /// No description provided for @termsOfUse.
  ///
  /// In ja, this message translates to:
  /// **'利用規約'**
  String get termsOfUse;

  /// No description provided for @premiumMember.
  ///
  /// In ja, this message translates to:
  /// **'プレミアム会員'**
  String get premiumMember;

  /// No description provided for @premiumRegister.
  ///
  /// In ja, this message translates to:
  /// **'プレミアムに登録'**
  String get premiumRegister;

  /// No description provided for @premiumActiveDesc.
  ///
  /// In ja, this message translates to:
  /// **'すべての機能が利用可能です'**
  String get premiumActiveDesc;

  /// No description provided for @premiumInactiveDesc.
  ///
  /// In ja, this message translates to:
  /// **'広告非表示・スロット無制限・詳細分析'**
  String get premiumInactiveDesc;

  /// No description provided for @perMonthPrice.
  ///
  /// In ja, this message translates to:
  /// **'月あたり¥400 — 31%お得'**
  String get perMonthPrice;

  /// No description provided for @yearlyPrice.
  ///
  /// In ja, this message translates to:
  /// **'年額 {price}'**
  String yearlyPrice(String price);

  /// No description provided for @monthlyPrice.
  ///
  /// In ja, this message translates to:
  /// **'月額 {price}'**
  String monthlyPrice(String price);

  /// No description provided for @welcomeToNamikibun.
  ///
  /// In ja, this message translates to:
  /// **'ようこそ波きぶんへ'**
  String get welcomeToNamikibun;

  /// No description provided for @onboardingDesc1.
  ///
  /// In ja, this message translates to:
  /// **'毎日の気分を波のように記録して\n自分の心の動きを見つめましょう'**
  String get onboardingDesc1;

  /// No description provided for @recordMoodIn5Levels.
  ///
  /// In ja, this message translates to:
  /// **'気分を5段階で記録'**
  String get recordMoodIn5Levels;

  /// No description provided for @reviewOnCalendar.
  ///
  /// In ja, this message translates to:
  /// **'カレンダーで振り返り'**
  String get reviewOnCalendar;

  /// No description provided for @onboardingDesc3.
  ///
  /// In ja, this message translates to:
  /// **'月間の気分の波をカレンダーで確認\n統計やグラフで傾向を分析できます'**
  String get onboardingDesc3;

  /// No description provided for @letsGetStarted.
  ///
  /// In ja, this message translates to:
  /// **'さっそく始めましょう'**
  String get letsGetStarted;

  /// No description provided for @onboardingDesc4.
  ///
  /// In ja, this message translates to:
  /// **'朝・昼・夜の3つの時間帯で\n気分を記録してみましょう'**
  String get onboardingDesc4;

  /// No description provided for @getStarted.
  ///
  /// In ja, this message translates to:
  /// **'始める'**
  String get getStarted;

  /// No description provided for @skip.
  ///
  /// In ja, this message translates to:
  /// **'スキップ'**
  String get skip;

  /// No description provided for @next.
  ///
  /// In ja, this message translates to:
  /// **'次へ'**
  String get next;

  /// No description provided for @enterPasscode.
  ///
  /// In ja, this message translates to:
  /// **'パスコードを入力'**
  String get enterPasscode;

  /// No description provided for @newPasscode.
  ///
  /// In ja, this message translates to:
  /// **'新しいパスコード'**
  String get newPasscode;

  /// No description provided for @confirmPasscode.
  ///
  /// In ja, this message translates to:
  /// **'パスコードを確認'**
  String get confirmPasscode;

  /// No description provided for @passcodesDoNotMatch.
  ///
  /// In ja, this message translates to:
  /// **'パスコードが一致しません'**
  String get passcodesDoNotMatch;

  /// No description provided for @useBiometricAuth.
  ///
  /// In ja, this message translates to:
  /// **'生体認証を使用'**
  String get useBiometricAuth;

  /// No description provided for @unlockApp.
  ///
  /// In ja, this message translates to:
  /// **'アプリのロックを解除'**
  String get unlockApp;

  /// No description provided for @incorrectPasscode.
  ///
  /// In ja, this message translates to:
  /// **'パスコードが違います'**
  String get incorrectPasscode;

  /// No description provided for @setPasscode.
  ///
  /// In ja, this message translates to:
  /// **'パスコードを設定'**
  String get setPasscode;

  /// No description provided for @reenterPasscode.
  ///
  /// In ja, this message translates to:
  /// **'もう一度入力'**
  String get reenterPasscode;

  /// No description provided for @disablePasscode.
  ///
  /// In ja, this message translates to:
  /// **'パスコードを解除'**
  String get disablePasscode;

  /// No description provided for @enterCurrentPasscode.
  ///
  /// In ja, this message translates to:
  /// **'現在のパスコードを入力してください'**
  String get enterCurrentPasscode;

  /// No description provided for @passcodeLabel.
  ///
  /// In ja, this message translates to:
  /// **'パスコード'**
  String get passcodeLabel;

  /// No description provided for @letsRecordMood.
  ///
  /// In ja, this message translates to:
  /// **'気分を記録してみましょう'**
  String get letsRecordMood;

  /// No description provided for @loading.
  ///
  /// In ja, this message translates to:
  /// **'読み込み中...'**
  String get loading;

  /// No description provided for @errorOccurred.
  ///
  /// In ja, this message translates to:
  /// **'エラーが発生しました'**
  String get errorOccurred;

  /// No description provided for @error.
  ///
  /// In ja, this message translates to:
  /// **'エラー'**
  String get error;

  /// No description provided for @errorWithMessage.
  ///
  /// In ja, this message translates to:
  /// **'エラー: {message}'**
  String errorWithMessage(String message);

  /// No description provided for @tagLoadFailed.
  ///
  /// In ja, this message translates to:
  /// **'タグの読み込みに失敗しました'**
  String get tagLoadFailed;

  /// No description provided for @memoHint.
  ///
  /// In ja, this message translates to:
  /// **'会議が長かった'**
  String get memoHint;

  /// No description provided for @debugOptions.
  ///
  /// In ja, this message translates to:
  /// **'開発者オプション'**
  String get debugOptions;

  /// No description provided for @debugDisable.
  ///
  /// In ja, this message translates to:
  /// **'デバッグモード無効化'**
  String get debugDisable;

  /// No description provided for @debugDisableDesc.
  ///
  /// In ja, this message translates to:
  /// **'リリース挙動テスト用'**
  String get debugDisableDesc;

  /// No description provided for @premiumStatus.
  ///
  /// In ja, this message translates to:
  /// **'プレミアム状態'**
  String get premiumStatus;

  /// No description provided for @premiumActive.
  ///
  /// In ja, this message translates to:
  /// **'アクティブ'**
  String get premiumActive;

  /// No description provided for @premiumInactive.
  ///
  /// In ja, this message translates to:
  /// **'非アクティブ'**
  String get premiumInactive;

  /// No description provided for @adFreeStatus.
  ///
  /// In ja, this message translates to:
  /// **'広告除去状態'**
  String get adFreeStatus;

  /// No description provided for @notPurchased.
  ///
  /// In ja, this message translates to:
  /// **'未購入'**
  String get notPurchased;

  /// No description provided for @videoUnlockStatus.
  ///
  /// In ja, this message translates to:
  /// **'動画アンロック状態'**
  String get videoUnlockStatus;

  /// No description provided for @videoUnlocked.
  ///
  /// In ja, this message translates to:
  /// **'アンロック中'**
  String get videoUnlocked;

  /// No description provided for @videoLocked.
  ///
  /// In ja, this message translates to:
  /// **'ロック中'**
  String get videoLocked;

  /// No description provided for @resetFirstLaunch.
  ///
  /// In ja, this message translates to:
  /// **'初回起動日リセット'**
  String get resetFirstLaunch;

  /// No description provided for @resetFirstLaunchDone.
  ///
  /// In ja, this message translates to:
  /// **'初回起動日をリセットしました'**
  String get resetFirstLaunchDone;

  /// No description provided for @resetVideoTimestamp.
  ///
  /// In ja, this message translates to:
  /// **'動画リセット'**
  String get resetVideoTimestamp;

  /// No description provided for @resetVideoTimestampDone.
  ///
  /// In ja, this message translates to:
  /// **'動画タイムスタンプをリセットしました'**
  String get resetVideoTimestampDone;

  /// No description provided for @resetOnboarding.
  ///
  /// In ja, this message translates to:
  /// **'オンボーディングリセット'**
  String get resetOnboarding;

  /// No description provided for @resetOnboardingDone.
  ///
  /// In ja, this message translates to:
  /// **'オンボーディングをリセットしました'**
  String get resetOnboardingDone;

  /// No description provided for @notificationTitle.
  ///
  /// In ja, this message translates to:
  /// **'波きぶん'**
  String get notificationTitle;

  /// No description provided for @notificationBody.
  ///
  /// In ja, this message translates to:
  /// **'{slotName}の気分を記録しましょう'**
  String notificationBody(String slotName);

  /// No description provided for @notificationChannelName.
  ///
  /// In ja, this message translates to:
  /// **'気分リマインダー'**
  String get notificationChannelName;

  /// No description provided for @notificationChannelDesc.
  ///
  /// In ja, this message translates to:
  /// **'気分記録のリマインダー通知'**
  String get notificationChannelDesc;

  /// No description provided for @language.
  ///
  /// In ja, this message translates to:
  /// **'言語'**
  String get language;

  /// No description provided for @languageJapanese.
  ///
  /// In ja, this message translates to:
  /// **'日本語'**
  String get languageJapanese;

  /// No description provided for @languageEnglish.
  ///
  /// In ja, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @slotFilterAll.
  ///
  /// In ja, this message translates to:
  /// **'全体'**
  String get slotFilterAll;

  /// No description provided for @moodByTimeSlot.
  ///
  /// In ja, this message translates to:
  /// **'スロット別気分表示'**
  String get moodByTimeSlot;

  /// No description provided for @slotFilterPremiumDesc.
  ///
  /// In ja, this message translates to:
  /// **'スロットを選択して時間帯ごとの気分を確認'**
  String get slotFilterPremiumDesc;

  /// No description provided for @premiumOnlyFeature.
  ///
  /// In ja, this message translates to:
  /// **'この機能はプレミアム限定です'**
  String get premiumOnlyFeature;

  /// No description provided for @displayDate.
  ///
  /// In ja, this message translates to:
  /// **'{month}月{day}日 {weekday}曜日'**
  String displayDate(int month, int day, String weekday);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
