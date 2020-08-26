import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_starter_v2/middlewares/auth_middleware.dart';
import 'package:flutter_starter_v2/middlewares/reg_middleware.dart';
import 'package:flutter_starter_v2/reducers/app_reducer.dart';
import 'package:flutter_starter_v2/routes.dart';
import 'package:redux/redux.dart';
import 'models/app_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_starter_v2/keys/keys.dart';
import 'package:camera/camera.dart';
import 'package:redux_logging/redux_logging.dart';

List<CameraDescription> cameras;
DocumentSnapshot raid;
String token;

Future<Null> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  cameras = await availableCameras();
  User user;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = new GoogleSignIn();
  try {
    GoogleSignInAccount googleUser = await _googleSignIn.signInSilently();
    GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    GoogleAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    UserCredential userCred = await _auth.signInWithCredential(credential);
    user = userCred.user;
    token = "Bearer " + await user.getIdToken();
    DocumentReference mydb = _db.collection('users').doc(user.uid);
    raid = await mydb.get();
    if (!raid.exists) {
      Map<String, String> data = <String, String>{
        "displayName": user.displayName,
        "email": user.email,
        "number": user.phoneNumber,
        "photoURL": user.photoURL,
        "uid": user.uid
      };
      await mydb.set(data);
      raid = await mydb.get();
      AppState initialState = new AppState(isLoading: false, currentUser: raid);
      final store = new Store<AppState>(
        appReducer,
        initialState: initialState ?? new AppState(),
        distinct: true,
        middleware: []
          ..addAll(createAuthMiddleware())
          ..addAll(createRegMiddleware())
          ..add(new LoggingMiddleware.printer()),
      );
      runApp(NewUserApp(
        store: store,
      ));
    } else if (raid.data()['uname'] == null || raid.data()['uname'] == "") {
      AppState initialState = new AppState(isLoading: false, currentUser: raid);
      final store = new Store<AppState>(
        appReducer,
        initialState: initialState ?? new AppState(),
        distinct: true,
        middleware: []
          ..addAll(createAuthMiddleware())
          ..addAll(createRegMiddleware())
          ..add(new LoggingMiddleware.printer()),
      );
      runApp(NewUserApp(
        store: store,
      ));
    } else {
      // returning user
      AppState initialState = new AppState(isLoading: false, currentUser: raid);
      final store = new Store<AppState>(
        appReducer,
        initialState: initialState ?? new AppState(),
        distinct: true,
        middleware: []
          ..addAll(createAuthMiddleware())
          ..addAll(createRegMiddleware())
          ..add(new LoggingMiddleware.printer()),
      );
      runApp(ReturningUserApp(
        store: store,
      ));
    }
  } catch (error) {
    final store = new Store<AppState>(
      appReducer,
      initialState: new AppState(),
      distinct: true,
      middleware: []
        ..addAll(createAuthMiddleware())
        ..addAll(createRegMiddleware())
        ..add(new LoggingMiddleware.printer()),
    );
    runApp(MainApp(
      store: store,
    ));
  }
}

class MainApp extends StatelessWidget {
  final Store<AppState> store;

  MainApp({this.store});

  @override
  Widget build(BuildContext context) {
    return new StoreProvider(
      store: store,
      child: new MaterialApp(
        navigatorKey: AppKeys.navKey,
        debugShowCheckedModeBanner: false,
        routes: getRoutes(context, store),
        initialRoute: '/login',
      ),
    );
  }
}

class NewUserApp extends StatelessWidget {
  final Store<AppState> store;

  NewUserApp({this.store});

  @override
  Widget build(BuildContext context) {
    return new StoreProvider(
      store: store,
      child: new MaterialApp(
        navigatorKey: AppKeys.navKey,
        debugShowCheckedModeBanner: false,
        routes: getRoutes(context, store),
        initialRoute: '/register',
      ),
    );
  }
}

class ReturningUserApp extends StatelessWidget {
  final Store<AppState> store;

  ReturningUserApp({this.store});

  @override
  Widget build(BuildContext context) {
    return new StoreProvider(
      store: store,
      child: new MaterialApp(
        navigatorKey: AppKeys.navKey,
        debugShowCheckedModeBanner: false,
        routes: getRoutes(context, store),
        initialRoute: '/',
      ),
    );
  }
}
