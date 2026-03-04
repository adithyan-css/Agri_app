import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for the Firebase auth service singleton
final firebaseAuthServiceProvider = Provider<FirebaseAuthService>((ref) {
  return FirebaseAuthService();
});

/// Service layer for Firebase Authentication.
/// Wraps FirebaseAuth and GoogleSignIn for clean access from providers.
class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// The currently signed-in Firebase user, or null.
  User? get currentUser => _auth.currentUser;

  /// Stream of auth state changes (sign-in / sign-out).
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  /// Get the current user's Firebase ID token for backend API calls.
  Future<String?> getIdToken({bool forceRefresh = false}) async {
    return await _auth.currentUser?.getIdToken(forceRefresh);
  }

  /// Sign in with email and password.
  Future<UserCredential> signInWithEmail(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Register a new user with email and password.
  Future<UserCredential> registerWithEmail(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Sign in with Google.
  Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw GoogleSignInCancelledException();
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return await _auth.signInWithCredential(credential);
  }

  /// Update the display name on the Firebase user profile.
  Future<void> updateDisplayName(String name) async {
    await _auth.currentUser?.updateDisplayName(name);
    await _auth.currentUser?.reload();
  }

  /// Sign out from both Firebase and Google.
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}

/// Exception thrown when user cancels Google Sign-In.
class GoogleSignInCancelledException implements Exception {
  @override
  String toString() => 'Google sign-in was cancelled by user.';
}
