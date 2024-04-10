import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:school_app/src/utils/firebase.dart';

class UserModel {
  final String id;
  final String username;
  final String name;
  final String email;
  final String universityId;
  final String? schoolyears;
  final String? department;
  final String? course;

  UserModel(
      {required this.id,
      required this.email,
      required this.name,
      required this.universityId,
      required this.username,
      this.course,
      this.department,
      this.schoolyears});

  factory UserModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot, options) {
    final data = snapshot.data();
    final id = snapshot.id;

    final fromFirebase = UserModel(
        id: id,
        email: data?['email'],
        username: data?['username'],
        name: data?['name'],
        universityId: data?['universityId'],
        course: data?['course'],
        department: data?['department'],
        schoolyears: data?['schoolyears']);

    return fromFirebase;
  }

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      id: data['id'],
      email: data['email'],
      username: data['username'],
      name: data['name'],
      universityId: data['universityId'],
      course: data['course'],
      department: data['department'],
      schoolyears: data['schoolyears'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "email": email,
      "username": username,
      "name": name,
      "universityId": universityId,
      if (schoolyears != null) "schoolyears": schoolyears,
      if (department != null) "department": department,
      if (course != null) "course": course
    };
  }
}

class UniversityModel {
  final String id;
  final String name;
  final String? storageLogoPath;
  final List<String>? subjectIds;
  final List<DepartmentModel>? departmentIds;

  UniversityModel(
      {required this.id,
      required this.name,
      this.storageLogoPath,
      this.subjectIds,
      this.departmentIds});

  factory UniversityModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot, options) {
    final data = snapshot.data();
    final id = snapshot.id;

    final university = UniversityModel(
        id: id,
        name: data?['name'],
        storageLogoPath: data?['storageLogoPath'],
        subjectIds: data?['subjectIds']?.cast<String>(),
        departmentIds: data?['departmentIds']?.cast<String>());

    return university;
  }

  Map<String, dynamic> toFirestore() {
    return {
      "name": name,
      if (storageLogoPath != null) "storageLogoPath": storageLogoPath,
      if (subjectIds != null) "subjectIds": subjectIds,
      if (departmentIds != null) "departmentIds": departmentIds
    };
  }
}

class DepartmentModel {
  final String id;
  final String name;
  final DocumentReference<UniversityModel>? universityRef;

  DepartmentModel({
    required this.id,
    required this.name,
    this.universityRef,
  });

  factory DepartmentModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot, options) {
    final data = snapshot.data();
    final id = snapshot.id;

    final department = DepartmentModel(
      id: id,
      name: data?['name'],
      universityRef: data?["universityRef"],
    );

    return department;
  }

  Map<String, dynamic> toFirestore() {
    return {"name": name, "universityRef": universityRef};
  }
}

class CourseModel {
  final String id;
  final String name;
  final List<DocumentReference>? subjects;

  CourseModel({required this.id, required this.name, this.subjects});

  factory CourseModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot, options) {
    final data = snapshot.data();
    final id = snapshot.id;
    

    final course = CourseModel(
        id: id,
        name: data?['name'],
        subjects: data?['subjects'].cast<DocumentReference>());

    return course;
  }

  Map<String, dynamic> toFirestore() {
    return {"name": name, if (subjects != null) "subjects": subjects};
  }
}

class SubjectModel {
  String id;
  String Subject;
  List<String>? subjectCode;

  SubjectModel({required this.id, required this.Subject, this.subjectCode});

  factory SubjectModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot, options) {
    final data = snapshot.data();
    final id = snapshot.id;

    return SubjectModel(
        id: id,
        Subject: data?['Subject'],
        subjectCode: data?['subjectCode']?.cast<String>());
  }
  Map<String, dynamic> toFirestore() {
    return {
      "Subject": Subject,
      if (subjectCode != null) "subjectCode": subjectCode,
    };
  }
}

class NoteModel {
  String? id;
  String name;
  String subject;
  String time;
  String storagePath;
  List<String>? tags;
  String? summary;

  NoteModel(
      {this.id,
      required this.name,
      required this.subject,
      required this.time,
      required this.storagePath,
      this.tags,
      this.summary});

  factory NoteModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot, __) {
    final data = snapshot.data();
    final id = snapshot.id;

    final note = NoteModel(
        id: id,
        name: data?['name'],
        subject: data?['subject'],
        time: data?['time'],
        storagePath: data?['storagePath'],
        tags: data?['tags'].cast<String>(),
        summary: data?['summary']);

    return note;
  }

  Map<String, dynamic> toFirestore() {
    return {
      "name": name,
      "subject": subject,
      "time": DateTime.now().toString(),
      "storagePath": storagePath,
      if (tags != null) "tags": tags,
      if (summary != null) "summary": summary
    };
  }
}

class MessageModel {
  String? id;
  String message;
  String senderId;
  String receiverId;
  String timestamp;

  MessageModel(
      {this.id,
      required this.message,
      required this.senderId,
      required this.receiverId,
      required this.timestamp});

  factory MessageModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot, __) {
    final data = snapshot.data();
    final id = snapshot.id;

    final message = MessageModel(
        id: id,
        message: data?['message'],
        senderId: data?['senderId'],
        receiverId: data?['receiverId'],
        timestamp: data?['timestamp']);
    return message;
  }

  Map<String, dynamic> toFirestore() {
    return {
      "id": id,
      "message": message,
      "senderId": senderId,
      "receiverId": receiverId,
      "timestamp": timestamp,
    };
  }
}
