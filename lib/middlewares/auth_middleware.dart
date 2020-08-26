import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_starter_v2/actions/auth_actions.dart';
import 'package:flutter_starter_v2/models/app_state.dart';
import 'package:redux/redux.dart';
import 'package:flutter_starter_v2/keys/keys.dart';
import 'package:flutter_starter_v2/main.dart';

List<Middleware<AppState>> createAuthMiddleware() {
  final logIn = _createLogInMiddleware();
  final logOut = _createLogOutMiddleware();
  return [
    new TypedMiddleware<AppState, LogIn>(logIn),
    new TypedMiddleware<AppState, LogOut>(logOut),
  ];
}

Middleware<AppState> _createLogInMiddleware() {
  return (Store store, action, NextDispatcher next) async {
    User user;
    final FirebaseFirestore _db = FirebaseFirestore.instance;
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final GoogleSignIn _googleSignIn = new GoogleSignIn();
    final navigatorKey = AppKeys.navKey;
    if (action is LogIn) {
      navigatorKey.currentState.pushReplacementNamed('/loading');
      try {
        GoogleSignInAccount googleUser = await _googleSignIn.signIn();
        GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        UserCredential userCred = await _auth.signInWithCredential(credential);
        user = userCred.user;
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
          store.dispatch(new LogInSuccessful(user: raid));
          navigatorKey.currentState.pushReplacementNamed('/register');
        } else if (raid.data()['uname'] == null || raid.data()['uname'] == "") {
          // returning user
          store.dispatch(new LogInSuccessful(user: raid));
          navigatorKey.currentState.pushReplacementNamed('/register');
        } else if (raid.data()['uname'] != null) {
          store.dispatch(new LogInSuccessful(user: raid));
          navigatorKey.currentState.pushReplacementNamed('/');
        }
      } catch (error) {
        store.dispatch(new LogInFail(error));
        navigatorKey.currentState.pushReplacementNamed('/login');
      }
    }
  };
}

Middleware<AppState> _createLogOutMiddleware() {
  return (Store store, action, NextDispatcher next) async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final GoogleSignIn _googleSignIn = new GoogleSignIn();
    final navigatorKey = AppKeys.navKey;
    if (action is LogOut) {
      try {
        navigatorKey.currentState.pushReplacementNamed('/login');
        await _auth.signOut();
        await _googleSignIn.isSignedIn().then((u) => _googleSignIn.signOut());
        store.dispatch(new LogOutSuccessful());
      } catch (error) {
        store.dispatch(new LogOutFail(error));
      }
    }
  };
}
