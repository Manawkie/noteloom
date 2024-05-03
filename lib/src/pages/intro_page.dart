import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:school_app/src/utils/firebase.dart';
import 'package:school_app/src/utils/models.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  final _findUniversity = TextEditingController();

  bool isOnLogin = false;

  List<String> universities = <String>[];
  List<String> filterUniversities = [];
  @override
  void initState() {
    Database.getUniversities().then((List<UniversityModel> universityLists) {
      universities =
          universityLists.map((university) => university.name).toList();
      filterUniversities = universities;
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _findUniversity.dispose();
  }

  void _displayUniversities(String input) {
    setState(() {
      filterUniversities = universities
          .where((university) =>
              university.toLowerCase().contains(input.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white70,
        body: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Positioned(
                  child: GestureDetector(
                      onVerticalDragEnd: (details) {
                        if (details.velocity.pixelsPerSecond.dy > 100) {
                          setState(() {
                            isOnLogin = false;
                          });
                        }

                        if (details.velocity.pixelsPerSecond.dy < 100) {
                          setState(() {
                            isOnLogin = true;
                          });
                        }
                      },
                      child: AnimatedContainer(
                        margin: EdgeInsets.only(
                          bottom: isOnLogin
                              ? MediaQuery.of(context).size.height * 0.15
                              : 0,
                        ),
                        duration: const Duration(milliseconds: 1000),
                        curve: Curves.ease,
                        child: Image.asset("assets/images/app/introimage.png")
                      ))),
              Positioned(
  top: 0,
  left: 0,
  child: AnimatedOpacity(
    opacity: isOnLogin ? 0 : 1,
    duration: const Duration(milliseconds: 500),
    curve: Curves.ease,
    child: SafeArea(
      child: Container(
        height: 300,
        margin: const EdgeInsets.only(left: 20, top: 20, right: 20), // Adjusted margin to include right
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Welcome to",
              style: TextStyle(fontSize: 30, color: Colors.black),
            ),
            const SizedBox(height: 20),
            Image.asset(
              "assets/images/app/logoNoteloom.png",
              height: 120,
              fit: BoxFit.contain, // Ensures the image fits within the bounds
            ),
            const SizedBox(height: 20),
            Text(
              "Find and share your notes\nwithin your university.",
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w300),
            ),
            const SizedBox(height: 17),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Color.fromARGB(255, 67, 178, 248)),
                overlayColor: MaterialStateProperty.resolveWith<Color?>(
                  (Set<MaterialState> states) {
                    if (states.contains(MaterialState.hovered)) {
                      return Colors.grey.shade900; // Dark hover effect
                    }
                    return null; // Defer to the widget's default.
                  },
                ),
              ),
              child: const Text("Get Started", style: TextStyle(color: Color.fromARGB(255, 0, 0, 0))),
              onPressed: () {
                setState(() {
                  isOnLogin = !isOnLogin;
                });
              }
            ),
          ],
        ),
      ),
    ),
  ),
),
              AnimatedPositioned(
                bottom:
                    isOnLogin ? 0 : -MediaQuery.of(context).size.height * 0.7,
                curve: Curves.ease,
                duration: isOnLogin
                    ? const Duration(milliseconds: 600)
                    : const Duration(milliseconds: 1500),
                child: GestureDetector(
                  onVerticalDragEnd: (details) {
                    if (details.velocity.pixelsPerSecond.dy > 100) {
                      setState(() {
                        isOnLogin = false;
                      });
                    }
                  },
                  child: Center(
                    child: Container(
                        decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(20))),
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height * 0.7,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 40),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Check if your school is\navailable:",
                                style: TextStyle(fontSize: 20),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              TextField(
                                controller: _findUniversity,
                                onChanged: (value) {
                                  _displayUniversities(value);
                                },
                              ),
                              const SizedBox(
                                height: 20,
                              ),

                              // used for list of universities

                              Flexible(
                                child: SingleChildScrollView(
                                  child: filterUniversities.isNotEmpty
                                      ? ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: filterUniversities.length,
                                          itemBuilder: (context, index) {
                                            final university =
                                                filterUniversities[index];
                                            return ListTile(
                                              onTap: () {
                                                setState(() {
                                                  _findUniversity.text =
                                                      university;
                                                });
                                              },
                                              tileColor: Colors.grey[200],
                                              title: Text(university),
                                            );
                                          },
                                        )
                                      : Container()
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Center(
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (universities
                                        .contains(_findUniversity.text)) {
                                      GoRouter.of(context)
                                          .goNamed("login", pathParameters: {
                                        "universityName": _findUniversity.text
                                      });
                                    }
                                  },
                                  child: const Text("Get Started"),
                                ),
                              )
                            ],
                          ),
                        )),
                  ),
                ),
              )
            ],
          ),
        ));
  }
}
