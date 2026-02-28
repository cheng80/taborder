import 'package:tab_order/game/one_to_fifty_game.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('OneToFiftyGame can be instantiated', () {
    final game = OneToFiftyGame();
    expect(game, isNotNull);
  });
}
