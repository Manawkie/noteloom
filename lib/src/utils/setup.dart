import 'package:school_app/src/utils/firebase.dart';
import 'package:school_app/src/utils/models.dart';

List<String> schoolYears = [
  "School Year",
  "2023-2024",
  "2024-2025",
  "2026-2027",
  "2027-2028",
  "2028-2029",
  "2029-2030"
];

Future<List<Map<String, List<String>>>> getDepartmentAndCourses() async {
  final departmentsAndCourses = <Map<String, List<String>>>[];

  final departments = await Database.db
      .collection("universities")
      .doc(Auth.schoolDomain)
      .collection("departments")
      .withConverter(
          fromFirestore: DepartmentModel.fromFirestore,
          toFirestore: (model, _) => model.toFirestore())
      .get();

  for (var department in departments.docs) {
    final courses = await Database.db
        .collection("universities")
        .doc(Auth.schoolDomain)
        .collection("departments")
        .doc(department.id)
        .collection("courses")
        .withConverter(
            fromFirestore: CourseModel.fromFirestore,
            toFirestore: (model, _) => model.toFirestore())
        .get()
        .then((snapshot) =>
            snapshot.docs.map((course) => course.data().name).toList());

    departmentsAndCourses.add({department.data().name: courses});
  }

  return departmentsAndCourses;
}
