// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html show window;

void replaceHistoryWithHome() {
  final currentState = html.window.history.state;
  if (currentState is Map) {
    // Keep Flutter engine's serialCount (required) but clear GoRouter's
    // route state so browser back reads the URL (/#/) instead of restoring
    // the original route from state.
    final newState = <String, dynamic>{
      'serialCount': currentState['serialCount'],
      'state': null,
    };
    html.window.history.replaceState(newState, '', '/#/');
  } else {
    html.window.history.replaceState(null, '', '/#/');
  }
}
