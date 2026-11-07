import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../core/theme/tokens.dart';

/// Play, pause, seek, and volume. Playback starts only when the person taps play.
class MbFilmPlayer extends StatefulWidget {
  const MbFilmPlayer({
    super.key,
    required this.controller,
    this.onDark = false,
  });

  final VideoPlayerController controller;
  final bool onDark;

  @override
  State<MbFilmPlayer> createState() => _MbFilmPlayerState();
}

class _MbFilmPlayerState extends State<MbFilmPlayer> {
  bool _scrubbing = false;
  double _scrubMs = 0;

  VideoPlayerController get _player => widget.controller;

  @override
  void initState() {
    super.initState();
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
    _player.removeListener(_onTick);
    super.dispose();
  }

  void _onTick() {
    if (mounted && !_scrubbing) setState(() {});
  }

  String _clock(Duration time) {
    final total = time.inSeconds;
    final minutes = total ~/ 60;
    final seconds = (total % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Future<void> _toggle() async {
    if (!_player.value.isInitialized) return;
    if (_player.value.isPlaying) {
      await _player.pause();
    } else {
      final end = _player.value.duration;
      if (end > Duration.zero && _player.value.position >= end - const Duration(milliseconds: 200)) {
        await _player.seekTo(Duration.zero);
      }
      await _player.play();
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final ready = _player.value.isInitialized;
    final ink = widget.onDark ? Colors.white : MbTokens.ink;
    final track = widget.onDark ? Colors.white24 : MbTokens.linen;
    final durationMs = ready ? _player.value.duration.inMilliseconds.toDouble() : 1.0;
    final positionMs = ready ? _player.value.position.inMilliseconds.toDouble() : 0.0;
    final shown = _scrubbing ? _scrubMs : positionMs.clamp(0, durationMs);
    final ratio = !ready || _player.value.aspectRatio == 0 ? 9 / 16 : _player.value.aspectRatio;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AspectRatio(
          aspectRatio: ratio,
          child: ColoredBox(
            color: Colors.black,
            child: ready
                ? VideoPlayer(_player)
                : const Center(child: CircularProgressIndicator(color: Colors.white)),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            IconButton(
              tooltip: ready && _player.value.isPlaying ? 'Pause' : 'Play',
              onPressed: ready ? _toggle : null,
              icon: Icon(
                ready && _player.value.isPlaying ? Icons.pause : Icons.play_arrow,
                color: ink,
              ),
            ),
            Text(
              ready ? _clock(Duration(milliseconds: shown.round())) : '0:00',
              style: TextStyle(color: ink, fontFamily: MbTokens.sans, fontSize: 13),
            ),
            Expanded(
              child: Slider(
                value: shown.clamp(0, durationMs).toDouble(),
                max: durationMs <= 0 ? 1 : durationMs,
                activeColor: MbTokens.leather,
                inactiveColor: track,
                onChangeStart: ready
                    ? (value) => setState(() {
                          _scrubbing = true;
                          _scrubMs = value;
                        })
                    : null,
                onChanged: ready
                    ? (value) => setState(() => _scrubMs = value)
                    : null,
                onChangeEnd: ready
                    ? (value) async {
                        await _player.seekTo(Duration(milliseconds: value.round()));
                        if (mounted) setState(() => _scrubbing = false);
                      }
                    : null,
              ),
            ),
            Text(
              ready ? _clock(_player.value.duration) : '0:00',
              style: TextStyle(color: ink, fontFamily: MbTokens.sans, fontSize: 13),
            ),
          ],
        ),
        Row(
          children: [
            Icon(Icons.volume_up, color: ink, size: 20),
            Expanded(
              child: Slider(
                value: ready ? _player.value.volume.clamp(0, 1) : 1,
                activeColor: MbTokens.leather,
                inactiveColor: track,
                onChanged: ready
                    ? (value) async {
                        await _player.setVolume(value);
                        if (mounted) setState(() {});
                      }
                    : null,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
