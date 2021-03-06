library routes;

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_starter_v2/pages/auth_page.dart';
import 'package:flutter_starter_v2/pages/loading_page.dart';
import 'package:flutter_starter_v2/pages/register_page.dart';
import 'package:flutter_starter_v2/pages/home_page.dart';
import 'models/app_state.dart';
import 'package:flutter_starter_v2/pages/update_page.dart';

Map<String, WidgetBuilder> getRoutes(context, store) {
  return {
    '/': (BuildContext context) => new StoreBuilder<AppState>(
          builder: (context, store) {
            return HomePage("Home");
          },
        ),
    '/update': (BuildContext context) => new StoreBuilder<AppState>(
          builder: (context, store) {
            return UpdatePage("Update Profile");
          },
        ),
    '/register': (BuildContext context) => new StoreBuilder<AppState>(
          builder: (context, store) {
            return RegisterPage("Register");
          },
        ),
    '/login': (BuildContext context) => new StoreBuilder<AppState>(
          builder: (context, store) {
            return AuthPage();
          },
        ),
    '/loading': (BuildContext context) => new StoreBuilder<AppState>(
          builder: (context, store) {
            return LoadingPage();
          },
        ),
  };
}
