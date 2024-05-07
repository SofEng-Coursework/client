import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:virtual_queue/controllers/FirebaseProvider.dart';
import 'package:virtual_queue/controllers/UserAccountController.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group("UserAccountController", () {
    late UserAccountController userAccountController;
    late FirebaseProvider firebaseProvider;
    late MockUser mockUser;

    setUpAll(() {
      firebaseProvider = FirebaseProvider();
      firebaseProvider.initializeMock();
      userAccountController = UserAccountController(firebaseProvider: firebaseProvider);

      // Sign in a user for testing
      mockUser = MockUser(
        isAnonymous: false,
        uid: 'testUserID',
        email: 'test@test.com',
        displayName: 'Test User',
      );
      firebaseProvider.FIREBASE_AUTH.signInAnonymously();
    });

    setUp(() {
      firebaseProvider.FIREBASE_AUTH.signOut();
    });

    test('is initialized', () {
      expect(userAccountController, isA<UserAccountController>());
    });
  });
}
