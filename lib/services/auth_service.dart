import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Mevcut kullanıcıyı al
  User? get currentUser => _auth.currentUser;

  // Kimlik doğrulama durumu değişikliklerini dinle
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // E-posta ve Şifre ile Kayıt Ol
  Future<UserCredential?> signUpWithEmailPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // E-posta ve Şifre ile Giriş Yap
  Future<UserCredential?> signInWithEmailPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Google ile Giriş Yap
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      // Google Sign-In akışını başlat
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return null; // Kullanıcı iptal etti

      // Kimlik doğrulama detaylarını al
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Yeni bir kimlik oluştur
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Firebase ile giriş yap
      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Google ile giriş yapılırken beklenmedik bir hata oluştu.';
    }
  }

  // Çıkış Yap
  Future<void> signOut() async {
    try {
      await GoogleSignIn().signOut();
    } catch (e) {
      // Google çıkış hatası e-posta girişini bozmamalı
      print('Google çıkış hatası (yoksayıldı): $e');
    }
    await _auth.signOut();
  }

  // Firebase Hata Yönetimi
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'Şifre çok zayıf. Lütfen daha güçlü bir şifre seçin.';
      case 'email-already-in-use':
        return 'Bu e-posta adresi zaten kullanımda.';
      case 'invalid-email':
        return 'Geçersiz bir e-posta adresi girdiniz.';
      case 'invalid-credential':
        return 'E-posta adresiniz veya şifreniz hatalı.';
      case 'user-not-found':
        return 'Bu e-posta adresine kayıtlı bir kullanıcı bulunamadı.';
      case 'wrong-password':
        return 'Yanlış şifre girdiniz.';
      case 'user-disabled':
        return 'Bu kullanıcı hesabı askıya alınmış.';
      case 'too-many-requests':
        return 'Çok fazla deneme yaptınız. Lütfen daha sonra tekrar deneyin.';
      case 'operation-not-allowed':
        return 'Bu işlem şu anda devre dışı bırakılmış.';
      default:
        return 'Bir kimlik doğrulama hatası oluştu: ${e.message}';
    }
  }
}
