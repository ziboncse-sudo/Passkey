import 'dart:convert';
import 'dart:math';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class EncryptionService {
  static const _storage = FlutterSecureStorage();
  static const _keyName = 'vault_encryption_key';
  static enc.Encrypter? _encrypter;
  static enc.IV? _iv;

  static Future<void> initialize() async {
    String? keyString = await _storage.read(key: _keyName);
    if (keyString == null) {
      final key = enc.Key.fromSecureRandom(32);
      keyString = base64Encode(key.bytes);
      await _storage.write(key: _keyName, value: keyString);
    }
    final keyBytes = base64Decode(keyString);
    final key = enc.Key(keyBytes);
    _iv = enc.IV.fromLength(16);
    _encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
  }

  static String encrypt(String plainText) {
    if (_encrypter == null) return plainText;
    return _encrypter!.encrypt(plainText, iv: _iv!).base64;
  }

  static String decrypt(String encrypted) {
    if (_encrypter == null) return encrypted;
    try {
      return _encrypter!.decrypt64(encrypted, iv: _iv!);
    } catch (_) {
      return encrypted;
    }
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

    final rng = Random.secure();
    return List.generate(length, (_) => chars[rng.nextInt(chars.length)]).join();
  }

  static int calculateStrength(String password) {
    int score = 0;
    if (password.length >= 8) score++;
    if (password.length >= 12) score++;
    if (password.length >= 16) score++;
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;
    if (RegExp(r'[a-z]').hasMatch(password)) score++;
    if (RegExp(r'[0-9]').hasMatch(password)) score++;
    if (RegExp(r'[!@#\$%^&*()_+\-=\[\]{}|;:,.<>?]').hasMatch(password)) score++;
    return score.clamp(0, 5);
  }

  static String strengthLabel(int strength) {
    switch (strength) {
      case 0:
      case 1: return 'খুব দুর্বল';
      case 2: return 'দুর্বল';
      case 3: return 'মাঝারি';
      case 4: return 'শক্তিশালী';
      default: return 'খুব শক্তিশালী';
    }
  }
}
