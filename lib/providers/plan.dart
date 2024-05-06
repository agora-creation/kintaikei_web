import 'package:fluent_ui/fluent_ui.dart';
import 'package:kintaikei_web/models/company.dart';
import 'package:kintaikei_web/models/company_group.dart';
import 'package:kintaikei_web/services/plan.dart';

class PlanProvider with ChangeNotifier {
  final PlanService _planService = PlanService();

  Future<String?> create({
    required CompanyModel? company,
    required CompanyGroupModel? group,
    required String subject,
    required DateTime startedAt,
    required DateTime endedAt,
    required bool allDay,
    required Color color,
    required int alertMinute,
  }) async {
    String? error;
    if (company == null) return '予定の追加に失敗しました';
    if (group == null) return '予定の追加に失敗しました';
    if (subject == '') return '件名を入力してください';
    if (startedAt.millisecondsSinceEpoch > endedAt.millisecondsSinceEpoch) {
      return '日時を正しく選択してください';
    }
    try {
      String id = _planService.id();
      _planService.create({
        'id': id,
        'companyId': company.id,
        'companyName': company.name,
        'groupId': group.id,
        'groupName': group.name,
        'userId': '',
        'userName': '',
        'subject': subject,
        'startedAt': startedAt,
        'endedAt': endedAt,
        'allDay': allDay,
        'color': color.value.toRadixString(16),
        'alertMinute': alertMinute,
        'alertedAt': startedAt.subtract(Duration(minutes: alertMinute)),
        'createdAt': DateTime.now(),
      });
    } catch (e) {
      error = '予定の追加に失敗しました';
    }
    return error;
  }

  Future<String?> update({
    required String id,
    required String subject,
    required DateTime startedAt,
    required DateTime endedAt,
    required bool allDay,
    required Color color,
    required int alertMinute,
  }) async {
    String? error;
    if (subject == '') return '件名を入力してください';
    if (startedAt.millisecondsSinceEpoch > endedAt.millisecondsSinceEpoch) {
      return '日時を正しく選択してください';
    }
    try {
      _planService.update({
        'id': id,
        'subject': subject,
        'startedAt': startedAt,
        'endedAt': endedAt,
        'allDay': allDay,
        'color': color.value.toRadixString(16),
        'alertMinute': alertMinute,
        'alertedAt': startedAt.subtract(Duration(minutes: alertMinute)),
      });
    } catch (e) {
      error = '予定の編集に失敗しました';
    }
    return error;
  }

  Future<String?> delete({
    required String id,
  }) async {
    String? error;
    try {
      _planService.delete({
        'id': id,
      });
    } catch (e) {
      error = '予定の削除に失敗しました';
    }
    return error;
  }
}
