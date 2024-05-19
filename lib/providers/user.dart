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

  Future<String?> update({
    required UserModel user,
    required String name,
    required String email,
    required String password,
  }) async {
    String? error;
    if (name == '') return 'スタッフ名を入力してください';
    if (email == '') return 'メールアドレスを入力してください';
    if (password == '') return 'パスワードを入力してください';
    try {
      _userService.update({
        'id': user.id,
        'name': name,
        'email': email,
        'password': password,
      });
    } catch (e) {
      error = 'スタッフ情報の編集に失敗しました';
    }
    return error;
  }

  Future<String?> groupIn({
    required CompanyGroupModel? group,
    required UserModel? user,
  }) async {
    String? error;
    if (group == null) return 'スタッフの加入に失敗しました';
    if (user == null) return 'スタッフの加入に失敗しました';
    try {
      List<String> userIds = group.userIds;
      if (!userIds.contains(user.id)) {
        userIds.add(user.id);
      }
      _groupService.update({
        'id': group.id,
        'userIds': userIds,
      });
    } catch (e) {
      error = 'スタッフの加入に失敗しました';
    }
    return error;
  }

  Future<String?> groupExit({
    required CompanyGroupModel? group,
    required UserModel user,
  }) async {
    String? error;
    if (group == null) return 'スタッフの脱退に失敗しました';
    try {
      List<String> userIds = group.userIds;
      if (userIds.contains(user.id)) {
        userIds.remove(user.id);
      }
      _groupService.update({
        'id': group.id,
        'userIds': userIds,
      });
    } catch (e) {
      error = 'スタッフの脱退に失敗しました';
    }
    return error;
  }
}
