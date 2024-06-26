import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:kintaikei_web/common/functions.dart';
import 'package:kintaikei_web/common/style.dart';
import 'package:kintaikei_web/models/plan_shift.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart' as sfc;

class PlanShiftService {
  String collection = 'planShift';
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

  Future<PlanShiftModel?> selectDataToId({
    required String id,
  }) async {
    PlanShiftModel? ret;
    await firestore
        .collection(collection)
        .where('id', isEqualTo: id)
        .get()
        .then((value) {
      if (value.docs.isNotEmpty) {
        ret = PlanShiftModel.fromSnapshot(value.docs.first);
      }
    });
    return ret;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>>? streamList({
    required String? companyId,
    required String? groupId,
  }) {
    return FirebaseFirestore.instance
        .collection(collection)
        .where('companyId', isEqualTo: companyId ?? 'error')
        .where('groupId', isEqualTo: groupId ?? 'error')
        .orderBy('startedAt', descending: true)
        .snapshots();
  }

  List<sfc.Appointment> convertListAppointment(
    AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot,
  ) {
    List<sfc.Appointment> ret = [];
    if (snapshot.hasData) {
      for (DocumentSnapshot<Map<String, dynamic>> doc in snapshot.data!.docs) {
        PlanShiftModel planShift = PlanShiftModel.fromSnapshot(doc);
        String startTimeText = convertDateText('HH:mm', planShift.startedAt);
        String endTimeText = convertDateText('HH:mm', planShift.endedAt);
        ret.add(sfc.Appointment(
          id: planShift.id,
          resourceIds: [planShift.userId],
          subject: '勤務予定 $startTimeText～$endTimeText',
          startTime: planShift.startedAt,
          endTime: planShift.endedAt,
          isAllDay: planShift.allDay,
          color: kGrey600Color,
          notes: 'planShift',
          recurrenceRule: planShift.getRepeatRule(),
        ));
      }
    }
    return ret;
  }
}
