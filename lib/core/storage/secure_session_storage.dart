import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../features/auth/domain/entities/auth_session.dart';

/// Wraps flutter_secure_storage so the auth data layer never imports the
/// storage package directly — same reasoning as BookLocalDataSource
/// sitting behind an interface: if this needs to become platform
/// keychain + biometric gating later, this file is the only one that changes.
class SecureSessionStorage {
  const SecureSessionStorage(this._storage);
  final FlutterSecureStorage _storage;

  static const _kToken = 'auth_access_token';
  static const _kExpiresIn = 'auth_expires_in_minutes';
  static const _kUserId = 'auth_user_id';
  static const _kRole = 'auth_role';
  static const _kFullName = 'auth_full_name';
  static const _kEmail = 'auth_email';

  Future<void> save(AuthSession session) async {
    await Future.wait([
      _storage.write(key: _kToken, value: session.accessToken),
      _storage.write(key: _kExpiresIn, value: session.expiresInMinutes.toString()),
      _storage.write(key: _kUserId, value: session.userId),
      _storage.write(key: _kRole, value: session.role.name),
      _storage.write(key: _kFullName, value: session.fullName),
      _storage.write(key: _kEmail, value: session.email),
    ]);
  }

  Future<AuthSession?> read() async {
    final token = await _storage.read(key: _kToken);
    if (token == null) return null; // no persisted session — normal, not an error

    final expiresIn = await _storage.read(key: _kExpiresIn);
    final userId = await _storage.read(key: _kUserId);
    final roleStr = await _storage.read(key: _kRole);
    final fullName = await _storage.read(key: _kFullName);
    final email = await _storage.read(key: _kEmail);

    if (expiresIn == null || userId == null || roleStr == null || fullName == null || email == null) {
      await clear(); // partially-written/corrupted — treat as no session, don't crash
      return null;
    }

    return AuthSession(
      accessToken: token,
      expiresInMinutes: int.parse(expiresIn),
      userId: userId,
      role: UserRole.values.byName(roleStr),
      fullName: fullName,
      email: email,
    );
  }

  Future<void> clear() async {
    await Future.wait([
      _storage.delete(key: _kToken),
      _storage.delete(key: _kExpiresIn),
      _storage.delete(key: _kUserId),
      _storage.delete(key: _kRole),
      _storage.delete(key: _kFullName),
      _storage.delete(key: _kEmail),
    ]);
  }
}