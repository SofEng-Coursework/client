import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:virtual_queue/controllers/FirebaseProvider.dart';
import 'package:virtual_queue/controllers/AccountController.dart';
import 'package:virtual_queue/pages/RegisterForm.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group("AccountController Signing Up", () {
    late AccountController accountController;
    late FirebaseProvider firebaseProvider;

    setUpAll(() {
      firebaseProvider = FirebaseProvider();
      firebaseProvider.initializeMock();
      accountController = AccountController(collectionName: 'users', firebaseProvider: firebaseProvider);
    });

    tearDown(() {
      firebaseProvider.FIREBASE_AUTH.currentUser?.delete();
    });

    test('is initialized', () {
      expect(accountController, isA<AccountController>());
    });

    test('can sign up and be authenticated', () async {
      final result = await accountController.signUp("test", "password", "name", "07123456789");
      expect(result.success, false);
      expect(result.message, "Invalid email");
      final result2 = await accountController.signUp("test@test.com", "pass", "name", "07123456789");
      expect(result2.success, false);
      expect(result2.message, "Invalid password");
      final result3 = await accountController.signUp("test@test.com", "password", "name", "071234");
      expect(result3.success, false);
      expect(result3.message, "Invalid phone number");
      final result1 = await accountController.signUp("test@test.com", "password", "name", "07123456789");
      expect(result1.success, true);
      final user = firebaseProvider.FIREBASE_AUTH.currentUser;
      expect(user, isA<MockUser>());
      expect(user!.email, "test@test.com");
    });
  });

  group("AccountController Signing In & Out", () {
    late AccountController accountController;
    late FirebaseProvider firebaseProvider;

    // For this group, create the account once
    setUpAll(() async {
      firebaseProvider = FirebaseProvider();
      firebaseProvider.initializeMock();
      accountController = AccountController(collectionName: 'users', firebaseProvider: firebaseProvider);

      await accountController.signUp("test@test.com", "password", "name", "07123456789");
    });

    // For each test, sign in
    tearDown(() async {
      await firebaseProvider.FIREBASE_AUTH.signOut();
    });

    // After all tests, delete the account
    tearDownAll(() async {
      await firebaseProvider.FIREBASE_AUTH.currentUser?.delete();
    });

    test('is initialized', () {
      expect(accountController, isA<AccountController>());
    });

    test('can sign in and be authenticated', () async {
      final result = await accountController.login("test@test.com", "password");
      expect(result.success, true);
      final user = firebaseProvider.FIREBASE_AUTH.currentUser;
      expect(user, isA<MockUser>());
      expect(user!.email, "test@test.com");
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
      await accountController.login("test@test.com", "password");
      final result = await accountController.signOut();
      expect(result.success, true);
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