import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kintaikei_web/models/company_group.dart';

class CompanyGroupService {
  String collection = 'companyGroup';
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

  Future<List<CompanyGroupModel>> selectList({
    required String companyId,
  }) async {
    List<CompanyGroupModel> ret = [];
    await firestore
        .collection(collection)
        .where('companyId', isEqualTo: companyId)
        .orderBy('index', descending: false)
        .get()
        .then((value) {
      for (DocumentSnapshot<Map<String, dynamic>> map in value.docs) {
        ret.add(CompanyGroupModel.fromSnapshot(map));
      }
    });
    return ret;
  }
}
