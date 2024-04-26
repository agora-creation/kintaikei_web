import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kintaikei_web/models/company.dart';

class CompanyService {
  String collection = 'company';
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

  Future<bool> loginIdCheck(String loginId) async {
    bool ret = false;
    await firestore
        .collection(collection)
        .where('loginId', isEqualTo: loginId)
        .get()
        .then((value) {
      if (value.docs.isNotEmpty) {
        ret = true;
      }
    });
    return ret;
  }

  Future<CompanyModel?> selectToLogin({
    required String? loginId,
    required String? password,
  }) async {
    CompanyModel? ret;
    await firestore
        .collection(collection)
        .where('loginId', isEqualTo: loginId ?? 'error')
        .where('password', isEqualTo: password ?? 'error')
        .get()
        .then((value) {
      if (value.docs.isNotEmpty) {
        ret = CompanyModel.fromSnapshot(value.docs.first);
      }
    });
    return ret;
  }
}
