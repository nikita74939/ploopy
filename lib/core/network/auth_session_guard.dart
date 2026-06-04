import 'dart:async';

class AuthSessionGuard {
  AuthSessionGuard._();

  static final _controller = StreamController<void>.broadcast();

  static Stream<void> get expiredStream => _controller.stream;

  static void notifyExpired() {
    if (!_controller.isClosed) _controller.add(null);
  }
}
