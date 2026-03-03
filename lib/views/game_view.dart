import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app_config.dart';
import '../widgets/starry_background.dart';
import '../game/one_to_fifty_game.dart';
import '../resources/asset_paths.dart';
import '../resources/sound_manager.dart';
import '../services/game_settings.dart';
import '../services/in_app_review_service.dart';

/// 게임 화면. OneToFiftyGame을 마운트하고 오버레이를 관리한다.
class GameView extends StatefulWidget {
  const GameView({super.key, this.gameMode = 0});

  final int gameMode;

  @override
  State<GameView> createState() => _GameViewState();
}

class _GameViewState extends State<GameView> {
  /// 게임 BGM 재생 시작.
  @override
  void initState() {
    super.initState();
    SoundManager.playBgm(AssetPaths.bgmMain);
  }

  /// 모바일 기준 크기. 웹에서는 이 비율로 중앙 배치.
  static const double _mobileRefW = 390.0;
  static const double _mobileRefH = 750.0;

  /// GameWidget에 OneToFiftyGame 마운트. 웹은 모바일 비율로 중앙 배치.
  @override
  Widget build(BuildContext context) {
    final safeTop = MediaQuery.of(context).padding.top;
    final gameWidget = GameWidget<OneToFiftyGame>.controlled(
      gameFactory: () => OneToFiftyGame(
        gameMode: widget.gameMode,
        safeAreaTop: kIsWeb ? 0 : safeTop,
      ),
      overlayBuilderMap: {
        'Countdown': _buildCountdown,
        'PauseMenu': _buildPauseMenu,
        'Clear': _buildClearScreen,
        'PauseButton': _buildPauseButton,
      },
      initialActiveOverlays: const ['Countdown', 'PauseButton'],
    );

    if (kIsWeb) {
      return Scaffold(
        body: Stack(
          children: [
            Positioned.fill(child: StarryBackground()),
            Center(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final scale = (constraints.maxWidth / _mobileRefW)
                      .clamp(0.0, constraints.maxHeight / _mobileRefH);
                  final gameW = _mobileRefW * scale;
                  final gameH = _mobileRefH * scale;
                  return SizedBox(
                    width: gameW,
                    height: gameH,
                    child: gameWidget,
                  );
                },
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(body: gameWidget);
  }

  /// 3, 2, 1, Start 카운트다운 오버레이
  Widget _buildCountdown(BuildContext context, OneToFiftyGame game) {
    game.setLocaleStrings({
      'timeScore': context.tr('timeScore'),
      'hint': context.tr('hint'),
      'bestScore': context.tr('bestScore'),
    });
    return _CountdownOverlay(game: game);
  }

  /// 일시정지 오버레이: PAUSED, 볼륨·음소거, 다시하기·나가기.
  Widget _buildPauseMenu(BuildContext context, OneToFiftyGame game) {
    return _PauseMenuOverlay(game: game);
  }

  /// 일시정지 버튼 오버레이. Flutter 위젯으로 렌더 → 웹 리사이즈 시 문제 없음.
  Widget _buildPauseButton(BuildContext context, OneToFiftyGame game) {
    game.setLocaleStrings({
      'timeScore': context.tr('timeScore'),
      'hint': context.tr('hint'),
      'bestScore': context.tr('bestScore'),
    });
    return ListenableBuilder(
      listenable: game.resizeNotifier,
      builder: (context, _) {
        final ref = game.layoutRef;
        final scale = game.hudScale;
        final contentLeft = (game.size.x - ref) / 2;
        final btnSize = scale * 0.5;
        final btnY = game.hintCenterY - btnSize / 2;

        return Stack(
          children: [
            Positioned.fill(child: IgnorePointer(child: SizedBox.shrink())),
            Positioned(
              left: contentLeft + 12,
              top: btnY,
              child: GestureDetector(
                onTap: () {
                  SoundManager.unlockForWeb();
                  game.pauseGame();
                },
                child: _PauseButtonWidget(size: btnSize),
              ),
            ),
          ],
        );
      },
    );
  }

  /// 게임 클리어 오버레이: Clear! 텍스트, 결과 시간, 다시하기·나가기 버튼.
  /// 첫 클리어 시 인앱 리뷰 팝업 요청.
  Widget _buildClearScreen(BuildContext context, OneToFiftyGame game) {
    return _ClearScreenOverlay(game: game);
  }
}

/// 클리어 화면. 첫 표시 시 2초 후 인앱 리뷰 요청.
class _ClearScreenOverlay extends StatefulWidget {
  const _ClearScreenOverlay({required this.game});
  final OneToFiftyGame game;

  @override
  State<_ClearScreenOverlay> createState() => _ClearScreenOverlayState();
}

class _ClearScreenOverlayState extends State<_ClearScreenOverlay> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) InAppReviewService.maybeRequestReviewAfterFirstClear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final game = widget.game;
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 36),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.amber.withValues(alpha: 0.5), width: 3),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.6),
              blurRadius: 24,
              spreadRadius: 4,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 20,
          children: [
            Text(
              context.tr('clear'),
              style: TextStyle(
                fontFamily: AssetPaths.fontAngduIpsul140,
                color: Colors.amber,
                fontSize: 64,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(color: Colors.black45, offset: Offset(2, 2), blurRadius: 4),
                ],
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  context.tr('gameResult'),
                  style: TextStyle(
                    fontFamily: AssetPaths.fontAngduIpsul140,
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  game.formattedTime,
                  style: const TextStyle(
                    fontFamily: AssetPaths.fontAngduIpsul140,
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (game.formattedBestScore != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      context.tr('bestScore'),
                      style: TextStyle(
                        fontFamily: AssetPaths.fontAngduIpsul140,
                        color: Colors.amber,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      game.formattedBestScore!,
                      style: const TextStyle(
                        fontFamily: AssetPaths.fontAngduIpsul140,
                        color: Colors.amber,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            SizedBox(
              width: 240,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(
                    fontFamily: AssetPaths.fontAngduIpsul140,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                onPressed: () {
                  SoundManager.unlockForWeb();
                  SoundManager.playSfx(AssetPaths.sfxBtnSnd);
                  game.overlays.remove('Clear');
                  game.prepareAndCountdown();
                },
                child: Text(context.tr('retry')),
              ),
            ),
            SizedBox(
              width: 240,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.redAccent,
                  textStyle: const TextStyle(
                    fontFamily: AssetPaths.fontAngduIpsul140,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                onPressed: () {
                  SoundManager.unlockForWeb();
                  SoundManager.playSfx(AssetPaths.sfxBtnSnd);
                  context.go(RoutePaths.title);
                },
                child: Text(context.tr('exit')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 일시정지 오버레이. 볼륨 조절·음소거, 계속하기·나가기 버튼.
class _PauseMenuOverlay extends StatefulWidget {
  const _PauseMenuOverlay({required this.game});
  final OneToFiftyGame game;

  @override
  State<_PauseMenuOverlay> createState() => _PauseMenuOverlayState();
}

class _PauseMenuOverlayState extends State<_PauseMenuOverlay> {
  late double _bgmVolume;
  late double _sfxVolume;
  late bool _bgmMuted;
  late bool _sfxMuted;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    setState(() {
      _bgmVolume = GameSettings.bgmVolume;
      _sfxVolume = GameSettings.sfxVolume;
      _bgmMuted = GameSettings.bgmMuted;
      _sfxMuted = GameSettings.sfxMuted;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white24, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.6),
                blurRadius: 24,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.tr('paused'),
                style: TextStyle(
                  fontFamily: AssetPaths.fontAngduIpsul140,
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black45,
                      offset: Offset(2, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                context.tr('bgm'),
                style: TextStyle(
                  fontFamily: AssetPaths.fontAngduIpsul140,
                  fontSize: 20,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 12,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                        overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
                        trackShape: const RoundedRectSliderTrackShape(),
                      ),
                      child: Slider(
                        value: _bgmMuted ? 0.0 : _bgmVolume,
                        onChanged: _bgmMuted
                            ? null
                            : (v) {
                                setState(() {
                                  _bgmVolume = v;
                                  GameSettings.bgmVolume = v;
                                  SoundManager.applyBgmVolume();
                                });
                              },
                      ),
                    ),
                  ),
                  Icon(
                    _bgmMuted ? Icons.volume_off : Icons.volume_up,
                    color: Colors.white70,
                    size: 24,
                  ),
                  const SizedBox(width: 4),
                  Switch(
                    value: _bgmMuted,
                    onChanged: (v) {
                      setState(() {
                        _bgmMuted = v;
                        GameSettings.bgmMuted = v;
                        if (v) {
                          SoundManager.pauseBgm();
                        } else {
                          SoundManager.playBgmIfUnmuted();
                        }
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                context.tr('sfx'),
                style: TextStyle(
                  fontFamily: AssetPaths.fontAngduIpsul140,
                  fontSize: 20,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 12,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                        overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
                        trackShape: const RoundedRectSliderTrackShape(),
                      ),
                      child: Slider(
                        value: _sfxMuted ? 0.0 : _sfxVolume,
                        onChanged: _sfxMuted
                            ? null
                            : (v) {
                                setState(() {
                                  _sfxVolume = v;
                                  GameSettings.sfxVolume = v;
                                });
                              },
                      ),
                    ),
                  ),
                  Icon(
                    _sfxMuted ? Icons.volume_off : Icons.volume_up,
                    color: Colors.white70,
                    size: 24,
                  ),
                  const SizedBox(width: 4),
                  Switch(
                    value: _sfxMuted,
                    onChanged: (v) {
                      setState(() {
                        _sfxMuted = v;
                        GameSettings.sfxMuted = v;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: 220,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(
                      fontFamily: AssetPaths.fontAngduIpsul140,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  onPressed: () {
                    SoundManager.unlockForWeb();
                    SoundManager.playSfx(AssetPaths.sfxBtnSnd);
                    SoundManager.resumeBgm(onlyIfCurrent: AssetPaths.bgmMain);
                    widget.game.resumeEngine();
                    widget.game.overlays.remove('PauseMenu');
                    widget.game.overlays.add('PauseButton');
                    widget.game.isPlaying = true;
                  },
                  child: Text(context.tr('continueGame')),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 220,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.redAccent,
                    textStyle: const TextStyle(
                      fontFamily: AssetPaths.fontAngduIpsul140,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  onPressed: () {
                    SoundManager.unlockForWeb();
                    SoundManager.playSfx(AssetPaths.sfxBtnSnd);
                    context.go(RoutePaths.title);
                  },
                  child: Text(context.tr('exit')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 카운트다운 오버레이 위젯.
/// StatefulWidget으로 3 -> 2 -> 1 -> Start 순서를 제어한다.
class _CountdownOverlay extends StatefulWidget {
  const _CountdownOverlay({required this.game});
  final OneToFiftyGame game;

  @override
  State<_CountdownOverlay> createState() => _CountdownOverlayState();
}

class _CountdownOverlayState extends State<_CountdownOverlay>
    with TickerProviderStateMixin {
  int _count = -1;
  String _displayText = '';
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  /// 스케일 애니메이션 설정 후 카운트다운 시작.
  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    // 0.2 → 1.0 스케일, easeOutBack으로 튀어나오는 효과.
    _scaleAnimation = Tween<double>(begin: 0.2, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOutBack),
    );

    _startCountdown();
  }

  /// 500ms 대기 후 3→2→1(각 1초) → Start(800ms) → 게임 시작. 각 단계마다 사운드 재생.
  Future<void> _startCountdown() async {
    // 오버레이 표시 후 500ms 대기 → 3,2,1 각 1초 → Start 800ms → 게임 시작.
    await Future<void>.delayed(const Duration(milliseconds: 500));

    for (var i = 3; i >= 1; i--) {
      if (!mounted) return;
      SoundManager.playSfx(AssetPaths.sfxTimeTic);
      setState(() {
        _count = i;
        _displayText = '$i';
      });
      _scaleController.forward(from: 0);
      await Future<void>.delayed(const Duration(seconds: 1));
    }

    if (!mounted) return;
    SoundManager.playSfx(AssetPaths.sfxStart);
    setState(() {
      _count = 0;
      _displayText = 'Start';
    });
    _scaleController.forward(from: 0);
    await Future<void>.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;
    widget.game.overlays.remove('Countdown');
    widget.game.startGame();
  }

  /// 애니메이션 컨트롤러 해제.
  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  /// 딤 배경 위에 스케일 애니메이션 적용된 카운트다운 텍스트 표시.
  /// 웹: 탭 시 unlock → BGM 재생 가능.
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: SoundManager.unlockForWeb,
      behavior: HitTestBehavior.opaque,
      child: Container(
        color: Colors.black54,
        child: Center(
          child: AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Text(
                  _displayText,
                  style: TextStyle(
                    fontFamily: AssetPaths.fontAngduIpsul140,
                    color: _count > 0 ? Colors.cyanAccent : Colors.amber,
                    fontSize: _count > 0 ? 120 : 72,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: (_count > 0 ? Colors.cyanAccent : Colors.amber)
                            .withValues(alpha: 0.6),
                        blurRadius: 30,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// 일시정지 버튼 Flutter 위젯. HUD _PauseButton과 동일한 모양.
class _PauseButtonWidget extends StatelessWidget {
  const _PauseButtonWidget({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _PauseButtonPainter(size: size),
      ),
    );
  }
}

class _PauseButtonPainter extends CustomPainter {
  _PauseButtonPainter({required this.size});
  final double size;

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final r = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size, size),
      Radius.circular(size * 0.25),
    );
    canvas.drawRRect(
      r,
      Paint()..color = Colors.white.withValues(alpha: 0.15),
    );

    final barW = size * 0.14;
    final barH = size * 0.45;
    final gap = size * 0.12;
    final cx = size / 2;
    final cy = size / 2;
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx - gap, cy),
          width: barW,
          height: barH,
        ),
        Radius.circular(barW * 0.3),
      ),
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx + gap, cy),
          width: barW,
          height: barH,
        ),
        Radius.circular(barW * 0.3),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _PauseButtonPainter oldDelegate) =>
      oldDelegate.size != size;
}
