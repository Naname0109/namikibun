import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'package:namikibun/models/slot.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  static const _permissionRequestedKey = 'notification_permission_requested';

  /// 通知プラグインの初期化
  Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();
    // デバイスのタイムゾーンオフセットからローカルタイムゾーンを設定
    final now = DateTime.now();
    final offset = now.timeZoneOffset;
    final locations = tz.timeZoneDatabase.locations.values.where((loc) {
      final tzNow = tz.TZDateTime.now(loc);
      return tzNow.timeZoneOffset == offset;
    });
    if (locations.isNotEmpty) {
      tz.setLocalLocation(locations.first);
    }

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(settings);
    _initialized = true;
  }

  /// 通知許可をリクエスト（初回のみ）
  Future<bool> requestPermissionIfNeeded() async {
    await initialize();

    final prefs = await SharedPreferences.getInstance();
    final alreadyRequested = prefs.getBool(_permissionRequestedKey) ?? false;

    // 既にリクエスト済みの場合は再リクエストしない
    // （ユーザーが拒否した場合、OSの設定画面で変更してもらう）
    if (alreadyRequested) return true;

    await prefs.setBool(_permissionRequestedKey, true);

    // iOS
    final iosImpl = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (iosImpl != null) {
      final granted = await iosImpl.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    // Android 13+
    final androidImpl = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidImpl != null) {
      final granted = await androidImpl.requestNotificationsPermission();
      return granted ?? false;
    }

    return true;
  }

  /// スロットIDから決定的な通知IDを生成
  int _notificationIdForSlot(String slotId) {
    int hash = 0;
    for (int i = 0; i < slotId.length; i++) {
      hash = (hash * 31 + slotId.codeUnitAt(i)) & 0x7FFFFFFF;
    }
    return hash;
  }

  /// スロットのリマインダーをスケジュール
  Future<void> scheduleSlotReminder(Slot slot) async {
    final notifyTime = slot.notifyTime;
    if (!slot.notifyEnabled || notifyTime == null) return;

    await initialize();

    final parts = notifyTime.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    final notificationId = _notificationIdForSlot(slot.id);

    await _plugin.zonedSchedule(
      notificationId,
      '波きぶん',
      '${slot.name}の気分を記録しましょう',
      _nextInstanceOfTime(hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'mood_reminder',
          '気分リマインダー',
          channelDescription: '気分記録のリマインダー通知',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// スロットのリマインダーをキャンセル
  Future<void> cancelSlotReminder(String slotId) async {
    await initialize();
    final notificationId = _notificationIdForSlot(slotId);
    await _plugin.cancel(notificationId);
  }

  /// 全通知をキャンセル
  Future<void> cancelAllReminders() async {
    await initialize();
    await _plugin.cancelAll();
  }

  /// 次の指定時刻のTZDateTimeを取得
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
