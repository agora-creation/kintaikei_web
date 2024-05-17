import 'package:fluent_ui/fluent_ui.dart';
import 'package:kintaikei_web/models/company_group.dart';
import 'package:kintaikei_web/models/user.dart';
import 'package:kintaikei_web/services/company_group.dart';
import 'package:kintaikei_web/services/user.dart';

class UserProvider with ChangeNotifier {
  final CompanyGroupService _groupService = CompanyGroupService();
  final UserService _userService = UserService();

  Future<String?> create({
    required CompanyGroupModel? group,
    required String name,
    required String email,
    required String password,
  }) async {
    String? error;
    if (group == null) return 'スタッフの新規加入に失敗しました';
    if (name == '') return 'スタッフ名を入力してください';
    if (email == '') return 'メールアドレスを入力してください';
    if (password == '') return 'パスワードを入力してください';
    UserModel? tmpUser = await _userService.selectToEmail(email: email);
    if (tmpUser != null) return '既に同じメールアドレスが登録されております';
    try {
      String id = _userService.id();
      _userService.create({
        'id': id,
        'name': name,
        'email': email,
        'password': password,
        'uid': '',
        'token': '',
        'lastWorkId': '',
        'lastWorkBreakId': '',
        'createdAt': DateTime.now(),
      });
      List<String> userIds = group.userIds;
      if (!userIds.contains(id)) {
        userIds.add(id);
      }
      _groupService.update({
        'id': group.id,
        'userIds': userIds,
      });
    } catch (e) {
      error = 'スタッフの新規加入に失敗しました';
    }
    return error;
  }
}
