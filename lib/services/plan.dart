import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:kintaikei_web/common/functions.dart';
import 'package:kintaikei_web/models/plan.dart';
import 'package:kintaikei_web/models/user.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart' as sfc;

class PlanService {
  String collection = 'plan';
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

  Future<PlanModel?> selectDataToId({
    required String id,
  }) async {
    PlanModel? ret;
    await firestore
        .collection(collection)
        .where('id', isEqualTo: id)
        .get()
        .then((value) {
      if (value.docs.isNotEmpty) {
        ret = PlanModel.fromSnapshot(value.docs.first);
      }
    });
    return ret;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>>? streamList({
    required String? companyId,
    required String? groupId,
    DateTime? selectedDate,
  }) {
    if (selectedDate != null) {
      Timestamp startAt = convertTimestamp(selectedDate, false);
      Timestamp endAt = convertTimestamp(selectedDate, true);
      return FirebaseFirestore.instance
          .collection(collection)
          .where('companyId', isEqualTo: companyId ?? 'error')
          .where('groupId', isEqualTo: groupId ?? 'error')
          .orderBy('startedAt', descending: false)
          .startAt([startAt]).endAt([endAt]).snapshots();
    } else {
      return FirebaseFirestore.instance
          .collection(collection)
          .where('companyId', isEqualTo: companyId ?? 'error')
          .where('groupId', isEqualTo: groupId ?? 'error')
          .orderBy('startedAt', descending: true)
          .snapshots();
    }
  }

  List<sfc.Appointment> convertListAppointment(
    AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot, {
    bool shift = false,
    List<UserModel>? users,
  }) {
    List<sfc.Appointment> ret = [];
    if (snapshot.hasData) {
      List<String> resourceIds = [];
      if (users != null) {
        if (users.isNotEmpty) {
          for (UserModel user in users) {
            resourceIds.add(user.id);
          }
        }
      }
      for (DocumentSnapshot<Map<String, dynamic>> doc in snapshot.data!.docs) {
        PlanModel plan = PlanModel.fromSnapshot(doc);
        ret.add(sfc.Appointment(
          id: plan.id,
          resourceIds: resourceIds,
          subject: plan.subject,
          startTime: plan.startedAt,
          endTime: plan.endedAt,
          isAllDay: plan.allDay,
          color: !shift ? plan.color : plan.color.withOpacity(0.3),
          notes: 'plan',
        ));
      }
    }
    return ret;
  }
}
