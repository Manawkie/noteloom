import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:school_app/src/pages/home/addnote/layout.dart';
import 'package:school_app/src/pages/home/addnote/selectsubject.dart';
import 'package:school_app/src/pages/home/profile/profile.dart';
import 'package:school_app/src/pages/info%20pages/note/notepage.dart';
import 'package:school_app/src/pages/login.dart';
import 'package:school_app/src/pages/not_found.dart';
import 'package:school_app/src/pages/home/home_layout.dart';
import 'package:school_app/src/pages/settings/settings.dart';
import 'package:school_app/src/utils/firebase.dart';
import 'package:school_app/src/pages/intro_page.dart';
import 'package:school_app/src/pages/setup.dart';

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
                    fadeTransition(_, anim, __, child))),
        GoRoute(
            name: "login",
            path: "/login/:universityName",
            pageBuilder: (context, state) {
              String universityName = state.pathParameters['universityName']!;
              return CustomTransitionPage(
                  key: state.pageKey,
                  transitionDuration: const Duration(milliseconds: 800),
                  reverseTransitionDuration: const Duration(milliseconds: 800),
                  child: Login(
                    universityName: universityName,
                  ),
                  transitionsBuilder: (_, __, ___, child) =>
                      fromBottomTransition(_, __, __, child));
            }),
        GoRoute(
            name: "setup",
            path: "/setup",
            pageBuilder: (context, state) => CustomTransitionPage(
                key: state.pageKey,
                transitionDuration: const Duration(milliseconds: 500),
                reverseTransitionDuration: const Duration(milliseconds: 500),
                child: const Setup(),
                transitionsBuilder: (_, __, ___, child) =>
                    fromRightTransition(_, __, __, child))),
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
            ]),
        GoRoute(
            name: "addnote",
            path: "/addnote",
            pageBuilder: (context, state) => CustomTransitionPage(
                transitionDuration: const Duration(milliseconds: 500),
                child: const AddNoteLayout(),
                transitionsBuilder: (_, anim, __, child) =>
                    fromBottomTransition(_, anim, __, child)),
            routes: [
              GoRoute(
                path: "selectsubject",
                builder: (context, state) => const SelectSubjectPage(),
              )
            ]),

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
        ),
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

          return Database.getUser().then((user) {
            if (user != null) {
              return "/home";
            }
            return null;
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
