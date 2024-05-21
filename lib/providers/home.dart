import 'package:fluent_ui/fluent_ui.dart';
import 'package:kintaikei_web/models/company.dart';
import 'package:kintaikei_web/models/company_group.dart';
import 'package:kintaikei_web/services/company_group.dart';

class HomeProvider with ChangeNotifier {
  int currentIndex = 0;
  final CompanyGroupService _groupService = CompanyGroupService();
  CompanyGroupModel? currentGroup;

  void currentIndexChange(int index) {
    currentIndex = index;
    notifyListeners();
  }

  Future init(CompanyGroupModel? group) async {
    currentGroup = group;
    notifyListeners();
  }

  void currentGroupChange(CompanyGroupModel? value) {
    currentIndex = 0;
    currentGroup = value;
    notifyListeners();
  }

  void currentGroupClear() {
    currentIndex = 0;
    notifyListeners();
  }

  Future<String?> groupCreate({
    required CompanyModel? company,
    required int index,
    required String name,
    required String password,
  }) async {
    String? error;
    if (company == null) return 'グループの追加に失敗しました';
    if (name == '') return 'グループ名を入力してください';
    if (password == '') return 'パスワードを入力してください';
    try {
      String id = _groupService.id();
      _groupService.create({
        'id': id,
        'companyId': company.id,
        'companyName': company.name,
        'index': index,
        'name': name,
        'loginId': '${company.loginId}-$index',
        'password': password,
        'userIds': [],
        'createdAt': DateTime.now(),
      });
    } catch (e) {
      error = 'グループの追加に失敗しました';
    }
    return error;
  }

  Future<String?> groupUpdate({
    required CompanyGroupModel? group,
    required String name,
    required String password,
  }) async {
    String? error;
    if (group == null) return 'グループ情報の変更に失敗しました';
    if (name == '') return 'グループ名を入力してください';
    if (password == '') return 'パスワードを入力してください';
    try {
      _groupService.update({
        'id': group.id,
        'name': name,
        'password': password,
      });
    } catch (e) {
      error = 'グループ情報の変更に失敗しました';
    }
    return error;
  }

  Future<String?> groupDelete({
    required CompanyGroupModel? group,
  }) async {
    String? error;
    if (group == null) return 'グループの削除に失敗しました';
    try {
      _groupService.delete({
        'id': group.id,
      });
    } catch (e) {
      error = 'グループの削除に失敗しました';
    }
    return error;
  }
}
