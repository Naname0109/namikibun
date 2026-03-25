// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => '波きぶん';

  @override
  String get appSubtitle => '気分の浮き沈みを可視化';

  @override
  String get home => 'ホーム';

  @override
  String get stats => '統計';

  @override
  String get settings => '設定';

  @override
  String get todayRecordPrompt => '今日の気分を記録しましょう';

  @override
  String get todayAverageMood => '今日の平均気分';

  @override
  String recordCount(int count) {
    return '$count件の記録';
  }

  @override
  String get streak => '連続記録';

  @override
  String streakDays(int days) {
    return '連続$days日記録中';
  }

  @override
  String get days => '日';

  @override
  String monthYear(int year, int month) {
    return '$year年$month月';
  }

  @override
  String get weekdayMon => '月';

  @override
  String get weekdayTue => '火';

  @override
  String get weekdayWed => '水';

  @override
  String get weekdayThu => '木';

  @override
  String get weekdayFri => '金';

  @override
  String get weekdaySat => '土';

  @override
  String get weekdaySun => '日';

  @override
  String get morning => '朝';

  @override
  String get afternoon => '昼';

  @override
  String get evening => '夜';

  @override
  String get tapToRecord => 'タップして記録';

  @override
  String get addRecord => '記録を追加';

  @override
  String get moodGood => '良い';

  @override
  String get moodBad => '悪い';

  @override
  String get tryAddingAnother => 'もう1つ記録してみましょう';

  @override
  String get tapToRecordToday => 'タップして今日の気分を記録しましょう';

  @override
  String slotMood(String slotName) {
    return '$slotNameの気分';
  }

  @override
  String get chooseMood => '今の気分を選んでください';

  @override
  String get moodVeryBad => 'とても悪い';

  @override
  String get moodBadLabel => '悪い';

  @override
  String get moodNormal => '普通';

  @override
  String get moodGoodLabel => '良い';

  @override
  String get moodVeryGood => 'とても良い';

  @override
  String get quickNote => 'ひとことメモ';

  @override
  String get tags => 'タグ';

  @override
  String get photo => '写真';

  @override
  String get addPhoto => '写真を追加';

  @override
  String get addPhotoPremium => '写真を追加（プレミアム）';

  @override
  String get save => '保存';

  @override
  String get update => '更新';

  @override
  String get tagWork => '仕事';

  @override
  String get tagExercise => '運動';

  @override
  String get tagMeals => '食事';

  @override
  String get tagSocial => '人間関係';

  @override
  String get tagWeather => '天気';

  @override
  String get tagOther => 'その他';

  @override
  String get weeklySummary => '今週のサマリー';

  @override
  String get thisWeekAverage => '今週の平均';

  @override
  String get vsLastWeek => '先週比';

  @override
  String get averageMoodByTime => '時間帯別の平均気分';

  @override
  String get monthlyMoodTrend => '月全体の気分推移';

  @override
  String get averageMoodByTag => 'タグ別平均気分';

  @override
  String get tagCorrelationInsights => 'タグ相関インサイト';

  @override
  String get thisMonthHighlights => '今月のハイライト';

  @override
  String get bestDay => '最高の日';

  @override
  String get worstDay => '最低の日';

  @override
  String get dayOfWeekPattern => '曜日別パターン';

  @override
  String get monthlyComparison => '月別比較';

  @override
  String get lastMonth => '先月';

  @override
  String get thisMonth => '今月';

  @override
  String get noData => 'データなし';

  @override
  String tagDaysMoodHigher(String tag, String sign, String value) {
    return '「$tag」タグの日は平均気分が$sign$value';
  }

  @override
  String get watchVideoToUnlock => '動画を見て24h解放';

  @override
  String get unlockWithPremium => 'プレミアムで常時解放';

  @override
  String get unlockWithPremiumShort => 'プレミアムで解放';

  @override
  String get unlocked => '解放中';

  @override
  String get remaining => '残り';

  @override
  String get hours => '時間';

  @override
  String get detailedAnalytics => '詳細分析';

  @override
  String get detailedAnalyticsDesc => '月別比較・タグ相関・曜日別パターン';

  @override
  String get statsMinDays => '3日以上記録すると\n統計が表示されます';

  @override
  String dayLabel(int day) {
    return '$day日';
  }

  @override
  String average(String value) {
    return '平均 $value';
  }

  @override
  String improvedFromLastMonth(String value) {
    return '先月より +$value 改善';
  }

  @override
  String declinedFromLastMonth(String value) {
    return '先月より $value 低下';
  }

  @override
  String get slotManagement => 'スロット管理';

  @override
  String get tagManagement => 'タグ管理';

  @override
  String get notifications => '通知設定';

  @override
  String get theme => 'テーマ';

  @override
  String get themeLight => 'ライト';

  @override
  String get themeDark => 'ダーク';

  @override
  String get themeSystem => 'システム';

  @override
  String get security => 'セキュリティ';

  @override
  String get passcodeLock => 'パスコードロック';

  @override
  String get passcodeLockDesc => 'アプリ起動時にロックを要求';

  @override
  String get store => 'ストア';

  @override
  String get openStore => 'ストアを開く';

  @override
  String get purchased => '購入済み';

  @override
  String get version => 'バージョン';

  @override
  String get privacyPolicy => 'プライバシーポリシー';

  @override
  String get privacyPolicyDesc => 'データはすべて端末内に保存されます';

  @override
  String get renameSlot => 'スロット名を変更';

  @override
  String get addSlot => 'スロットを追加';

  @override
  String get slotName => 'スロット名';

  @override
  String get cancel => 'キャンセル';

  @override
  String get delete => '削除';

  @override
  String get deleteSlotConfirm => 'このスロットを削除しますか？';

  @override
  String deleteSlotConfirmDetail(String name) {
    return '「$name」を削除しますか？\n過去の記録はそのまま残ります。';
  }

  @override
  String get addTag => 'タグを追加';

  @override
  String get editTag => 'タグを編集';

  @override
  String get tagName => 'タグ名';

  @override
  String get chooseColor => '色を選択';

  @override
  String get deleteTag => 'タグを削除';

  @override
  String deleteTagConfirmDetail(String name) {
    return '「$name」を削除しますか？\n過去の記録からは削除されません。';
  }

  @override
  String get deleteRecord => '記録を削除';

  @override
  String get deleteRecordConfirm => 'この記録を削除しますか？';

  @override
  String get edit => '編集';

  @override
  String get slotHintExample => '例: 仕事後';

  @override
  String get tagHintExample => '例: 読書';

  @override
  String get add => '追加';

  @override
  String get tagAlreadyExists => '同じ名前のタグが既に存在します';

  @override
  String notificationTime(String time) {
    return '通知 $time';
  }

  @override
  String get recorded => '記録済み';

  @override
  String get selectSlot => 'スロットを選択';

  @override
  String get deleteSlot => 'スロットを削除';

  @override
  String get other => 'その他';

  @override
  String get namikibunStore => '波きぶん ストア';

  @override
  String get namikibunPremium => '波きぶんプレミアム';

  @override
  String get freeTrialDays => '7日間無料体験　終了後自動課金';

  @override
  String get autoChargeWarning => '無料体験終了後、自動的に課金されます';

  @override
  String yearlyTrialDesc(String price, String perMonth) {
    return '7日間無料　→　年額$price（月あたり$perMonth）';
  }

  @override
  String monthlyTrialDesc(String price) {
    return '7日間無料　→　月額$price';
  }

  @override
  String get cancelAnytimeNotice =>
      'サブスクリプションはいつでもキャンセルできます。無料体験期間中にキャンセルすれば課金されません。';

  @override
  String get monthly => '月額';

  @override
  String get yearly => '年額';

  @override
  String get perMonth => '月あたり';

  @override
  String get savePercent => 'お得';

  @override
  String get noAds => '広告完全非表示';

  @override
  String get unlimitedSlots => 'スロット無制限';

  @override
  String get photoAttachment => '写真添付';

  @override
  String get removeAdsOnly => '広告除去のみ';

  @override
  String get oneTimePurchase => '買い切り';

  @override
  String get forThoseWhoJustWantRemoveAds => 'サブスクなしで広告だけ消したい方へ';

  @override
  String get restorePurchases => '購入を復元';

  @override
  String get restoringPurchases => '購入を復元中...';

  @override
  String get termsOfUse => '利用規約';

  @override
  String get premiumMember => 'プレミアム会員';

  @override
  String get premiumRegister => 'プレミアムに登録';

  @override
  String get premiumActiveDesc => 'すべての機能が利用可能です';

  @override
  String get premiumInactiveDesc => '広告非表示・スロット無制限・詳細分析';

  @override
  String get perMonthPrice => '月あたり¥400 — 31%お得';

  @override
  String yearlyPrice(String price) {
    return '年額 $price';
  }

  @override
  String monthlyPrice(String price) {
    return '月額 $price';
  }

  @override
  String get welcomeToNamikibun => 'ようこそ波きぶんへ';

  @override
  String get onboardingDesc1 => '毎日の気分を波のように記録して\n自分の心の動きを見つめましょう';

  @override
  String get recordMoodIn5Levels => '気分を5段階で記録';

  @override
  String get reviewOnCalendar => 'カレンダーで振り返り';

  @override
  String get onboardingDesc3 => '月間の気分の波をカレンダーで確認\n統計やグラフで傾向を分析できます';

  @override
  String get letsGetStarted => 'さっそく始めましょう';

  @override
  String get onboardingDesc4 => '朝・昼・夜の3つの時間帯で\n気分を記録してみましょう';

  @override
  String get getStarted => '始める';

  @override
  String get skip => 'スキップ';

  @override
  String get next => '次へ';

  @override
  String get enterPasscode => 'パスコードを入力';

  @override
  String get newPasscode => '新しいパスコード';

  @override
  String get confirmPasscode => 'パスコードを確認';

  @override
  String get passcodesDoNotMatch => 'パスコードが一致しません';

  @override
  String get useBiometricAuth => '生体認証を使用';

  @override
  String get unlockApp => 'アプリのロックを解除';

  @override
  String get incorrectPasscode => 'パスコードが違います';

  @override
  String get setPasscode => 'パスコードを設定';

  @override
  String get reenterPasscode => 'もう一度入力';

  @override
  String get disablePasscode => 'パスコードを解除';

  @override
  String get enterCurrentPasscode => '現在のパスコードを入力してください';

  @override
  String get passcodeLabel => 'パスコード';

  @override
  String get letsRecordMood => '気分を記録してみましょう';

  @override
  String get loading => '読み込み中...';

  @override
  String get errorOccurred => 'エラーが発生しました';

  @override
  String get error => 'エラー';

  @override
  String errorWithMessage(String message) {
    return 'エラー: $message';
  }

  @override
  String get tagLoadFailed => 'タグの読み込みに失敗しました';

  @override
  String get memoHint => '会議が長かった';

  @override
  String get debugOptions => '開発者オプション';

  @override
  String get debugDisable => 'デバッグモード無効化';

  @override
  String get debugDisableDesc => 'リリース挙動テスト用';

  @override
  String get premiumStatus => 'プレミアム状態';

  @override
  String get premiumActive => 'アクティブ';

  @override
  String get premiumInactive => '非アクティブ';

  @override
  String get adFreeStatus => '広告除去状態';

  @override
  String get notPurchased => '未購入';

  @override
  String get videoUnlockStatus => '動画アンロック状態';

  @override
  String get videoUnlocked => 'アンロック中';

  @override
  String get videoLocked => 'ロック中';

  @override
  String get resetFirstLaunch => '初回起動日リセット';

  @override
  String get resetFirstLaunchDone => '初回起動日をリセットしました';

  @override
  String get resetVideoTimestamp => '動画リセット';

  @override
  String get resetVideoTimestampDone => '動画タイムスタンプをリセットしました';

  @override
  String get resetOnboarding => 'オンボーディングリセット';

  @override
  String get resetOnboardingDone => 'オンボーディングをリセットしました';

  @override
  String get notificationTitle => '波きぶん';

  @override
  String notificationBody(String slotName) {
    return '$slotNameの気分を記録しましょう';
  }

  @override
  String get notificationChannelName => '気分リマインダー';

  @override
  String get notificationChannelDesc => '気分記録のリマインダー通知';

  @override
  String get language => '言語';

  @override
  String get languageJapanese => '日本語';

  @override
  String get languageEnglish => 'English';

  @override
  String get slotFilterAll => '全体';

  @override
  String get moodByTimeSlot => 'スロット別気分表示';

  @override
  String get slotFilterPremiumDesc => 'スロットを選択して時間帯ごとの気分を確認';

  @override
  String get premiumOnlyFeature => 'この機能はプレミアム限定です';

  @override
  String displayDate(int month, int day, String weekday) {
    return '$month月$day日 $weekday曜日';
  }
}
