import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

class DateUtils {
  static String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  static String formatDateTime(DateTime date) {
    return DateFormat('yyyy-MM-dd HH:mm').format(date);
  }

  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inSeconds < 60) return '刚刚';
    if (diff.inMinutes < 60) return '${diff.inMinutes}分钟前';
    if (diff.inHours < 24) return '${diff.inHours}小时前';
    if (diff.inDays < 7) return '${diff.inDays}天前';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}周前';
    if (diff.inDays < 365) return '${(diff.inDays / 30).floor()}个月前';
    return '${(diff.inDays / 365).floor()}年前';
  }

  static String formatDateChinese(DateTime date) {
    return DateFormat('yyyy年MM月dd日').format(date);
  }

  static String formatTimeChinese(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }
}

class FileUtils {
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  static String getFileExtension(String fileName) {
    final parts = fileName.split('.');
    return parts.length > 1 ? parts.last.toLowerCase() : '';
  }

  static String getFileType(String extension) {
    if (AppConstants.imageExtensions.contains(extension)) return 'image';
    if (AppConstants.documentExtensions.contains(extension)) return 'document';
    if (AppConstants.archiveExtensions.contains(extension)) return 'archive';
    return 'other';
  }

  static String getMimeType(String extension) {
    final mimeMap = {
      'jpg': 'image/jpeg',
      'jpeg': 'image/jpeg',
      'png': 'image/png',
      'webp': 'image/webp',
      'gif': 'image/gif',
      'pdf': 'application/pdf',
      'doc': 'application/msword',
      'docx': 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'xls': 'application/vnd.ms-excel',
      'xlsx': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      'txt': 'text/plain',
      'csv': 'text/csv',
      'zip': 'application/zip',
    };
    return mimeMap[extension] ?? 'application/octet-stream';
  }
}

class StringUtils {
  static String truncate(String text, int maxLength, {String suffix = '...'}) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength - suffix.length)}$suffix';
  }

  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  static String generatePassword({
    int length = 16,
    bool uppercase = true,
    bool lowercase = true,
    bool numbers = true,
    bool symbols = true,
  }) {
    const upper = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const lower = 'abcdefghijklmnopqrstuvwxyz';
    const nums = '0123456789';
    const syms = '!@#\$%^&*()_+-=[]{}|;:,.<>?';

    String chars = '';
    if (uppercase) chars += upper;
    if (lowercase) chars += lower;
    if (numbers) chars += nums;
    if (symbols) chars += syms;

    if (chars.isEmpty) chars = lower + nums;

    final random = List.generate(length, (i) {
      return chars[(DateTime.now().microsecondsSinceEpoch + i * 7) % chars.length];
    });
    return random.join();
  }

  static Map<String, dynamic> parseCustomFields(String content) {
    final fields = <String, dynamic>{};
    final lines = content.split('\n');
    for (final line in lines) {
      final colonIndex = line.indexOf(':');
      if (colonIndex > 0) {
        final key = line.substring(0, colonIndex).trim();
        final value = line.substring(colonIndex + 1).trim();
        if (key.isNotEmpty) {
          fields[key] = value;
        }
      }
    }
    return fields;
  }

  static String buildCustomFieldsContent(Map<String, dynamic> fields) {
    return fields.entries.map((e) => '${e.key}: ${e.value}').join('\n');
  }
}

class ValidationUtils {
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  static bool isValidUrl(String url) {
    return RegExp(r'^https?://').hasMatch(url);
  }

  static bool isValidPhone(String phone) {
    return RegExp(r'^\+?[\d\s-]{7,15}$').hasMatch(phone);
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName不能为空';
    }
    return null;
  }
}
