import 'dart:convert';
import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../models/entry.dart';
import '../models/password_entry.dart';
import '../database/database_helper.dart';
import '../utils/helpers.dart';

class ExportService {
  static final ExportService _instance = ExportService._();
  factory ExportService() => _instance;
  ExportService._();

  final _db = DatabaseHelper.instance;

  Future<String> exportAsMarkdown(List<Entry> entries, {String? title}) async {
    final buffer = StringBuffer();
    buffer.writeln('# ${title ?? "Personal Vault 导出"}');
    buffer.writeln();
    buffer.writeln('> 导出时间: ${DateUtils.formatDateTime(DateTime.now())}');
    buffer.writeln('> 共 ${entries.length} 条记录');
    buffer.writeln();

    for (final entry in entries) {
      buffer.writeln('## ${entry.title}');
      buffer.writeln();
      buffer.writeln('- **类型:** ${entry.typeDisplayName}');
      buffer.writeln('- **创建时间:** ${DateUtils.formatDateTime(entry.createdAt)}');
      buffer.writeln('- **更新时间:** ${DateUtils.formatDateTime(entry.updatedAt)}');
      if (entry.isStarred) buffer.writeln('- ⭐ 已收藏');
      buffer.writeln();

      if (entry.content != null && entry.content!.isNotEmpty) {
        buffer.writeln('### 内容');
        buffer.writeln();
        buffer.writeln(entry.content);
        buffer.writeln();
      }

      if (entry.url != null && entry.url!.isNotEmpty) {
        buffer.writeln('### 链接');
        buffer.writeln();
        buffer.writeln(entry.url);
        buffer.writeln();
      }

      if (entry.fileName != null) {
        buffer.writeln('### 文件');
        buffer.writeln();
        buffer.writeln('- 文件名: ${entry.fileName}');
        if (entry.fileSize != null) {
          buffer.writeln('- 大小: ${FileUtils.formatFileSize(entry.fileSize!)}');
        }
        buffer.writeln();
      }

      if (entry.customFields.isNotEmpty) {
        buffer.writeln('### 自定义字段');
        buffer.writeln();
        for (final field in entry.customFields.entries) {
          buffer.writeln('- **${field.key}:** ${field.value}');
        }
        buffer.writeln();
      }

      buffer.writeln('---');
      buffer.writeln();
    }

    final dir = await getApplicationDocumentsDirectory();
    final fileName = 'export_${DateTime.now().millisecondsSinceEpoch}.md';
    final file = File(p.join(dir.path, 'exports', fileName));
    await file.parent.create(recursive: true);
    await file.writeAsString(buffer.toString());
    return file.path;
  }

  Future<String> exportAsPdf(List<Entry> entries, {String? title}) async {
    final pdf = pw.Document();
    final font = pw.Font.helvetica();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        header: (context) => pw.Container(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            'Personal Vault - ${DateUtils.formatDate(DateTime.now())}',
            style: pw.TextStyle(font: font, color: PdfColors.grey700, fontSize: 9),
          ),
        ),
        footer: (context) => pw.Container(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            'Page ${context.pageNumber}/${context.pagesCount}',
            style: pw.TextStyle(font: font, color: PdfColors.grey700, fontSize: 9),
          ),
        ),
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text(title ?? 'Personal Vault Export', style: pw.TextStyle(font: font, fontSize: 24)),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            '共 ${entries.length} 条记录 | 导出时间: ${DateUtils.formatDateTime(DateTime.now())}',
            style: pw.TextStyle(font: font, color: PdfColors.grey600, fontSize: 10),
          ),
          pw.SizedBox(height: 20),
          ...entries.map((entry) => pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 15),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(entry.title, style: pw.TextStyle(font: font, fontSize: 16, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 4),
                pw.Text(
                  '${entry.typeDisplayName} | ${DateUtils.formatDateTime(entry.updatedAt)}',
                  style: pw.TextStyle(font: font, color: PdfColors.grey600, fontSize: 9),
                ),
                if (entry.content != null && entry.content!.isNotEmpty) ...[
                  pw.SizedBox(height: 6),
                  pw.Text(entry.content!, style: pw.TextStyle(font: font, fontSize: 11)),
                ],
                if (entry.url != null && entry.url!.isNotEmpty) ...[
                  pw.SizedBox(height: 4),
                  pw.Text('Link: ${entry.url}', style: pw.TextStyle(font: font, color: PdfColors.blue, fontSize: 10)),
                ],
                pw.SizedBox(height: 8),
                pw.Divider(color: PdfColors.grey300),
              ],
            ),
          )),
        ],
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final fileName = 'export_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File(p.join(dir.path, 'exports', fileName));
    await file.parent.create(recursive: true);
    await file.writeAsBytes(await pdf.save());
    return file.path;
  }

  Future<String> exportAsTxt(List<Entry> entries, {String? title}) async {
    final buffer = StringBuffer();
    buffer.writeln(title ?? 'Personal Vault Export');
    buffer.writeln('=' * 40);
    buffer.writeln('导出时间: ${DateUtils.formatDateTime(DateTime.now())}');
    buffer.writeln('共 ${entries.length} 条记录');
    buffer.writeln();

    for (final entry in entries) {
      buffer.writeln('-' * 30);
      buffer.writeln('标题: ${entry.title}');
      buffer.writeln('类型: ${entry.typeDisplayName}');
      buffer.writeln('创建: ${DateUtils.formatDateTime(entry.createdAt)}');
      buffer.writeln('更新: ${DateUtils.formatDateTime(entry.updatedAt)}');
      if (entry.content != null && entry.content!.isNotEmpty) {
        buffer.writeln('内容:');
        buffer.writeln(entry.content);
      }
      if (entry.url != null) buffer.writeln('链接: ${entry.url}');
      buffer.writeln();
    }

    final dir = await getApplicationDocumentsDirectory();
    final fileName = 'export_${DateTime.now().millisecondsSinceEpoch}.txt';
    final file = File(p.join(dir.path, 'exports', fileName));
    await file.parent.create(recursive: true);
    await file.writeAsString(buffer.toString());
    return file.path;
  }

  Future<String> exportAsJson(List<Entry> entries, {String? title}) async {
    final data = {
      'title': title ?? 'Personal Vault Export',
      'exported_at': DateTime.now().toIso8601String(),
      'count': entries.length,
      'entries': entries.map((e) => e.toMap()).toList(),
    };

    final jsonStr = const JsonEncoder.withIndent('  ').convert(data);
    final dir = await getApplicationDocumentsDirectory();
    final fileName = 'export_${DateTime.now().millisecondsSinceEpoch}.json';
    final file = File(p.join(dir.path, 'exports', fileName));
    await file.parent.create(recursive: true);
    await file.writeAsString(jsonStr);
    return file.path;
  }

  Future<String> exportPasswordsAsJson(List<PasswordEntry> passwords) async {
    final data = {
      'type': 'password_export',
      'exported_at': DateTime.now().toIso8601String(),
      'count': passwords.length,
      'passwords': passwords.map((p) => p.toMap()).toList(),
    };

    final jsonStr = const JsonEncoder.withIndent('  ').convert(data);
    final dir = await getApplicationDocumentsDirectory();
    final fileName = 'passwords_${DateTime.now().millisecondsSinceEpoch}.json';
    final file = File(p.join(dir.path, 'exports', fileName));
    await file.parent.create(recursive: true);
    await file.writeAsString(jsonStr);
    return file.path;
  }
}
