import 'package:virtual_queue/controllers/AccountController.dart';
import 'package:virtual_queue/controllers/FirebaseProvider.dart';

class AdminAccountController extends AccountController {
  late FirebaseProvider _firebaseProvider;
  AdminAccountController({required FirebaseProvider firebaseProvider})
    : super(collectionName: 'admins', firebaseProvider: firebaseProvider);


}

