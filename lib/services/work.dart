import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:kintaikei_web/common/functions.dart';
import 'package:kintaikei_web/models/user.dart';
import 'package:kintaikei_web/models/work.dart';

class WorkService {
  String collection = 'work';
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

  Stream<QuerySnapshot<Map<String, dynamic>>>? streamList({
    required String? companyId,
    required String? groupId,
    required DateTime searchMonth,
    required UserModel? searchUser,
  }) {
    Timestamp startAt = convertTimestamp(searchMonth, false);
    Timestamp endAt = convertTimestamp(searchMonth, true);
    return FirebaseFirestore.instance
        .collection(collection)
        .where('companyId', isEqualTo: companyId ?? 'error')
        .where('groupId', isEqualTo: groupId ?? 'error')
        .where('userId', isEqualTo: searchUser?.id ?? 'error')
        .orderBy('startedAt', descending: false)
        .startAt([startAt]).endAt([endAt]).snapshots();
  }

  List<WorkModel> convertList(
    AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot,
  ) {
    List<WorkModel> ret = [];
    if (snapshot.hasData) {
      for (DocumentSnapshot<Map<String, dynamic>> doc in snapshot.data!.docs) {
        WorkModel work = WorkModel.fromSnapshot(doc);
        if (work.startedAt.millisecondsSinceEpoch !=
            work.endedAt.millisecondsSinceEpoch) {
          ret.add(work);
        }
      }
    }
    return ret;
  }
}
