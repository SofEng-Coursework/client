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

    setUpAll(() {
      firebaseProvider = FirebaseProvider();
      firebaseProvider.initializeMock();
      userAccountController = UserAccountController(firebaseProvider: firebaseProvider);
    });

    tearDown(() {
      // Delete the user account
      firebaseProvider.FIREBASE_AUTH.currentUser!.delete();
    });

    test('is initialized', () {
      expect(userAccountController, isA<UserAccountController>());
    });

    test('can query the history', () async {
      await userAccountController.signUp("email@email.com", "password", "name", "07123456789");

      final result = await userAccountController.getHistory();
      expect(result, isA<List<Map<String, dynamic>>>());

      
    });
  });
}
