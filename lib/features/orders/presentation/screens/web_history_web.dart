// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html show window;

void replaceHistoryWithHome() {
  // Preserve Flutter engine's internal state (contains serialCount)
  // but change the URL so browser back navigates to home.
  final state = html.window.history.state;
  html.window.history.replaceState(state, '', '/#/');
}
