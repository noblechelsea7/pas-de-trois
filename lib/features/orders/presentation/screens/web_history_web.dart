// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html show window;

void replaceHistoryWithHome() {
  html.window.history.replaceState(null, '', '/#/');
}
