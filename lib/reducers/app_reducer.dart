import 'package:flutter_starter_v2/models/app_state.dart';
import 'package:flutter_starter_v2/reducers/update_reducer.dart';
import 'package:flutter_starter_v2/reducers/navigation_reducer.dart';

AppState appReducer(state, action) {
  return new AppState(
      isLoading: false,
      currentUser: updateReducer(state.currentUser, action),
      navigationState: navigationReducer(state.navigationState, action));
}
