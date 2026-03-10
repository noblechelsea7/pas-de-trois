// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html show window;

void replaceHistoryWithHome() {
  final len = html.window.history.length;
  if (len > 1) {
    // Go back to the very first history entry, then replace it with '/#/'.
    // This clears checkout (and any prior SPA entries) from the back stack.
    html.window.onPopState.first.then((_) {
      html.window.history.replaceState(null, '', '/#/');
    });
    html.window.history.go(-(len - 1));
  } else {
    html.window.history.replaceState(null, '', '/#/');
  }
}
