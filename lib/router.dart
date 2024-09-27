import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_log/sign_in/sign_in_page.dart';
import 'package:pet_log/sign_up/sign_up_nickname_page.dart';
import 'package:pet_log/sign_up/sign_up_pet_info_page.dart';
import 'package:pet_log/sign_up/sign_up_select_pet_type_page.dart';

final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => SignInPage(),
    ),
    GoRoute(
      path: '/sign_up',
      builder: (context, state) {
        return SignUpNicknamePage();
      },
      routes: <RouteBase>[
        GoRoute(
          path: 'pet_type',
          builder: (context, state) {
            return SignUpSelectPetTypePage();
          },
          routes: <RouteBase>[
            GoRoute(
              path: 'pet_info',
              builder: (context, state) {
                return SignUpPetInfoPage();
              },
            ),
          ],
        ),
      ],
    ),
  ],
);
