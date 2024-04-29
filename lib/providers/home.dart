import 'package:fluent_ui/fluent_ui.dart';
import 'package:kintaikei_web/models/company.dart';
import 'package:kintaikei_web/models/company_group.dart';
import 'package:kintaikei_web/services/company_group.dart';

class HomeProvider with ChangeNotifier {
  int currentIndex = 0;
  final CompanyGroupService _groupService = CompanyGroupService();
  List<CompanyGroupModel> groups = [];
  CompanyGroupModel? currentGroup;

  void currentIndexChange(int index) {
    currentIndex = index;
    notifyListeners();
  }

  Future init({
    required String companyId,
    CompanyGroupModel? group,
  }) async {
    groups = await _groupService.selectList(companyId: companyId);
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
    currentGroup = null;
    notifyListeners();
  }

  Future<String?> groupCreate({
    required CompanyModel? company,
    required String name,
  }) async {
    String? error;
    if (company == null) return 'グループの追加に失敗しました';
    if (name == '') return 'グループ名を入力してください';
    try {
      String id = _groupService.id();
      _groupService.create({
        'id': id,
        'companyId': company.id,
        'companyName': company.name,
        'name': name,
        'loginId': '',
        'password': '',
        'userIds': [],
        'createdAt': DateTime.now(),
      });
      await init(companyId: company.id);
    } catch (e) {
      error = 'グループの追加に失敗しました';
    }
    return error;
  }

  Future<String?> groupDelete({
    required CompanyModel? company,
    required CompanyGroupModel? group,
  }) async {
    String? error;
    if (company == null) return 'グループの削除に失敗しました';
    if (group == null) return 'グループの削除に失敗しました';
    try {
      _groupService.delete({
        'id': group.id,
      });
      await init(companyId: company.id);
    } catch (e) {
      error = 'グループの削除に失敗しました';
    }
    return error;
  }
}
