import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tick_it/services/notification_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  bool get isLoggedIn => _auth.currentUser != null;

  Future<String> getDisplayName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_display_name') ??
        currentUser?.displayName ??
        'User';
  }

  Future<UserCredential> signInWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (credential.user != null) {
        await _cacheUserInfo(credential.user!);
      }

      return credential;
    } on FirebaseAuthException {
      rethrow;
    }
  }

  Future<UserCredential> signUpWithEmail(
    String email,
    String password,
    String username,
  ) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      await credential.user?.updateDisplayName(username);

      if (credential.user != null) {
        await _firestore.collection('users').doc(credential.user!.uid).set({
          'username': username,
          'email': email.trim(),
          'createdAt': FieldValue.serverTimestamp(),
          'photoUrl': '',
          'fcmToken': NotificationService().currentToken,
        });

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_display_name', username);
      }

      return credential;
    } on FirebaseAuthException {
      rethrow;
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        final userDoc = _firestore
            .collection('users')
            .doc(userCredential.user!.uid);

        final docSnapshot = await userDoc.get();
        if (!docSnapshot.exists) {
          await userDoc.set({
            'username': userCredential.user!.displayName ?? 'User',
            'email': userCredential.user!.email ?? '',
            'createdAt': FieldValue.serverTimestamp(),
            'photoUrl': userCredential.user!.photoURL ?? '',
          });
        }

        await _cacheUserInfo(userCredential.user!);
      }

      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_display_name');
    await prefs.remove('user_photo_url');
  }

  Future<void> _cacheUserInfo(User user) async {
    final prefs = await SharedPreferences.getInstance();

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists && doc.data()?['username'] != null) {
        await prefs.setString('user_display_name', doc.data()!['username']);
      } else {
        await prefs.setString(
          'user_display_name',
          user.displayName ?? 'User',
        );
      }
    } catch (_) {
      await prefs.setString(
        'user_display_name',
        user.displayName ?? 'User',
      );
    }

    // Save current FCM token to Firestore
    final token = NotificationService().currentToken;
    if (token != null) {
      try {
        await _firestore.collection('users').doc(user.uid).update({
          'fcmToken': token,
        });
      } catch (e) {
        // Doc might not exist yet, but signUp handles it separately
      }
    }

    if (user.photoURL != null) {
      await prefs.setString('user_photo_url', user.photoURL!);
    }
  }

  static String getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      default:
        return e.message ?? 'An error occurred. Please try again.';
    }
  }
}
