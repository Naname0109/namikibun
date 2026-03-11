import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';

import 'package:namikibun/models/tag.dart';
import 'package:namikibun/services/database_service.dart';

final tagProvider =
    AsyncNotifierProvider<TagNotifier, List<Tag>>(TagNotifier.new);

class TagNotifier extends AsyncNotifier<List<Tag>> {
  @override
  Future<List<Tag>> build() async {
    return await DatabaseService().getAllTags();
  }

  /// タグ名が既存タグと重複していないかチェック
  bool _isDuplicateName(String name, {String? excludeId}) {
    final tags = state.valueOrNull ?? [];
    return tags.any((t) => t.name == name && t.id != excludeId);
  }

  /// タグを追加。重複名の場合はfalseを返す。
  Future<bool> addTag(String name, String colorHex) async {
    if (_isDuplicateName(name)) return false;
    final db = DatabaseService();
    final maxIndex = await db.getMaxTagOrderIndex();
    final id = 'tag_${DateTime.now().microsecondsSinceEpoch}';
    final tag = Tag(
      id: id,
      name: name,
      colorHex: colorHex,
      orderIndex: maxIndex + 1,
    );
    try {
      await db.insertTag(tag);
    } on DatabaseException {
      return false;
    }
    ref.invalidateSelf();
    return true;
  }

  /// タグを更新。重複名の場合はfalseを返す。
  Future<bool> updateTag(String tagId, {String? name, String? colorHex}) async {
    final db = DatabaseService();
    final tags = state.valueOrNull ?? [];
    final tagIndex = tags.indexWhere((t) => t.id == tagId);
    if (tagIndex < 0) return false;
    final tag = tags[tagIndex];

    final newName = name ?? tag.name;
    if (name != null && _isDuplicateName(name, excludeId: tagId)) return false;

    final oldName = tag.name;
    final newColorHex = colorHex ?? tag.colorHex;

    try {
      await db.updateTag(tag.copyWith(name: newName, colorHex: newColorHex));
    } on DatabaseException {
      return false;
    }

    // タグ名変更時に既存レコードも更新
    if (name != null && name != oldName) {
      await db.renameTagInRecords(oldName, newName);
    }

    ref.invalidateSelf();
    return true;
  }

  Future<void> deleteTag(String tagId) async {
    await DatabaseService().deleteTag(tagId);
    ref.invalidateSelf();
  }
}

/// タグ名からColorを取得するヘルパー
Color tagColorFromHex(String hex) {
  final value = int.tryParse(hex, radix: 16);
  if (value == null) return Colors.grey;
  return Color(value);
}
