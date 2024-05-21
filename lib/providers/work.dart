import 'package:fluent_ui/fluent_ui.dart';
import 'package:kintaikei_web/models/work.dart';
import 'package:kintaikei_web/services/work.dart';

class WorkProvider with ChangeNotifier {
  final WorkService _workService = WorkService();

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
