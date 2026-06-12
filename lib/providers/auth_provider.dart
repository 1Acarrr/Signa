import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  User? _user;
  bool _isLoading = false;
  bool _isGuest = false;

  AuthProvider() {
    // Auth durum değişikliklerini dinle
    _authService.authStateChanges.listen((User? user) {
      _user = user;
      _isGuest = user == null && _isGuest; // Eğer gerçek kullanıcı giriş yaparsa misafir durumunu kapat
      notifyListeners();
    });
  }

  // Getter'lar
  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  bool get isGuest => _isGuest;
  String? get email => _user?.email;
  String? get fullName => _user?.displayName;
  String? get photoURL => _user?.photoURL;

  // Profil güncellemelerini yansıtmak için
  Future<void> refreshUser() async {
    if (_user != null) {
      await _user!.reload();
      _user = FirebaseAuth.instance.currentUser;
      notifyListeners();
    }
  }

  // E-posta ve Şifre ile Giriş
  Future<void> login(String email, String password) async {
    _setLoading(true);
    try {
      await _authService.signInWithEmailPassword(email, password).timeout(const Duration(seconds: 15));
      _isGuest = false;
    } on TimeoutException {
      throw 'Bağlantı zaman aşımına uğradı. İnternet bağlantınızı kontrol edin.';
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // E-posta ve Şifre ile Kayıt
  Future<void> signup(String email, String password, String fullName) async {
    _setLoading(true);
    try {
      UserCredential? credential = await _authService.signUpWithEmailPassword(email, password).timeout(const Duration(seconds: 30));
      // Kayıt olduktan sonra kullanıcının adını güncelle
      if (credential?.user != null) {
        await credential!.user!.updateDisplayName(fullName);
        // İsmin hemen yansıması için kullanıcıyı reload yap ve state'i güncelle
        await credential.user!.reload();
        _user = _authService.currentUser;
      }
      _isGuest = false;
      notifyListeners();
    } on TimeoutException {
      throw 'Bağlantı zaman aşımına uğradı. İnternet bağlantınızı kontrol edin.';
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Google ile Giriş
  Future<void> signInWithGoogle() async {
    _setLoading(true);
    try {
      await _authService.signInWithGoogle().timeout(const Duration(seconds: 15));
      _isGuest = false;
    } on TimeoutException {
      throw 'Bağlantı zaman aşımına uğradı. İnternet bağlantınızı kontrol edin.';
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }


  // Misafir Olarak Giriş
  Future<void> loginAsGuest() async {
    _isGuest = true;
    notifyListeners();
  }

  // Çıkış Yap
  Future<void> logout() async {
    _setLoading(true);
    try {
      await _authService.signOut();
      _user = null; // Anında null yap ki GoRouter redirect'e takılmasın
      _isGuest = false;
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // İsmi Güncelle
  Future<void> updateUsername(String newName) async {
    _setLoading(true);
    try {
      if (_user != null) {
        await _user!.updateDisplayName(newName);
        await _user!.reload();
        _user = FirebaseAuth.instance.currentUser;
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Şifreyi Güncelle (Doğrudan - sadece yeni giriş yapıldıysa çalışır)
  Future<void> changePassword(String newPassword) async {
    _setLoading(true);
    try {
      if (_user != null) {
        await _user!.updatePassword(newPassword);
      }
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Güvenli Şifre Güncelleme (Önce mevcut şifre ile doğrular)
  Future<void> reauthenticateAndChangePassword(String oldPassword, String newPassword) async {
    _setLoading(true);
    try {
      if (_user != null && _user!.email != null) {
        // Eski şifre ile yeniden doğrulama
        AuthCredential credential = EmailAuthProvider.credential(
          email: _user!.email!,
          password: oldPassword,
        );
        await _user!.reauthenticateWithCredential(credential);
        
        // Başarılı olursa yeni şifreyi ayarla
        await _user!.updatePassword(newPassword);
      }
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Şifre Sıfırlama E-postası Gönder
  Future<void> sendPasswordResetEmail(String email) async {
    _setLoading(true);
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
