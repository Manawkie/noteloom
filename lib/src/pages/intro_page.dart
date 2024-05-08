import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:school_app/src/utils/firebase.dart';
import 'package:school_app/src/utils/models.dart';
import 'package:google_fonts/google_fonts.dart';

// class WavePainter extends CustomPainter {
//   final double
//       animationValue; // This should be updated by an external animation controller
//   WavePainter(this.animationValue);

//   @override
//   void paint(Canvas canvas, Size size) {
//     var paint = Paint()
//       ..color = Colors.blue[300]!
//       ..style = PaintingStyle.fill;

//     var path = Path();

//     // Start the wave from the left bottom of the screen
//     path.moveTo(0, size.height * 0.60 + 20 * sin(animationValue * pi));

//     // Create two quadratic bezier curves with dynamic control points influenced by animationValue
//     path.quadraticBezierTo(
//         size.width * 0.25,
//         size.height *
//             (0.60 +
//                 0.10 *
//                     cos(animationValue * pi)), // Dynamic height for animation
//         size.width * 0.5,
//         size.height * 0.60 +
//             20 * sin(animationValue * pi + pi / 2)); // Shift phase by pi/2

//     path.quadraticBezierTo(
//         size.width * 0.75,
//         size.height *
//             (0.60 -
//                 0.10 *
//                     cos(animationValue * pi)), // Dynamic height for animation
//         size.width,
//         size.height * 0.60 + 20 * sin(animationValue * pi));

//     // Complete the path to fill the bottom part of the screen
//     path.lineTo(size.width, size.height);
//     path.lineTo(0, size.height);

//     canvas.drawPath(path, paint);
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) {
//     // Repaint only if the animation value changes
//     return oldDelegate is WavePainter &&
//         oldDelegate.animationValue != animationValue;
//   }
// }

class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  // Animation<double>? _animation;

  final _findUniversity = TextEditingController();

  bool isOnLogin = false;

  List<String> universities = <String>[];
  List<String> filterUniversities = [];
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration:
          const Duration(seconds: 15), // Adjusted from 2 seconds to 10 seconds
      vsync: this,
    )..repeat(reverse: false);

    // _animation = Tween<double>(begin: 0, end: 2 * pi).animate(_controller!)
    //   ..addListener(() {
    //     setState(() {});
    //   });

    Database.getUniversities().then((List<UniversityModel> universityLists) {
      universities =
          universityLists.map((university) => university.name).toList();
      filterUniversities = universities;
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
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
        body: Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color.fromRGBO(95, 10, 215, 1),
            Color.fromRGBO(7, 156, 182, 1),
          ],
        ),
      ),
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
                      child: Image.asset("assets/images/app/introimage.png")))),
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
                  margin: const EdgeInsets.only(
                      left: 20,
                      top: 20,
                      right: 20), // Adjusted margin to include right
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Welcome to",
                          style: GoogleFonts.ubuntu(
                            fontSize: 30,
                            fontWeight: FontWeight.w600,
                            color: const Color.fromARGB(255, 255, 255, 255),
                          )),
                      const SizedBox(height: 20),
                      Text("Noteloom",
                          style: GoogleFonts.cinzel(
                            fontSize: 50,
                            fontWeight: FontWeight.w600,
                            color: const Color.fromARGB(255, 255, 255, 255),
                          )),
                      const SizedBox(height: 20),
                      Text("Connect, share, and conquer \n your classes.",
                          style: GoogleFonts.ubuntu(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: const Color.fromARGB(255, 255, 255, 255),
                          )),
                      const SizedBox(height: 17),
                      
                      Container(
                        height: 35, // Set the height of the button
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(15), // Rounded corners
                          gradient: const LinearGradient(
                            colors: [
                              Color.fromRGBO(95, 10, 215, 1), // Start color of the gradient
                              Color.fromRGBO(7, 156, 182, 1) // End color of the gradient
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(
                                  1), // Shadow color with some transparency
                              spreadRadius: 0,
                              blurRadius: 4,
                              offset: const Offset(
                                  0, 4), // changes position of shadow
                            ),
                          ],
                        ),
                        child: TextButton.icon(
                          icon: const Icon(Icons.login,
                              color: Colors.white), // Adding the login icon
                          label: Text("Get Started",
                              style: GoogleFonts.ubuntu(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              )),
                          onPressed: () {
                            setState(() {
                              isOnLogin = !isOnLogin;
                            });
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white, // Text color
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          AnimatedPositioned(
            bottom: isOnLogin ? 0 : -MediaQuery.of(context).size.height * 0.7,
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
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: CustomPaint(
                      // painter: WavePainter(_animation!.value),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 40),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Check if your school is\navailable:",
                              style: GoogleFonts.montserrat(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            TextField(
                              controller: _findUniversity,
                              onChanged: (value) {
                                _displayUniversities(value);
                              },
                              decoration: const InputDecoration(
                                labelText:
                                    "Search University", // Placeholder text
                                labelStyle: TextStyle(
                                    color: Colors
                                        .grey), // Style for the placeholder
                                enabledBorder: OutlineInputBorder(
                                  // Normal border
                                  borderSide: BorderSide(
                                      color: Colors.blue, width: 1.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  // Border when TextField is focused
                                  borderSide: BorderSide(
                                      color: Colors.green, width: 2.0),
                                ),
                                prefixIcon: Icon(Icons.search,
                                    color:
                                        Colors.grey), // Icon on the left side
                              ),
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
                                              title: Text(
                                                university,
                                                style: GoogleFonts.ubuntu(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            );
                                          },
                                        )
                                      : Container()),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            
                            Center(
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color.fromRGBO(95, 10, 215, 1), // Adjusted to match background start color
                                      Color.fromRGBO(7, 156, 182, 1) // Adjusted to match background end color
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.5),
                                      spreadRadius: 2,
                                      blurRadius: 4,
                                      offset: const Offset(
                                          0, 4), // changes position of shadow
                                    ),
                                  ],
                                  borderRadius: BorderRadius.circular(
                                      30), // Adjust border radius to match your design
                                ),
                                child: TextButton.icon(
                                  icon: const Icon(Icons.person, color: Colors.white), // Adding the person icon
                                  label: Text("Log in",
                                      style: GoogleFonts.ubuntu(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      )),
                                  onPressed: () {
                                    if (universities.contains(_findUniversity.text)) {
                                      GoRouter.of(context).goNamed("login", pathParameters: {
                                        "universityName": _findUniversity.text
                                      });
                                    }
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.white, // Text color
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      )),
                ),
              ),
            ),
          ),
        ],
      ),
    ));
  }
}
