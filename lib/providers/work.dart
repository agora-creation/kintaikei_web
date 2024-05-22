import 'package:fluent_ui/fluent_ui.dart';
import 'package:kintaikei_web/models/company_group.dart';
import 'package:kintaikei_web/models/user.dart';
import 'package:kintaikei_web/models/work.dart';
import 'package:kintaikei_web/services/work.dart';

class WorkProvider with ChangeNotifier {
  final WorkService _workService = WorkService();

  Future<String?> create({
    required CompanyGroupModel? group,
    required UserModel? user,
    required DateTime startedAt,
    required DateTime endedAt,
  }) async {
    String? error;
    if (group == null) return '勤怠打刻の追加に失敗しました';
    if (user == null) return '勤怠打刻の追加に失敗しました';
    if (startedAt.millisecondsSinceEpoch > endedAt.millisecondsSinceEpoch) {
      return '日時を正しく選択してください';
    }
    try {
      String id = _workService.id();
      List<Map> workBreaks = [];
      _workService.create({
        'id': id,
        'companyId': group.companyId,
        'companyName': group.companyName,
        'groupId': group.id,
        'groupName': group.name,
        'userId': user.id,
        'userName': user.name,
        'startedAt': startedAt,
        'endedAt': endedAt,
        'workBreaks': workBreaks,
        'createdAt': DateTime.now(),
      });
    } catch (e) {
      error = '勤怠打刻の追加に失敗しました';
    }
    return error;
  }

  Future<String?> update({
    required WorkModel? work,
    required DateTime startedAt,
    required DateTime endedAt,
  }) async {
    String? error;
    if (work == null) return '打刻情報の編集に失敗しました';
    if (startedAt.millisecondsSinceEpoch > endedAt.millisecondsSinceEpoch) {
      return '日時を正しく選択してください';
    }
    try {
      _workService.update({
        'id': work.id,
        'startedAt': startedAt,
        'endedAt': endedAt,
      });
    } catch (e) {
      error = '打刻情報の編集に失敗しました';
    }
    return error;
  }

  Future<String?> delete({
    required WorkModel? work,
  }) async {
    String? error;
    if (work == null) return '打刻情報の削除に失敗しました';
    try {
      _workService.delete({
        'id': work.id,
      });
    } catch (e) {
      error = '打刻情報の削除に失敗しました';
    }
    return error;
  }
}
