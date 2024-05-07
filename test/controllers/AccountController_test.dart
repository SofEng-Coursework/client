import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:virtual_queue/controllers/FirebaseProvider.dart';
import 'package:virtual_queue/controllers/AccountController.dart';
import 'package:virtual_queue/pages/RegisterForm.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group("AccountController", () {
    late AccountController accountController;
    late FirebaseProvider firebaseProvider;

    setUpAll(() {
      firebaseProvider = FirebaseProvider();
      firebaseProvider.initializeMock();
      accountController = AccountController(collectionName: 'users', firebaseProvider: firebaseProvider);
    });

    setUp(() {
      firebaseProvider.FIREBASE_AUTH.signOut();
    });

    test('is initialized', () {
      expect(accountController, isA<AccountController>());
    });

    test('can sign up and be authenticated', () async {
      final result = await accountController.signUp("test", "password", "name", "07123456789");
      expect(result.success, false);
      final result2 = await accountController.signUp("test@test.com", "pass", "name", "07123456789");
      expect(result2.success, false);
      final result3 = await accountController.signUp("test@test.com", "password", "name", "071234");
      expect(result3.success, false);
      final result1 = await accountController.signUp("test@test.com", "password", "name", "07123456789");
      expect(result1.success, true);
      final user = firebaseProvider.FIREBASE_AUTH.currentUser;
      expect(user, isA<MockUser>());
      expect(user!.email, "test@test.com");
    });

    test('can sign in and be authenticated', () async {
      final result1 = await accountController.login("test@test.com", "password");
      final user1 = firebaseProvider.FIREBASE_AUTH.currentUser;
      expect(user1, isA<MockUser>());
      expect(user1!.email, "test@test.com");
    });

    test('user exists in database after sign up', () async {
      final result = await accountController.login("test@test.com", "password");
      expect(result.success, true);

      final user = firebaseProvider.FIREBASE_AUTH.currentUser;
      expect(user, isA<MockUser>());
      
      final databaseUser = await firebaseProvider.FIREBASE_FIRESTORE.collection("users").doc(user!.uid).get();
      expect(databaseUser.data(), isA<Map<String, dynamic>>());
      expect(databaseUser.data()!['email'], "test@test.com");
    });

    test('can sign out', () async {
      await accountController.signOut();
      final user = firebaseProvider.FIREBASE_AUTH.currentUser;
      expect(user, isNull);
    });

    test('can get user data', () async {
      final result = await accountController.login("test@test.com", "password");
      expect(result.success, true);

      final userData = await accountController.getUserData();
      expect(userData, isA<Map<String, dynamic>>());
      expect(userData!['email'], "test@test.com");
      expect(userData['accountType'], AccountType.User);
    });
  });
}