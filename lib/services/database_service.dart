import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import 'package:namikibun/constants/app_constants.dart';
import 'package:namikibun/models/mood_record.dart';
import 'package:namikibun/models/slot.dart';
import 'package:namikibun/utils/date_utils.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = '$dbPath/namikibun.db';

    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE mood_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        slot_id TEXT NOT NULL,
        mood_level INTEGER NOT NULL,
        memo TEXT,
        tags TEXT NOT NULL DEFAULT '[]',
        photo_path TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        UNIQUE(date, slot_id)
      )
    ''');

    await db.execute('''
      CREATE TABLE slots (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        order_index INTEGER NOT NULL,
        notify_enabled INTEGER NOT NULL DEFAULT 0,
        notify_time TEXT,
        start_time TEXT,
        end_time TEXT,
        is_deleted INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // インデックス作成
    await db.execute(
      'CREATE INDEX idx_mood_records_date ON mood_records(date)',
    );
    await db.execute(
      'CREATE INDEX idx_mood_records_slot_id ON mood_records(slot_id)',
    );

    // デフォルトスロットの挿入
    for (final slot in AppConstants.defaultSlots) {
      await db.insert('slots', {
        'id': slot['id'],
        'name': slot['name'],
        'order_index': slot['order_index'],
        'notify_enabled': 0,
        'notify_time': slot['notify_time'],
        'start_time': slot['start_time'],
        'end_time': slot['end_time'],
        'is_deleted': 0,
      });
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE mood_records ADD COLUMN photo_path TEXT');
    }
  }

  // --- MoodRecord CRUD ---

  Future<int> insertMoodRecord(MoodRecord record) async {
    final db = await database;
    return await db.insert('mood_records', _moodRecordToMap(record));
  }

  Future<List<MoodRecord>> getMoodRecordsByDate(String date) async {
    final db = await database;
    final maps = await db.query(
      'mood_records',
      where: 'date = ?',
      whereArgs: [date],
      orderBy: 'created_at ASC',
    );
    return maps.map(_moodRecordFromMap).toList();
  }

  Future<List<MoodRecord>> getMoodRecordsByDateRange(
    String startDate,
    String endDate,
  ) async {
    final db = await database;
    final maps = await db.query(
      'mood_records',
      where: 'date >= ? AND date <= ?',
      whereArgs: [startDate, endDate],
      orderBy: 'date ASC, created_at ASC',
    );
    return maps.map(_moodRecordFromMap).toList();
  }

  Future<int> updateMoodRecord(MoodRecord record) async {
    final db = await database;
    return await db.update(
      'mood_records',
      _moodRecordToMap(record),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  Future<int> deleteMoodRecord(int id) async {
    final db = await database;
    return await db.delete(
      'mood_records',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // --- Slot CRUD ---

  Future<List<Slot>> getActiveSlots() async {
    final db = await database;
    final maps = await db.query(
      'slots',
      where: 'is_deleted = 0',
      orderBy: 'order_index ASC',
    );
    return maps.map(_slotFromMap).toList();
  }

  Future<List<Slot>> getAllSlots() async {
    final db = await database;
    final maps = await db.query('slots', orderBy: 'order_index ASC');
    return maps.map(_slotFromMap).toList();
  }

  Future<Slot?> getSlotById(String id) async {
    final db = await database;
    final maps = await db.query(
      'slots',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return _slotFromMap(maps.first);
  }

  Future<void> insertSlot(Slot slot) async {
    final db = await database;
    await db.insert('slots', _slotToMap(slot));
  }

  Future<void> updateSlot(Slot slot) async {
    final db = await database;
    await db.update(
      'slots',
      _slotToMap(slot),
      where: 'id = ?',
      whereArgs: [slot.id],
    );
  }

  Future<void> softDeleteSlot(String id) async {
    final db = await database;
    await db.update(
      'slots',
      {'is_deleted': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// スロットのorder_indexを一括更新（トランザクション）
  Future<void> reorderSlots(List<Slot> slots) async {
    final db = await database;
    await db.transaction((txn) async {
      for (int i = 0; i < slots.length; i++) {
        await txn.update(
          'slots',
          {'order_index': i},
          where: 'id = ?',
          whereArgs: [slots[i].id],
        );
      }
    });
  }

  /// アクティブスロットの最大order_indexを取得
  Future<int> getMaxOrderIndex() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT MAX(order_index) as max_index FROM slots WHERE is_deleted = 0',
    );
    final maxIndex = result.first['max_index'];
    return maxIndex != null ? (maxIndex as int) : -1;
  }

  /// 今日から遡って連続記録日数を計算する
  Future<int> getConsecutiveRecordDays(String todayDate) async {
    final db = await database;
    // 直近90日分の記録がある日付を取得（十分なバッファ）
    final date = DateTime.parse(todayDate);
    final startDate = date.subtract(const Duration(days: 90));
    final startDateStr = AppDateUtils.formatDate(startDate);

    final result = await db.rawQuery(
      'SELECT DISTINCT date FROM mood_records WHERE date >= ? AND date <= ? ORDER BY date DESC',
      [startDateStr, todayDate],
    );

    if (result.isEmpty) return 0;

    final recordedDates = result.map((r) => r['date'] as String).toSet();
    int count = 0;
    var checkDate = date;

    while (true) {
      final checkStr = AppDateUtils.formatDate(checkDate);
      if (recordedDates.contains(checkStr)) {
        count++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return count;
  }

  // --- Map変換ヘルパー ---

  Map<String, dynamic> _moodRecordToMap(MoodRecord record) {
    return {
      if (record.id != null) 'id': record.id,
      'date': record.date,
      'slot_id': record.slotId,
      'mood_level': record.moodLevel,
      'memo': record.memo,
      'tags': jsonEncode(record.tags),
      'photo_path': record.photoPath,
      'created_at': record.createdAt,
      'updated_at': record.updatedAt,
    };
  }

  MoodRecord _moodRecordFromMap(Map<String, dynamic> map) {
    return MoodRecord(
      id: map['id'] as int?,
      date: map['date'] as String,
      slotId: map['slot_id'] as String,
      moodLevel: map['mood_level'] as int,
      memo: map['memo'] as String?,
      tags: (jsonDecode(map['tags'] as String) as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      photoPath: map['photo_path'] as String?,
      createdAt: map['created_at'] as String,
      updatedAt: map['updated_at'] as String,
    );
  }

  Map<String, dynamic> _slotToMap(Slot slot) {
    return {
      'id': slot.id,
      'name': slot.name,
      'order_index': slot.orderIndex,
      'notify_enabled': slot.notifyEnabled ? 1 : 0,
      'notify_time': slot.notifyTime,
      'start_time': slot.startTime,
      'end_time': slot.endTime,
      'is_deleted': slot.isDeleted ? 1 : 0,
    };
  }

  Slot _slotFromMap(Map<String, dynamic> map) {
    return Slot(
      id: map['id'] as String,
      name: map['name'] as String,
      orderIndex: map['order_index'] as int,
      notifyEnabled: (map['notify_enabled'] as int) == 1,
      notifyTime: map['notify_time'] as String?,
      startTime: map['start_time'] as String?,
      endTime: map['end_time'] as String?,
      isDeleted: (map['is_deleted'] as int) == 1,
    );
  }
}
