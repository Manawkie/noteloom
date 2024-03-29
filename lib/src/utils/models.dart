import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String? username;
  final String? name;
  final String email;
  final String? universityId;

  UserModel(
      {required this.id,
      required this.email,
      this.name,
      this.universityId,
      this.username});

  factory UserModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot, _) {
    final data = snapshot.data();
    final id = snapshot.id;

    final fromFirebase = UserModel(
        id: id,
        email: data?['email'],
        username: data?['username'],
        name: data?['name'],
        universityId: data?['universityId']);

    return fromFirebase;
  }
  Map<String, dynamic> toFirestore() {
    return {
      "email": email,
      if (username != null) "username": username,
      if (name != null) "name": name,
      if (universityId != null) "universityId": universityId
    };
  }
}

class UniversityModel {
  final String id;
  final String name;
  final String domain;
  final String? storageLogoPath;
  final List<String>? subjectIds;
  final List<String>? departmentIds;

  UniversityModel(
      {required this.id,
      required this.name,
      required this.domain,
      this.storageLogoPath,
      this.subjectIds,
      this.departmentIds});

  factory UniversityModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot, _) {
    final data = snapshot.data();
    final id = snapshot.id;

    final university = UniversityModel(
        id: id,
        name: data?['name'],
        domain: data?['domain'],
        storageLogoPath: data?['storageLogoPath'],
        subjectIds: data?['subjectIds']?.cast<String>(),
        departmentIds: data?['departmentIds']?.cast<String>());

    return university;
  }

  Map<String, dynamic> toFirestore() {
    return {
      "name": name,
      "domain": domain,
      if (storageLogoPath != null) "storageLogoPath": storageLogoPath,
      if (subjectIds != null) "subjectIds": subjectIds,
      if (departmentIds != null) "departmentIds": departmentIds
    };
  }
}

class DepartmentModel {
  final String id;
  final String name;
  final DocumentReference<UniversityModel> universityRef;

  DepartmentModel(
      {required this.id, required this.name, required this.universityRef});

  factory DepartmentModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data();
    final id = snapshot.id;

    final department = DepartmentModel(
        id: id, name: data?['name'], universityRef: data?["universityRef"]);

    return department;
  }
}

class SubjectModel {
  String id;
  String name;
  List<String> subjectCode;

  SubjectModel(
      {required this.id, required this.name, required this.subjectCode});

  factory SubjectModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot, options) {
    final data = snapshot.data();
    final id = snapshot.id;

    return SubjectModel(
        id: id,
        name: data?['name'],
        subjectCode: data?['subjectCode']?.cast<String>());
  }
}

class NoteModel {
  String? id;
  String name;
  String storagePath;
  List<String>? tags;

  NoteModel(
      {this.id,
      required this.name,
      required this.storagePath,
      this.tags});

  factory NoteModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot, __) {
    final data = snapshot.data();
    final id = snapshot.id;

    final note = NoteModel(
        id: id,
        name: data?['name'],
        storagePath: data?['storagePath'],
        tags: data?['tags'].cast<String>());
    return note;
  }

  Map<String, dynamic> toFirestore() {
    return {
      "id": id,
      "name": name,
      "storagePath": storagePath,
      if (tags != null) "tags": tags
    };
  }
}
