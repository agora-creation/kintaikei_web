import 'package:cloud_firestore/cloud_firestore.dart';

class ApplyModel {
  String _id = '';
  String _companyId = '';
  String _companyName = '';
  String _groupId = '';
  String _groupName = '';
  String _userId = '';
  String _userName = '';
  DateTime _createdAt = DateTime.now();

  String get id => _id;
  String get companyId => _companyId;
  String get companyName => _companyName;
  String get groupId => _groupId;
  String get groupName => _groupName;
  String get userId => _userId;
  String get userName => _userName;
  DateTime get createdAt => _createdAt;

  ApplyModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    Map<String, dynamic>? data = snapshot.data();
    if (data == null) return;
    _id = data['id'] ?? '';
    _companyId = data['companyId'] ?? '';
    _companyName = data['companyName'] ?? '';
    _groupId = data['groupId'] ?? '';
    _groupName = data['groupName'] ?? '';
    _userId = data['userId'] ?? '';
    _userName = data['userName'] ?? '';
    _createdAt = data['createdAt'].toDate() ?? DateTime.now();
  }
}
