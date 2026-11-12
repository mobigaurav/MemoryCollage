import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

import '../core/theme/tokens.dart';

const _glass = BoxDecoration(
  color: Color(0xF21C1410),
  borderRadius: BorderRadius.all(Radius.circular(16)),
  border: Border.fromBorderSide(BorderSide(color: Color(0x99C4A35A))),
  boxShadow: [
    BoxShadow(color: Color(0x88000000), blurRadius: 12, offset: Offset(0, 4)),
  ],
);

/// One icon on a Shorts rail, or in the row under a regular video. Not a text button.
class MbFilmAction {
  const MbFilmAction({
    required this.icon,
    required this.label,
    this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
}

/// YouTube's phone player, or a Short when [shorts] is set.
/// Tap the picture to show the controls. Set [autoplay] when the screen starts the video itself.
/// Share and save belong in [actions] once. Screens do not add a second row.
class MbFilmPlayer extends StatefulWidget {
  const MbFilmPlayer({
    super.key,
    required this.controller,
    this.actions = const [],
    this.title,
    this.onClose,
    this.shorts = false,
    this.fullscreen = false,
    this.autoplay = false,
  });

  /// Starts with the controls hidden. The screen plays and pauses the video.
  final bool autoplay;

  final VideoPlayerController controller;
  final List<MbFilmAction> actions;
  final String? title;
  final VoidCallback? onClose;

  /// Full-bleed portrait stage: side icons, a bottom bar, tap to play.
  final bool shorts;

  /// True only for the full-screen stage. The in-frame player opens that stage.
  final bool fullscreen;

  @override
  State<MbFilmPlayer> createState() => _MbFilmPlayerState();
}

class _MbFilmPlayerState extends State<MbFilmPlayer> {
  bool _scrubbing = false;
  double _scrubMs = 0;
  bool _chrome = true;
  bool _covered = false;
  bool _wasPlaying = false;
  double _level = 1;
  Timer? _hideTimer;

  VideoPlayerController get _player => widget.controller;

  @override
  void initState() {
    super.initState();
    _chrome = !widget.autoplay;
    _player.addListener(_onTick);
  }

  @override
  void didUpdateWidget(MbFilmPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onTick);
      widget.controller.addListener(_onTick);
    }
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _player.removeListener(_onTick);
    super.dispose();
  }

  void _onTick() {
    final playing = _player.value.isPlaying;
    if (playing && !_wasPlaying) _armHide();
    if (!playing && _wasPlaying) {
      _hideTimer?.cancel();
      _chrome = true;
    }
    _wasPlaying = playing;
    if (mounted && !_scrubbing) setState(() {});
  }

  Future<void> _toggleSound() async {
    final muted = _player.value.volume <= 0.01;
    if (muted) {
      await _player.setVolume(_level <= 0.01 ? 1 : _level);
    } else {
      _level = _player.value.volume;
      await _player.setVolume(0);
    }
    if (mounted) _reveal();
  }

  void _reveal() {
    _hideTimer?.cancel();
    setState(() => _chrome = true);
    _armHide();
  }

  void _armHide() {
    _hideTimer?.cancel();
    if (!_player.value.isPlaying || _scrubbing) return;
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (!mounted || !_player.value.isPlaying || _scrubbing) return;
      setState(() => _chrome = false);
    });
  }

  String _clock(Duration time) {
    final hours = time.inHours;
    final minutes = time.inMinutes.remainder(60);
    final seconds = time.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:$seconds';
    }
    return '$minutes:$seconds';
  }

  Future<void> _toggle() async {
    if (!_player.value.isInitialized) return;
    if (_player.value.isPlaying) {
      await _player.pause();
    } else {
      final end = _player.value.duration;
      if (end > Duration.zero &&
          _player.value.position >= end - const Duration(milliseconds: 200)) {
        await _player.seekTo(Duration.zero);
      }
      await _player.play();
    }
    _reveal();
  }

  Future<void> _skip(int seconds) async {
    if (!_player.value.isInitialized) return;
    final end = _player.value.duration;
    var next = _player.value.position + Duration(seconds: seconds);
    if (next < Duration.zero) next = Duration.zero;
    if (next > end) next = end;
    await _player.seekTo(next);
    _reveal();
  }

  Future<void> _enterFullscreen() async {
    if (widget.fullscreen) {
      Navigator.of(context).pop();
      return;
    }
    setState(() => _covered = true);
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;
    // A Short already fills the page, so its full screen is the plain landscape-ready player.
    await Navigator.of(context, rootNavigator: true).push<void>(
      PageRouteBuilder<void>(
        opaque: true,
        transitionDuration: const Duration(milliseconds: 180),
        pageBuilder: (_, _, _) => _FilmStagePage(
          controller: _player,
          actions: widget.shorts ? const [] : widget.actions,
          title: widget.title,
          shorts: false,
        ),
      ),
    );
    if (mounted) setState(() => _covered = false);
  }

  @override
  Widget build(BuildContext context) {
    final ready = _player.value.isInitialized;
    final ratio = !ready || _player.value.aspectRatio == 0
        ? 9 / 16
        : _player.value.aspectRatio;
    final picture = _covered
        ? const ColoredBox(color: Colors.black)
        : _surface(ready, ratio);

    final framed = widget.fullscreen
        ? picture
        : DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x55301810),
                  blurRadius: 18,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: picture,
            ),
          );

    if (widget.shorts || widget.fullscreen) {
      return ColoredBox(color: Colors.black, child: framed);
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AspectRatio(aspectRatio: ratio, child: framed),
        if (widget.actions.isNotEmpty) _actionRow(),
      ],
    );
  }

  Widget _actionRow() {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          for (final action in widget.actions)
            _RailButton(action: action, compact: true),
        ],
      ),
    );
  }

  Widget _surface(bool ready, double ratio) {
    return ColoredBox(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (ready)
            widget.shorts ? _shortsPicture(ratio) : Center(
              child: AspectRatio(
                aspectRatio: ratio,
                child: VideoPlayer(_player),
              ),
            )
          else
            const Center(child: CircularProgressIndicator(color: Colors.white)),
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                if (_chrome) {
                  setState(() => _chrome = false);
                } else {
                  _reveal();
                }
              },
              onDoubleTapDown: (details) {
                final width = context.size?.width ?? 0;
                if (width <= 0) return;
                _skip(details.localPosition.dx < width / 2 ? -10 : 10);
              },
            ),
          ),
          if (widget.shorts) Positioned.fill(child: _shortsChrome(ready)),
          if (!widget.shorts && _chrome) Positioned.fill(child: _controls(ready)),
          if (_chrome)
            Positioned(
              left: 8,
              right: 8,
              bottom: 8 +
                  ((widget.shorts || widget.fullscreen)
                      ? MediaQuery.viewPaddingOf(context).bottom
                      : 0),
              child: _seekBar(ready),
            )
          else if (ready)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: IgnorePointer(child: _progressLine()),
            ),
        ],
      ),
    );
  }

  Widget _progressLine() {
    final total = _player.value.duration.inMilliseconds;
    final at = _player.value.position.inMilliseconds;
    final fraction = total <= 0 ? 0.0 : (at / total).clamp(0.0, 1.0).toDouble();
    return SizedBox(
      height: 3,
      child: Align(
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: fraction,
          heightFactor: 1,
          child: const ColoredBox(color: MbTokens.foil),
        ),
      ),
    );
  }

  Widget _seekBar(bool ready) {
    final duration = ready ? _player.value.duration : Duration.zero;
    final durationMs = duration.inMilliseconds.toDouble();
    final positionMs = ready ? _player.value.position.inMilliseconds.toDouble() : 0.0;
    final shown = _scrubbing ? _scrubMs : positionMs.clamp(0, durationMs);
    final volume = ready ? _player.value.volume.clamp(0, 1).toDouble() : 1.0;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xF21C1410),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x99C4A35A)),
        boxShadow: const [
          BoxShadow(color: Color(0x88000000), blurRadius: 14, offset: Offset(0, 4)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 10, right: 2),
        child: Row(
          children: [
            Text(
              _clock(Duration(milliseconds: shown.round())),
              style: const TextStyle(
                color: MbTokens.cream,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 4,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                  activeTrackColor: MbTokens.foil,
                  inactiveTrackColor: const Color(0x66FAF4E8),
                  thumbColor: MbTokens.cream,
                ),
                child: Slider(
                  value: shown.clamp(0, durationMs).toDouble(),
                  max: durationMs <= 0 ? 1 : durationMs,
                  onChangeStart: ready
                      ? (value) {
                          _hideTimer?.cancel();
                          setState(() {
                            _scrubbing = true;
                            _scrubMs = value;
                          });
                        }
                      : null,
                  onChanged: ready ? (value) => setState(() => _scrubMs = value) : null,
                  onChangeEnd: ready
                      ? (value) async {
                          await _player.seekTo(Duration(milliseconds: value.round()));
                          if (!mounted) return;
                          setState(() => _scrubbing = false);
                          _armHide();
                        }
                      : null,
                ),
              ),
            ),
            Text(
              _clock(duration),
              style: const TextStyle(
                color: MbTokens.cream,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            IconButton(
              tooltip: 'Sound',
              visualDensity: VisualDensity.compact,
              onPressed: _toggleSound,
              icon: Icon(
                volume <= 0.01 ? Icons.volume_off : Icons.volume_up,
                color: MbTokens.cream,
                size: 22,
              ),
            ),
            IconButton(
              tooltip: widget.fullscreen ? 'Leave full screen' : 'Full screen',
              visualDensity: VisualDensity.compact,
              onPressed: ready ? _enterFullscreen : null,
              icon: Icon(
                widget.fullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
                color: MbTokens.cream,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _shortsPicture(double ratio) {
    final size = _player.value.size;
    if (size.width < 2 || size.height < 2) {
      return Center(
        child: AspectRatio(aspectRatio: ratio, child: VideoPlayer(_player)),
      );
    }
    return FittedBox(
      fit: ratio < 1 ? BoxFit.cover : BoxFit.contain,
      child: SizedBox(
        width: size.width,
        height: size.height,
        child: VideoPlayer(_player),
      ),
    );
  }

  Widget _shortsChrome(bool ready) {
    final playing = ready && _player.value.isPlaying;
    return Stack(
      fit: StackFit.expand,
      children: [
        if (_chrome)
          Center(child: _PlayButton(playing: playing, onTap: ready ? _toggle : null)),
        SafeArea(
          child: Stack(
            children: [
              if (widget.onClose != null)
                Align(
                  alignment: Alignment.topLeft,
                  child: _GlassIcon(
                    tooltip: 'Close',
                    icon: Icons.close,
                    onPressed: widget.onClose,
                  ),
                ),
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 8, bottom: 96),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (final action in widget.actions) _RailButton(action: action),
                    ],
                  ),
                ),
              ),
              if ((widget.title ?? '').isNotEmpty)
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(12, 0, 88, _chrome ? 88 : 20),
                    child: DecoratedBox(
                      decoration: _glass,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Text(
                          widget.title!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: MbTokens.cream,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _controls(bool ready) {
    final playing = ready && _player.value.isPlaying;
    final top = widget.fullscreen ? MediaQuery.viewPaddingOf(context).top : 0.0;

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x661C1410), Color(0x00000000), Color(0x001C1410)],
          stops: [0, 0.42, 1],
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: top),
            child: Row(
              children: [
                if (widget.fullscreen || widget.onClose != null)
                  _GlassIcon(
                    tooltip: 'Close',
                    icon: Icons.close,
                    onPressed: widget.fullscreen
                        ? () => Navigator.of(context).pop()
                        : widget.onClose,
                  ),
              ],
            ),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _GlassIcon(
                tooltip: 'Back 10 seconds',
                icon: Icons.replay_10,
                onPressed: ready ? () => _skip(-10) : null,
              ),
              const SizedBox(width: 16),
              _PlayButton(playing: playing, onTap: ready ? _toggle : null),
              const SizedBox(width: 16),
              _GlassIcon(
                tooltip: 'Forward 10 seconds',
                icon: Icons.forward_10,
                onPressed: ready ? () => _skip(10) : null,
              ),
            ],
          ),
          const Spacer(),
          SizedBox(height: 64 + (widget.fullscreen ? MediaQuery.viewPaddingOf(context).bottom : 0)),
        ],
      ),
    );
  }
}

class _RailButton extends StatelessWidget {
  const _RailButton({required this.action, this.compact = false});

  final MbFilmAction action;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return IconButton(
        tooltip: action.label,
        onPressed: action.onPressed,
        icon: Icon(action.icon, color: MbTokens.ink, size: 24),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Material(
        color: const Color(0xB31C1410),
        shape: const CircleBorder(side: BorderSide(color: Color(0x66C4A35A))),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: action.onPressed,
          child: Tooltip(
            message: action.label,
            child: Semantics(
              button: true,
              label: action.label,
              child: SizedBox(
                width: 44,
                height: 44,
                child: Icon(action.icon, color: MbTokens.cream, size: 22),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassIcon extends StatelessWidget {
  const _GlassIcon({required this.tooltip, required this.icon, this.onPressed});

  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Material(
        color: const Color(0xF21C1410),
        elevation: 6,
        shadowColor: const Color(0x88000000),
        shape: const CircleBorder(side: BorderSide(color: Color(0x99C4A35A))),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: Tooltip(
            message: tooltip,
            child: SizedBox(
              width: 44,
              height: 44,
              child: Icon(icon, color: MbTokens.cream, size: 24),
            ),
          ),
        ),
      ),
    );
  }
}

class _PlayButton extends StatelessWidget {
  const _PlayButton({required this.playing, required this.onTap});

  final bool playing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xF21C1410),
      elevation: 8,
      shadowColor: const Color(0xCC000000),
      shape: const CircleBorder(side: BorderSide(color: MbTokens.foil, width: 1.5)),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 72,
          height: 72,
          child: Icon(
            playing ? Icons.pause : Icons.play_arrow,
            color: MbTokens.cream,
            size: 40,
          ),
        ),
      ),
    );
  }
}

class _FilmStagePage extends StatefulWidget {
  const _FilmStagePage({
    required this.controller,
    required this.actions,
    required this.title,
    required this.shorts,
  });

  final VideoPlayerController controller;
  final List<MbFilmAction> actions;
  final String? title;
  final bool shorts;

  @override
  State<_FilmStagePage> createState() => _FilmStagePageState();
}

class _FilmStagePageState extends State<_FilmStagePage> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    final wide = widget.controller.value.isInitialized &&
        widget.controller.value.aspectRatio > 1.05;
    SystemChrome.setPreferredOrientations(
      wide
          ? const [
              DeviceOrientation.landscapeLeft,
              DeviceOrientation.landscapeRight,
            ]
          : const [DeviceOrientation.portraitUp],
    );
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: MbFilmPlayer(
        controller: widget.controller,
        actions: widget.actions,
        title: widget.title,
        shorts: widget.shorts,
        fullscreen: true,
      ),
    );
  }
}
