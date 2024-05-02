import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kintaikei_web/models/user.dart';

class UserService {
  String collection = 'user';
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  String id() {
    return firestore.collection(collection).doc().id;
  }

  void create(Map<String, dynamic> values) {
    firestore.collection(collection).doc(values['id']).set(values);
  }

  void update(Map<String, dynamic> values) {
    firestore.collection(collection).doc(values['id']).update(values);
  }

  void delete(Map<String, dynamic> values) {
    firestore.collection(collection).doc(values['id']).delete();
  }

  Future<bool> emailCheck(String email) async {
    bool ret = false;
    await firestore
        .collection(collection)
        .where('email', isEqualTo: email)
        .get()
        .then((value) {
      if (value.docs.isNotEmpty) {
        ret = true;
      }
    });
    return ret;
  }

  Future<List<UserModel>> selectListToUserIds({
    required List<String> userIds,
  }) async {
    List<UserModel> ret = [];
    if (userIds.isNotEmpty) {
      await firestore
          .collection(collection)
          .where('id', whereIn: userIds)
          .orderBy('createdAt', descending: false)
          .get()
          .then((value) {
        for (DocumentSnapshot<Map<String, dynamic>> map in value.docs) {
          ret.add(UserModel.fromSnapshot(map));
        }
      });
    }
    return ret;
  }
}
