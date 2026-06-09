import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../constants/app_constants.dart';
import '../database/database_helper.dart';

class BackupService {
  static final BackupService _instance = BackupService._();
  factory BackupService() => _instance;
  BackupService._();

  final _db = DatabaseHelper.instance;

  Future<String> createBackup() async {
    final appDir = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').replaceAll('.', '-');
    final backupFileName = '${AppConstants.backupPrefix}$timestamp${AppConstants.backupExtension}';
    final backupPath = p.join(appDir.parent.path, 'backups', backupFileName);

    // Ensure backup directory exists
    final backupDir = Directory(p.dirname(backupPath));
    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }

    // Export all data as JSON
    final data = await _db.exportAllData();
    final jsonStr = const JsonEncoder.withIndent('  ').convert(data);

    // Create archive
    final archive = Archive();

    // Add JSON data
    final jsonBytes = utf8.encode(jsonStr);
    archive.addFile(ArchiveFile('data.json', jsonBytes.length, jsonBytes));

    // Copy all files from app documents
    await _addFilesToArchive(archive, appDir.path, 'files/');

    // Encode and write ZIP
    final zipBytes = ZipEncoder().encode(archive);
    final file = File(backupPath);
    await file.writeAsBytes(zipBytes);

    return backupPath;
  }

  Future<void> _addFilesToArchive(Archive archive, String dirPath, String prefix) async {
    final dir = Directory(dirPath);
    if (!await dir.exists()) return;

    await for (final entity in dir.list(recursive: true)) {
      if (entity is File) {
        final relativePath = p.relative(entity.path, from: dirPath);
        final bytes = await entity.readAsBytes();
        archive.addFile(ArchiveFile('$prefix$relativePath', bytes.length, bytes));
      }
    }
  }

  Future<void> restoreBackup(String backupPath) async {
    final file = File(backupPath);
    final bytes = await file.readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);

    // Find and parse data.json
    ArchiveFile? dataFile;
    for (final f in archive) {
      if (f.isFile && f.name == 'data.json') {
        dataFile = f;
        break;
      }
    }

    if (dataFile == null) throw Exception('Invalid backup: data.json not found');

    final jsonStr = utf8.decode(dataFile.content as List<int>);
    final data = jsonDecode(jsonStr) as Map<String, dynamic>;

    // Import data into database
    await _db.importAllData(data);

    // Restore files
    final appDir = await getApplicationDocumentsDirectory();
    for (final f in archive) {
      if (f.isFile && f.name.startsWith('files/')) {
        final filePath = p.join(appDir.path, f.name.substring(6));
        final dir = Directory(p.dirname(filePath));
        if (!await dir.exists()) {
          await dir.create(recursive: true);
        }
        await File(filePath).writeAsBytes(f.content as List<int>);
      }
    }
  }

  Future<List<FileSystemEntity>> listBackups() async {
    final appDir = await getApplicationDocumentsDirectory();
    final backupDir = Directory(p.join(appDir.parent.path, 'backups'));
    if (!await backupDir.exists()) return [];

    final files = await backupDir.list().toList();
    files.sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));
    return files;
  }

  Future<void> deleteBackup(String backupPath) async {
    final file = File(backupPath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<int> getBackupSize(String backupPath) async {
    final file = File(backupPath);
    if (!await file.exists()) return 0;
    return (await file.stat()).size;
  }
}
