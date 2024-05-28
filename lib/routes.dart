import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:school_app/src/pages/addsubject.dart';
import 'package:school_app/src/pages/home/addnote/layout.dart';
import 'package:school_app/src/pages/home/profile/profile.dart';
import 'package:school_app/src/pages/info%20pages/note/edit.dart';
import 'package:school_app/src/pages/info%20pages/note/notepage.dart';
import 'package:school_app/src/pages/info%20pages/subject/chat_page.dart';
import 'package:school_app/src/pages/info%20pages/subject/main2.dart';
import 'package:school_app/src/pages/info%20pages/subject/selectnote.dart';
import 'package:school_app/src/pages/info%20pages/subject/subjectnotes.dart';
import 'package:school_app/src/pages/login.dart';
import 'package:school_app/src/pages/not_found.dart';
import 'package:school_app/src/pages/home/home_layout.dart';
import 'package:school_app/src/pages/settings/settings.dart';
import 'package:school_app/src/utils/firebase.dart';
import 'package:school_app/src/pages/intro_page.dart';
import 'package:school_app/src/pages/setup.dart';
import 'package:school_app/src/utils/sharedprefs.dart';

class Routes {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static final routes = GoRouter(
      debugLogDiagnostics: true,
      navigatorKey: _rootNavigatorKey,
      routes: [
        GoRoute(
          name: "intro",
          path: "/",
          pageBuilder: (_, __) => CustomTransitionPage(
            key: __.pageKey,
            transitionDuration: const Duration(milliseconds: 1000),
            child: const IntroPage(),
            transitionsBuilder: (_, anim, __, child) =>
                fadeTransition(_, anim, __, child),
          ),
        ),
        GoRoute(
          name: "login",
          path: "/login",
          pageBuilder: (context, state) {
            return CustomTransitionPage(
              key: state.pageKey,
              transitionDuration: const Duration(milliseconds: 800),
              reverseTransitionDuration: const Duration(milliseconds: 800),
              child: const Login(
              ),
              transitionsBuilder: (_, __, ___, child) =>
                  fromBottomTransition(_, __, __, child),
            );
          },
        ),
        GoRoute(
          name: "setup",
          path: "/setup",
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            transitionDuration: const Duration(milliseconds: 500),
            reverseTransitionDuration: const Duration(milliseconds: 500),
            child: const Setup(),
            transitionsBuilder: (_, __, ___, child) =>
                fromRightTransition(_, __, __, child),
          ),
        ),
        GoRoute(
          path: "/home",
          pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              transitionDuration: const Duration(milliseconds: 1000),
              child: const PageWithDrawer(),
              transitionsBuilder: (_, anim, __, child) =>
                  fadeTransition(_, anim, __, child)),
          routes: [
            GoRoute(
              path: "profile",
              builder: (context, state) => const ProfilePage(),
            ),
            GoRoute(
              path: "settings",
              pageBuilder: (context, state) => CustomTransitionPage(
                key: state.pageKey,
                transitionDuration: const Duration(milliseconds: 500),
                child: const SettingsPage(),
                transitionsBuilder: (_, anim, __, child) =>
                    fromRightTransition(_, anim, __, child),
                maintainState: true,
              ),
            ),
          ],
        ),
        GoRoute(
          name: "addnote",
          path: "/addnote",
          pageBuilder: (context, state) => CustomTransitionPage(
              transitionDuration: const Duration(milliseconds: 500),
              child: const AddNoteLayout(),
              transitionsBuilder: (_, anim, __, child) =>
                  fromBottomTransition(_, anim, __, child)),
          // routes: [
          //   GoRoute(
          //     path: "selectsubject",
          //     builder: (context, state) => const SelectSubjectPage(),
          //   ),
          // ],
        ),
        GoRoute(
          name: "addsubject",
          path: "/addSubject",
          builder: (context, state) => const AddSubject(),
        ),

        // notes proper

        GoRoute(
          path: "/note/:id",
          name: "notepage",
          pageBuilder: (context, state) {
            String id = state.pathParameters['id']!;
            return CustomTransitionPage(
              key: state.pageKey,
              transitionDuration: const Duration(milliseconds: 500),
              child: NotePage(
                id: id,
              ),
              transitionsBuilder: (_, anim, __, child) =>
                  fromRightTransition(_, anim, __, child),
            );
          },
          routes: [
            GoRoute(
              path: "editNote",
              name: "editNote",
              builder: (context, state) => EditNotePage(
                noteId: state.pathParameters['id']!,
              ),
            )
          ],
        ),
        GoRoute(
          path: "/subject/:id",
          pageBuilder: (context, state) {
            String id = state.pathParameters['id']!;
            return CustomTransitionPage(
                key: state.pageKey,
                transitionDuration: const Duration(milliseconds: 500),
                child: SubjectPage(
                  subjectId: id,
                ),
                transitionsBuilder: (_, anim, __, child) =>
                    fromRightTransition(_, anim, __, child));
          },
          routes: [
            GoRoute(
              path: "subjectnotes",
              name: "subjectNotes",
              builder: (context, state) {
                return SubjectNotesPage(subjectId: state.pathParameters['id']!);
              },
            ),
            GoRoute(
                path: "discussions",
                name: "discussions",
                builder: (context, state) =>
                    ChatPage(subjectId: state.pathParameters["id"]!),
                routes: [
                  GoRoute(
                      path: "selectNote",
                      name: "selectNote",
                      builder: (context, state) {
                        return SelectNotePage(
                          subjectId: state.pathParameters['id']!,
                        );
                      })
                ])
          ],
        )
      ],
      errorBuilder: (context, state) {
        if (kDebugMode) print(state.error);
        return NotFoundPage(
          error: state.error!,
        );
      },
      redirect: (context, state) {
        bool isOnPath(String path) {
          return state.matchedLocation.startsWith(path);
        }

        if (isOnPath("/setup")) {
          if (Auth.currentUser == null) {
            return "/";
          }

          return SharedPrefs.getUserData().then((user) {
            if (user != null) {
              return "/home";
            } else {
              return null;
            }
          });
        }

        return null;
      });
}

SlideTransition fromRightTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child) {
  return SlideTransition(
    position: animation.drive(
      Tween(begin: const Offset(1, 0), end: Offset.zero).chain(
        CurveTween(curve: Curves.easeInOutQuad),
      ),
    ),
    child: child,
  );
}

SlideTransition fromBottomTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child) {
  return SlideTransition(
    position: animation.drive(
      Tween(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).chain(
        CurveTween(curve: Curves.easeInOutQuad),
      ),
    ),
    child: child,
  );
}

FadeTransition fadeTransition(BuildContext context, Animation<double> animation,
    Animation<double> secondaryAnimation, Widget child) {
  return FadeTransition(
    opacity: Tween(
      begin: 0.toDouble(),
      end: 1.toDouble(),
    ).animate(
      CurvedAnimation(parent: animation, curve: Curves.ease),
    ),
    child: child,
  );
}
