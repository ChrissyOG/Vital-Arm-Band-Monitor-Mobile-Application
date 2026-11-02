import 'dart:async';
import 'package:flutter/foundation.dart';

import 'user_profile.dart';

class RegisteredAccount {
  const RegisteredAccount({
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    required this.monitoredName,
    required this.createdAt,
  });

  final String name;
  final String email;
  final String password;
  final UserRole role;
  final String monitoredName;
  final DateTime createdAt;

  UserProfile toProfile() => UserProfile(
        name: name,
        email: email,
        role: role,
        monitoredName: monitoredName,
      );
}

class AuthService extends ChangeNotifier {
  AuthService._() {
    _seedDefaultAccounts();
  }

  static final AuthService instance = AuthService._();

  final Map<String, RegisteredAccount> _accounts = {};
  UserProfile? _currentUser;
  bool _isLoading = false;

  UserProfile? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;

  void _seedDefaultAccounts() {
    // Default account for Theophany Bandure
    final theo = RegisteredAccount(
      name: 'Theophany Bandure',
      email: 'theophany@vitalband.com',
      password: 'password123',
      role: UserRole.caregiver,
      monitoredName: 'Miriam Bandure',
      createdAt: DateTime.now().subtract(const Duration(days: 14)),
    );
    _accounts[theo.email.toLowerCase()] = theo;
    _accounts['theophany@utano.app'] = RegisteredAccount(
      name: 'Theophany Bandure',
      email: 'theophany@utano.app',
      password: 'password123',
      role: UserRole.caregiver,
      monitoredName: 'Miriam Bandure',
      createdAt: DateTime.now().subtract(const Duration(days: 14)),
    );

    // Demo account for quick presentation
    final demo = RegisteredAccount(
      name: 'Alex Morgan',
      email: 'demo@vitalband.com',
      password: 'password123',
      role: UserRole.caregiver,
      monitoredName: 'Miriam Bandure',
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
    );
    _accounts[demo.email.toLowerCase()] = demo;
    _accounts['demo@utano.app'] = RegisteredAccount(
      name: 'Alex Morgan',
      email: 'demo@utano.app',
      password: 'password123',
      role: UserRole.caregiver,
      monitoredName: 'Miriam Bandure',
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
    );
  }

  /// Registers a brand new account in the system database.
  Future<UserProfile> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
    required String monitoredName,
  }) async {
    _isLoading = true;
    notifyListeners();

    // Simulate network authentication roundtrip
    await Future<void>.delayed(const Duration(milliseconds: 600));

    final normalizedEmail = email.trim().toLowerCase();
    final account = RegisteredAccount(
      name: name.trim(),
      email: normalizedEmail,
      password: password,
      role: role,
      monitoredName: role.monitorsSomeone
          ? (monitoredName.trim().isEmpty ? 'Monitored Person' : monitoredName.trim())
          : name.trim(),
      createdAt: DateTime.now(),
    );

    _accounts[normalizedEmail] = account;
    _currentUser = account.toProfile();

    _isLoading = false;
    notifyListeners();
    return _currentUser!;
  }

  /// Signs in an existing registered account, or creates demo session.
  Future<UserProfile> signIn({
    required String email,
    required String password,
    required UserRole selectedRole,
  }) async {
    _isLoading = true;
    notifyListeners();

    await Future<void>.delayed(const Duration(milliseconds: 500));

    final normalizedEmail = email.trim().toLowerCase();

    if (_accounts.containsKey(normalizedEmail)) {
      final account = _accounts[normalizedEmail]!;
      if (account.password != password) {
        _isLoading = false;
        notifyListeners();
        throw Exception('Incorrect password for $email');
      }
      _currentUser = account.toProfile();
    } else {
      // If user inputs a new email directly on sign-in, create a demo profile dynamically
      final nameFromEmail = normalizedEmail.split('@').first;
      final formattedName = nameFromEmail.isNotEmpty
          ? '${nameFromEmail[0].toUpperCase()}${nameFromEmail.substring(1)}'
          : 'User';

      final newAccount = RegisteredAccount(
        name: formattedName,
        email: normalizedEmail,
        password: password,
        role: selectedRole,
        monitoredName: 'Miriam Bandure',
        createdAt: DateTime.now(),
      );
      _accounts[normalizedEmail] = newAccount;
      _currentUser = newAccount.toProfile();
    }

    _isLoading = false;
    notifyListeners();
    return _currentUser!;
  }

  void signOut() {
    _currentUser = null;
    notifyListeners();
  }
}
