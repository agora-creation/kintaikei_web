import 'package:fluent_ui/fluent_ui.dart';
import 'package:kintaikei_web/models/company.dart';
import 'package:kintaikei_web/models/company_group.dart';
import 'package:kintaikei_web/models/plan_shift.dart';
import 'package:kintaikei_web/models/user.dart';
import 'package:kintaikei_web/services/plan_shift.dart';

class PlanShiftProvider with ChangeNotifier {
  final PlanShiftService _planShiftService = PlanShiftService();

  Future<String?> create({
    required CompanyModel? company,
    required CompanyGroupModel? group,
    required List<UserModel> users,
    required DateTime startedAt,
    required DateTime endedAt,
    required bool allDay,
    required bool repeat,
    required String repeatInterval,
    required List<String> repeatWeeks,
    required int alertMinute,
  }) async {
    String? error;
    if (company == null) return '勤務予定の追加に失敗しました';
    if (group == null) return '勤務予定の追加に失敗しました';
    if (users.isEmpty) return '勤務予定の追加に失敗しました';
    if (startedAt.millisecondsSinceEpoch > endedAt.millisecondsSinceEpoch) {
      return '日時を正しく選択してください';
    }
    try {
      for (UserModel user in users) {
        String id = _planShiftService.id();
        _planShiftService.create({
          'id': id,
          'companyId': company.id,
          'companyName': company.name,
          'groupId': group.id,
          'groupName': group.name,
          'userId': user.id,
          'userName': user.name,
          'startedAt': startedAt,
          'endedAt': endedAt,
          'allDay': allDay,
          'repeat': repeat,
          'repeatInterval': repeatInterval,
          'repeatWeeks': repeatWeeks,
          'repeatUntil': null,
          'alertMinute': alertMinute,
          'alertedAt': startedAt.subtract(Duration(minutes: alertMinute)),
          'createdAt': DateTime.now(),
        });
      }
    } catch (e) {
      error = '勤務予定の追加に失敗しました';
    }
    return error;
  }

  Future<String?> update({
    required String id,
    required DateTime startedAt,
    required DateTime endedAt,
    required bool allDay,
    required bool repeat,
    required String repeatInterval,
    required List<String> repeatWeeks,
    required int alertMinute,
  }) async {
    String? error;
    if (startedAt.millisecondsSinceEpoch > endedAt.millisecondsSinceEpoch) {
      return '日時を正しく選択してください';
    }
    try {
      _planShiftService.update({
        'id': id,
        'startedAt': startedAt,
        'endedAt': endedAt,
        'allDay': allDay,
        'repeat': repeat,
        'repeatInterval': repeatInterval,
        'repeatWeeks': repeatWeeks,
        'repeatUntil': null,
        'alertMinute': alertMinute,
        'alertedAt': startedAt.subtract(Duration(minutes: alertMinute)),
      });
    } catch (e) {
      error = '予定の編集に失敗しました';
    }
    return error;
  }

  Future<String?> delete({
    required PlanShiftModel? planShift,
    required bool isAllDelete,
    required DateTime date,
  }) async {
    String? error;
    if (planShift == null) return '勤務予定の削除に失敗しました';
    try {
      if (planShift.repeat) {
        if (isAllDelete) {
          _planShiftService.delete({
            'id': planShift.id,
          });
        } else {
          //一旦区切り更新
          DateTime repeatUntil = DateTime(
            date.year,
            date.month,
            date.day,
            0,
            0,
            0,
          ).subtract(const Duration(days: 1));
          _planShiftService.update({
            'id': planShift.id,
            'repeatUntil': repeatUntil,
          });
          //一旦区切り登録
          String id = _planShiftService.id();
          DateTime startedAt = DateTime(
            date.year,
            date.month,
            date.day,
            planShift.startedAt.hour,
            planShift.startedAt.minute,
            planShift.startedAt.second,
          ).add(const Duration(days: 1));
          DateTime endedAt = DateTime(
            date.year,
            date.month,
            date.day,
            planShift.endedAt.hour,
            planShift.endedAt.minute,
            planShift.endedAt.second,
          ).add(const Duration(days: 1));
          _planShiftService.create({
            'id': id,
            'companyId': planShift.companyId,
            'companyName': planShift.companyName,
            'groupId': planShift.groupId,
            'groupName': planShift.groupName,
            'userId': planShift.userId,
            'userName': planShift.userName,
            'startedAt': startedAt,
            'endedAt': endedAt,
            'allDay': planShift.allDay,
            'repeat': planShift.repeat,
            'repeatInterval': planShift.repeatInterval,
            'repeatWeeks': planShift.repeatWeeks,
            'repeatUntil': null,
            'alertMinute': planShift.alertMinute,
            'alertedAt': startedAt.subtract(
              Duration(minutes: planShift.alertMinute),
            ),
            'createdAt': planShift.createdAt,
          });
        }
      } else {
        _planShiftService.delete({
          'id': planShift.id,
        });
      }
    } catch (e) {
      error = '勤務予定の削除に失敗しました';
    }
    return error;
  }
}
