import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:kintaikei_web/models/company.dart';
import 'package:kintaikei_web/models/company_group.dart';
import 'package:kintaikei_web/services/company.dart';
import 'package:kintaikei_web/services/company_group.dart';
import 'package:kintaikei_web/services/local_db.dart';

enum AuthStatus {
  authenticated,
  uninitialized,
  authenticating,
  unauthenticated,
}

class LoginProvider with ChangeNotifier {
  AuthStatus _status = AuthStatus.uninitialized;
  AuthStatus get status => _status;
  final FirebaseAuth? _auth;
  User? _authUser;
  User? get authUser => _authUser;

  final LocalDBService _localDBService = LocalDBService();
  final CompanyService _companyService = CompanyService();
  final CompanyGroupService _groupService = CompanyGroupService();
  CompanyModel? _company;
  CompanyModel? get company => _company;
  List<CompanyGroupModel> _groups = [];
  List<CompanyGroupModel> get groups => _groups;

  LoginProvider.initialize() : _auth = FirebaseAuth.instance {
    _auth?.authStateChanges().listen(_onStateChanged);
  }

  Future<String?> register({
    required String name,
    required String loginId,
    required String password,
  }) async {
    String? error;
    if (name == '') return '会社名を入力してください';
    if (loginId == '') return 'ログインIDを入力してください';
    if (password == '') return 'パスワードを入力してください';
    try {
      _status = AuthStatus.authenticating;
      notifyListeners();
      final result = await _auth?.signInAnonymously();
      _authUser = result?.user;
      bool isExist = await _companyService.loginIdCheck(loginId);
      if (!isExist) {
        String id = _companyService.id();
        _companyService.create({
          'id': id,
          'name': name,
          'loginId': loginId,
          'password': password,
          'createdAt': DateTime.now(),
        });
        String groupId = _groupService.id();
        _groupService.create({
          'id': groupId,
          'companyId': id,
          'companyName': name,
          'name': '本社',
          'loginId': '$loginId-1',
          'password': password,
          'userIds': [],
          'createdAt': DateTime.now(),
        });
        await _localDBService.setString('loginId', loginId);
        await _localDBService.setString('password', password);
      } else {
        await _auth?.signOut();
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        error = '既に同じログインIDが登録されています';
      }
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      error = '登録に失敗しました';
    }
    return error;
  }

  Future<String?> login({
    required String loginId,
    required String password,
  }) async {
    String? error;
    if (loginId == '') return 'ログインIDを入力してください';
    if (password == '') return 'パスワードを入力してください';
    try {
      _status = AuthStatus.authenticating;
      notifyListeners();
      final result = await _auth?.signInAnonymously();
      _authUser = result?.user;
      CompanyModel? tmpCompany = await _companyService.selectToLogin(
        loginId: loginId,
        password: password,
      );
      if (tmpCompany != null) {
        _company = tmpCompany;
        List<CompanyGroupModel> tmpGroups = await _groupService.selectList(
          companyId: tmpCompany.id,
        );
        if (tmpGroups.isNotEmpty) {
          _groups = tmpGroups;
        }
        await _localDBService.setString('loginId', loginId);
        await _localDBService.setString('password', password);
      } else {
        await _auth?.signOut();
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        error = 'ログインIDまたはパスワードが間違ってます';
      }
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      error = 'ログインに失敗しました';
    }
    return error;
  }

  Future<String?> update({
    required CompanyModel? company,
    required String name,
    required String password,
  }) async {
    String? error;
    if (company == null) return '会社情報の変更に失敗しました';
    if (name == '') return '会社名を入力してください';
    if (password == '') return 'パスワードを入力してください';
    try {
      _companyService.update({
        'id': company.id,
        'name': name,
        'password': password,
      });
      await _localDBService.setString('password', password);
    } catch (e) {
      error = '会社情報の変更に失敗しました';
    }
    return error;
  }

  Future logout() async {
    await _auth?.signOut();
    await _localDBService.clear();
    _company = null;
    _groups.clear();
    _status = AuthStatus.unauthenticated;
    notifyListeners();
    return Future.delayed(Duration.zero);
  }

  Future reloadData() async {
    String? loginId = await _localDBService.getString('loginId');
    String? password = await _localDBService.getString('password');
    if (loginId != null && password != null) {
      CompanyModel? tmpCompany = await _companyService.selectToLogin(
        loginId: loginId,
        password: password,
      );
      if (tmpCompany != null) {
        _company = tmpCompany;
        List<CompanyGroupModel> tmpGroups = await _groupService.selectList(
          companyId: tmpCompany.id,
        );
        if (tmpGroups.isNotEmpty) {
          _groups = tmpGroups;
        }
      }
    }
    notifyListeners();
  }

  Future _onStateChanged(User? authUser) async {
    if (authUser == null) {
      _status = AuthStatus.unauthenticated;
    } else {
      _authUser = authUser;
      _status = AuthStatus.authenticated;
      String? loginId = await _localDBService.getString('loginId');
      String? password = await _localDBService.getString('password');
      if (loginId != null && password != null) {
        CompanyModel? tmpCompany = await _companyService.selectToLogin(
          loginId: loginId,
          password: password,
        );
        if (tmpCompany != null) {
          _company = tmpCompany;
          List<CompanyGroupModel> tmpGroups = await _groupService.selectList(
            companyId: tmpCompany.id,
          );
          if (tmpGroups.isNotEmpty) {
            _groups = tmpGroups;
          }
        } else {
          _authUser = null;
          _status = AuthStatus.unauthenticated;
        }
      } else {
        _authUser = null;
        _status = AuthStatus.unauthenticated;
      }
    }
    notifyListeners();
  }
}
