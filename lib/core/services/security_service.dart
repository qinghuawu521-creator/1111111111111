import 'dart:convert';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import '../constants/app_constants.dart';

class SecurityService {
  static final SecurityService _instance = SecurityService._();
  factory SecurityService() => _instance;
  SecurityService._();

  final _secureStorage = const FlutterSecureStorage();
  final _localAuth = LocalAuthentication();

  encrypt.Key? _encryptionKey;
  bool _isUnlocked = false;
  int _failedAttempts = 0;
  DateTime? _lockoutUntil;

  bool get isUnlocked => _isUnlocked;
  bool get isLockedOut => _lockoutUntil != null && DateTime.now().isBefore(_lockoutUntil!);

  // ==================== MASTER PASSWORD ====================

  Future<bool> hasMasterPassword() async {
    final hash = await _secureStorage.read(key: AppConstants.masterPasswordKey);
    return hash != null && hash.isNotEmpty;
  }

  Future<void> setMasterPassword(String password) async {
    final hash = sha256.convert(utf8.encode(password)).toString();
    await _secureStorage.write(key: AppConstants.masterPasswordKey, value: hash);
    await _deriveEncryptionKey(password);
  }

  Future<bool> verifyMasterPassword(String password) async {
    if (isLockedOut) return false;

    final storedHash = await _secureStorage.read(key: AppConstants.masterPasswordKey);
    final inputHash = sha256.convert(utf8.encode(password)).toString();

    if (storedHash == inputHash) {
      _failedAttempts = 0;
      _lockoutUntil = null;
      _isUnlocked = true;
      await _deriveEncryptionKey(password);
      return true;
    }

    _failedAttempts++;
    if (_failedAttempts >= AppConstants.maxLoginAttempts) {
      _lockoutUntil = DateTime.now().add(
        Duration(minutes: AppConstants.lockoutDurationMinutes),
      );
      _failedAttempts = 0;
    }
    return false;
  }

  Future<void> changeMasterPassword(String oldPassword, String newPassword) async {
    final verified = await verifyMasterPassword(oldPassword);
    if (!verified) throw Exception('原密码错误');
    await setMasterPassword(newPassword);
  }

  // ==================== BIOMETRIC ====================

  Future<bool> canUseBiometric() async {
    try {
      final canAuth = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return canAuth && isDeviceSupported;
    } catch (_) {
      return false;
    }
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (_) {
      return [];
    }
  }

  Future<bool> authenticateWithBiometric() async {
    try {
      return await _localAuth.authenticate(
        localizedReason: '请验证身份以解锁 Personal Vault',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }

  Future<bool> isBiometricEnabled() async {
    final value = await _secureStorage.read(key: AppConstants.biometricEnabledKey);
    return value == 'true';
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    await _secureStorage.write(
      key: AppConstants.biometricEnabledKey,
      value: enabled.toString(),
    );
  }

  // ==================== ENCRYPTION ====================

  Future<void> _deriveEncryptionKey(String password) async {
    final keyBytes = sha256.convert(utf8.encode(password)).bytes;
    _encryptionKey = encrypt.Key(Uint8List.fromList(keyBytes));
    await _secureStorage.write(
      key: AppConstants.encryptionKeyKey,
      value: base64Encode(keyBytes),
    );
  }

  Future<void> loadEncryptionKey() async {
    final storedKey = await _secureStorage.read(key: AppConstants.encryptionKeyKey);
    if (storedKey != null) {
      _encryptionKey = encrypt.Key(base64Decode(storedKey));
    }
  }

  String encryptText(String plainText) {
    if (_encryptionKey == null) throw Exception('Encryption key not initialized');
    final iv = encrypt.IV.fromSecureRandom(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(_encryptionKey!, mode: encrypt.AESMode.cbc));
    final encrypted = encrypter.encrypt(plainText, iv: iv);
    return '${iv.base64}:${encrypted.base64}';
  }

  String decryptText(String encryptedText) {
    if (_encryptionKey == null) throw Exception('Encryption key not initialized');
    final parts = encryptedText.split(':');
    if (parts.length != 2) throw Exception('Invalid encrypted text format');
    final iv = encrypt.IV.fromBase64(parts[0]);
    final encrypter = encrypt.Encrypter(encrypt.AES(_encryptionKey!, mode: encrypt.AESMode.cbc));
    return encrypter.decrypt64(parts[1], iv: iv);
  }

  // ==================== LOCK STATE ====================

  void lock() {
    _isUnlocked = false;
    _encryptionKey = null;
  }

  void unlock() {
    _isUnlocked = true;
  }

  int get remainingAttempts => AppConstants.maxLoginAttempts - _failedAttempts;

  Duration? get lockoutRemaining {
    if (_lockoutUntil == null) return null;
    final remaining = _lockoutUntil!.difference(DateTime.now());
    return remaining.isNegative ? null : remaining;
  }
}
