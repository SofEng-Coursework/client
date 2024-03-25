import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:virtual_queue/controllers/FirebaseProvider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('Initialize mock auth', () async {
    FirebaseProvider firebaseProvider = FirebaseProvider();
    await firebaseProvider.initializeMock();
    expect(firebaseProvider.FIREBASE_AUTH, isA<MockFirebaseAuth>());
    expect(firebaseProvider.FIREBASE_FIRESTORE, isA<FakeFirebaseFirestore>());
  });  
}