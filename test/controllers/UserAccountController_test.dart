import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:virtual_queue/controllers/FirebaseProvider.dart';
import 'package:virtual_queue/controllers/UserAccountController.dart';
import 'package:virtual_queue/pages/RegisterForm.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group("UserAccountController", () {
    late UserAccountController userAccountController;
    late FirebaseProvider firebaseProvider;

    setUpAll(() {
      firebaseProvider = FirebaseProvider();
      firebaseProvider.initializeMock();
      userAccountController = UserAccountController(firebaseProvider: firebaseProvider);
    });

    setUp(() {
      firebaseProvider.FIREBASE_AUTH.signOut();
    });

    test('is initialized', () {
      expect(userAccountController, isA<UserAccountController>());
    });

    test('can sign up and be authenticated', () async {
      final result = await userAccountController.signUp("test@test.com", "password", "name", "phone");
      expect(result, isNull);

      final user = firebaseProvider.FIREBASE_AUTH.currentUser;
      expect(user, isA<MockUser>());
      expect(user!.email, "test@test.com");
    });

    test('can sign in and be authenticated', () async {
      final result = await userAccountController.login("test@test.com", "password");
      expect(result, isNull);

      final user = firebaseProvider.FIREBASE_AUTH.currentUser;
      expect(user, isA<MockUser>());
      expect(user!.email, "test@test.com");
    });

    test('can sign out', () async {
      await userAccountController.signOut();
      final user = firebaseProvider.FIREBASE_AUTH.currentUser;
      expect(user, isNull);
    });

    test('can get user data', () async {
      final result = await userAccountController.login("test@test.com", "password");
      expect(result, isNull);

      final userData = await userAccountController.getUserData();
      expect(userData, isA<Map<String, dynamic>>());
      expect(userData!['email'], "test@test.com");
      expect(userData['accountType'], AccountType.User);
    });

    test("can't login with invalid account", () async {
      final result = await userAccountController.login("lol@lol.com", "password");
      expect(result, isNotNull);
    });
  });
}