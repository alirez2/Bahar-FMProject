import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../database/sqlite_database.dart';

class BackupService {
  final SqliteDatabase _database = SqliteDatabase();

  Future<String?> createBackup() async {
    try {
      final data = await _database.exportData();
      final jsonStr = jsonEncode(data);

      final directory = await getApplicationDocumentsDirectory();
      final backupDir = Directory('${directory.path}/backups');

      if (!await backupDir.exists()) {
        await backupDir.create(recursive: true);
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${backupDir.path}/backup_$timestamp.json');

      await file.writeAsString(jsonStr);
      return file.path;
    } catch (e) {
      return null;
    }
  }

  Future<List<FileSystemEntity>> getBackupFiles() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final backupDir = Directory('${directory.path}/backups');

      if (!await backupDir.exists()) {
        return [];
      }

      final files = backupDir
          .listSync()
          .where((f) => f.path.endsWith('.json'))
          .toList();
      files.sort(
        (a, b) => b.statSync().modified.compareTo(a.statSync().modified),
      );
      return files;
    } catch (e) {
      return [];
    }
  }

  Future<bool> restoreBackup(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return false;

      final jsonStr = await file.readAsString();
      final data = jsonDecode(jsonStr) as Map<String, dynamic>;

      await _database.importData(data);
      return true;
    } catch (e) {
      return false;
    }
  }
}
