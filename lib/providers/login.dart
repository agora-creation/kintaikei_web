import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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

  Future<String?> register() async {
    String? error;
    try {
      _status = AuthStatus.authenticating;
      notifyListeners();
      final result = await _auth?.signInAnonymously();
      _authUser = result?.user;
      bool isExist = await _companyService.loginIdCheck('agora');
      if (!isExist) {
        String id = _companyService.id();
        _companyService.create({
          'id': id,
          'name': '(有)アゴラ・クリエーション',
          'loginId': 'agora',
          'password': 'agora0101',
          'createdAt': DateTime.now(),
        });
        String groupId = _groupService.id();
        _groupService.create({
          'id': groupId,
          'companyId': id,
          'companyName': '(有)アゴラ・クリエーション',
          'name': '本社',
          'loginId': 'agora-1',
          'password': 'agora0101',
          'userIds': [],
          'createdAt': DateTime.now(),
        });
        await _localDBService.setString('loginId', 'agora');
        await _localDBService.setString('password', 'agora0101');
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

  Future<String?> login() async {
    String? error;
    try {
      _status = AuthStatus.authenticating;
      notifyListeners();
      final result = await _auth?.signInAnonymously();
      _authUser = result?.user;
      CompanyModel? tmpCompany = await _companyService.selectToLogin(
        loginId: 'agora',
        password: 'agora0101',
      );
      if (tmpCompany != null) {
        _company = tmpCompany;
        List<CompanyGroupModel> tmpGroups = await _groupService.selectList(
          companyId: tmpCompany.id,
        );
        if (tmpGroups.isNotEmpty) {
          _groups = tmpGroups;
        }
        await _localDBService.setString('loginId', 'agora');
        await _localDBService.setString('password', 'agora0101');
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

  Future logout() async {
    await _auth?.signOut();
    await _localDBService.clear();
    _company = null;
    _groups.clear();
    _status = AuthStatus.unauthenticated;
    notifyListeners();
    return Future.delayed(Duration.zero);
  }

  Future reload() async {
    String? email = await getPrefsString('email');
    String? password = await getPrefsString('password');
    if (email != null && password != null) {
      UserModel? tmpUser = await _userService.selectData(
        email: email,
        password: password,
        admin: true,
      );
      if (tmpUser != null) {
        OrganizationModel? tmpOrganization =
            await _organizationService.selectData(
          userId: tmpUser.id,
        );
        if (tmpOrganization != null) {
          _user = tmpUser;
          _organization = tmpOrganization;
          OrganizationGroupModel? tmpGroup = await _groupService.selectData(
            organizationId: tmpOrganization.id,
            userId: tmpUser.id,
          );
          if (tmpGroup != null) {
            _group = tmpGroup;
          }
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
      String? email = await getPrefsString('email');
      String? password = await getPrefsString('password');
      if (email != null && password != null) {
        UserModel? tmpUser = await _userService.selectData(
          email: email,
          password: password,
          admin: true,
        );
        if (tmpUser != null) {
          OrganizationModel? tmpOrganization =
              await _organizationService.selectData(
            userId: tmpUser.id,
          );
          if (tmpOrganization != null) {
            _user = tmpUser;
            _organization = tmpOrganization;
            OrganizationGroupModel? tmpGroup = await _groupService.selectData(
              organizationId: tmpOrganization.id,
              userId: tmpUser.id,
            );
            if (tmpGroup != null) {
              _group = tmpGroup;
            }
          } else {
            _authUser = null;
            _status = AuthStatus.unauthenticated;
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
