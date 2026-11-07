import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

import '../../core/nav.dart';
import '../../core/theme/tokens.dart';
import '../../providers.dart';
import '../../services/reel_library.dart';
import '../ai/cloud_clip.dart';
import '../../widgets/film_player.dart';

class ClipEditorScreen extends ConsumerStatefulWidget {
  const ClipEditorScreen({super.key, required this.reelId});

  final String reelId;

  @override
  ConsumerState<ClipEditorScreen> createState() => _ClipEditorScreenState();
}

class _ClipEditorScreenState extends ConsumerState<ClipEditorScreen> {
  VideoPlayerController? _player;
  VideoPlayerController? _joinPlayer;
  ReelRecord? _reel;
  ReelRecord? _join;
  String _aspect = 'original';
  bool _mute = false;
  bool _busy = false;
  bool _missing = false;
  int _durationMs = 1;
  int _startMs = 0;
  int _endMs = 1;
  int _joinDurationMs = 1;
  int _joinStartMs = 0;
  int _joinEndMs = 1;

  @override
  void initState() {
    super.initState();
    Future.microtask(_open);
  }

  Future<void> _open() async {
    final rows = await ref.read(reelLibraryProvider).load();
    ReelRecord? reel;
    for (final row in rows) {
      if (row.id == widget.reelId) reel = row;
    }
    if (!mounted) return;
    if (reel == null || !File(reel.path).existsSync()) {
      setState(() => _missing = true);
      return;
    }
    final player = VideoPlayerController.file(File(reel.path));
    await player.initialize();
    await player.setLooping(false);
    final duration = player.value.duration.inMilliseconds.clamp(1, 3600000);
    player.addListener(_followTrim);
    if (!mounted) {
      await player.dispose();
      return;
    }
    setState(() {
      _reel = reel;
      _player = player;
      _durationMs = duration;
      _endMs = duration;
    });
    await player.pause();
  }

  void _followTrim() {
    final player = _player;
    if (player == null || !player.value.isInitialized || _busy) return;
    _holdInside(player, _startMs, _endMs);
  }

  void _followJoin() {
    final player = _joinPlayer;
    if (player == null || !player.value.isInitialized || _busy) return;
    _holdInside(player, _joinStartMs, _joinEndMs);
  }

  void _holdInside(VideoPlayerController player, int startMs, int endMs) {
    if (!player.value.isPlaying) return;
    final end = Duration(milliseconds: endMs);
    if (player.value.position >= end) {
      player.seekTo(Duration(milliseconds: startMs));
      player.pause();
    }
  }

  @override
  void dispose() {
    _player?.removeListener(_followTrim);
    _joinPlayer?.removeListener(_followJoin);
    _player?.dispose();
    _joinPlayer?.dispose();
    super.dispose();
  }

  Future<void> _pickJoin() async {
    final rows = await ref.read(reelLibraryProvider).load();
    final others = rows.where((row) => row.id != widget.reelId).toList();
    if (!mounted) return;
    if (others.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Make another reel, then join it here.')),
      );
      return;
    }
    final picked = await showModalBottomSheet<ReelRecord>(
      context: context,
      backgroundColor: MbTokens.cream,
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Text(
                'Play this after the cut',
                style: TextStyle(
                  fontFamily: MbTokens.serif,
                  fontSize: 22,
                  color: MbTokens.ink,
                ),
              ),
            ),
            for (final row in others)
              ListTile(
                title: Text(row.title),
                subtitle: Text(row.kind),
                onTap: () => Navigator.pop(ctx, row),
              ),
          ],
        ),
      ),
    );
    if (picked == null) return;
    final player = VideoPlayerController.file(File(picked.path));
    await player.initialize();
    await player.setLooping(false);
    await player.setVolume(0);
    player.addListener(_followJoin);
    final duration = player.value.duration.inMilliseconds.clamp(1, 3600000);
    if (!mounted) {
      await player.dispose();
      return;
    }
    final previous = _joinPlayer;
    previous?.removeListener(_followJoin);
    setState(() {
      _join = picked;
      _joinPlayer = player;
      _joinDurationMs = duration;
      _joinStartMs = 0;
      _joinEndMs = duration;
    });
    await previous?.dispose();
    await player.pause();
  }

  Future<void> _save() async {
    final reel = _reel;
    if (reel == null || _busy) return;
    if (_endMs - _startMs < 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Leave at least a moment in the cut.')),
      );
      return;
    }
    setState(() => _busy = true);
    try {
      final dir = await getTemporaryDirectory();
      final output = p.join(dir.path, 'mb-edit-${reel.id}.mp4');
      final clips = <Map<String, Object>>[
        {'path': reel.path, 'startMs': _startMs, 'endMs': _endMs},
        if (_join != null)
          {
            'path': _join!.path,
            'startMs': _joinStartMs,
            'endMs': _joinEndMs,
          },
      ];
      final path = await ref.read(nativeEncoderProvider).editClip(
            clips: clips,
            outputPath: output,
            aspect: _aspect,
            mute: _mute,
          );
      await ref.read(reelLibraryProvider).keep(
            source: File(path),
            title: nextReelTitle(
              await ref.read(reelLibraryProvider).load(),
              'Edit of ${reel.title}',
            ),
            kind: 'edit',
          );
      ref.invalidate(reelsProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _join == null
                ? 'Saved on Reels. The original is still there.'
                : 'Joined and saved on Reels. Both originals are still there.',
          ),
        ),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save this edit: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _restyle() async {
    final reel = _reel;
    if (reel == null || _busy) return;
    setState(() => _busy = true);
    try {
      final bytes = await ref.read(nativeEncoderProvider).posterFrame(
            path: reel.path,
            atMs: _startMs,
          );
      final still = await ref.read(exportServiceProvider).writeBytes(bytes, 'jpg');
      if (!mounted) return;
      setState(() => _busy = false);
      final prompt = await askClipPrompt(context);
      if (prompt == null || !mounted) return;
      final result = await runCloudClip(
        context,
        ref,
        imagePath: still.path,
        prompt: prompt,
      );
      if (!result.ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.message ?? 'The restyle did not finish.')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not read a frame: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final player = _player;
    return Scaffold(
      backgroundColor: MbTokens.studio,
      appBar: AppBar(
        leading: shelfBackButton(context),
        title: const Text('Edit'),
        actions: [
          TextButton(
            onPressed: _busy || _reel == null ? null : _save,
            child: Text(_busy ? 'Saving' : (_join == null ? 'Save' : 'Join and save')),
          ),
        ],
      ),
      body: _missing
          ? const Center(child: Text('That reel is no longer on this phone.'))
          : player == null || !player.value.isInitialized
              ? const Center(child: CircularProgressIndicator())
              : Stack(
                  children: [
                    ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                  children: [
                    _PreviewRow(
                      first: player,
                      firstTitle: _reel?.title ?? 'This cut',
                      second: _joinPlayer,
                      secondTitle: _join?.title,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _reel?.title ?? 'Reel',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_clock(_startMs)} – ${_clock(_endMs)}',
                      style: const TextStyle(
                        fontFamily: MbTokens.sans,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: MbTokens.inkSoft,
                      ),
                    ),
                    RangeSlider(
                      values: RangeValues(_startMs.toDouble(), _endMs.toDouble()),
                      min: 0,
                      max: _durationMs.toDouble(),
                      activeColor: MbTokens.leather,
                      inactiveColor: MbTokens.linen,
                      onChanged: (value) {
                        final start = value.start.round().clamp(0, _durationMs - 1).toInt();
                        final end = value.end.round().clamp(start + 1, _durationMs).toInt();
                        setState(() {
                          _startMs = start;
                          _endMs = end;
                        });
                        player.seekTo(Duration(milliseconds: start));
                      },
                    ),
                    const Text(
                      'Cut',
                      style: TextStyle(
                        fontFamily: MbTokens.sans,
                        fontWeight: FontWeight.w700,
                        color: MbTokens.ink,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final choice in _aspects)
                          ChoiceChip(
                            label: Text(choice.$2),
                            selected: _aspect == choice.$1,
                            selectedColor: MbTokens.leather,
                            labelStyle: TextStyle(
                              color: _aspect == choice.$1 ? MbTokens.cream : MbTokens.ink,
                              fontFamily: MbTokens.sans,
                              fontWeight: FontWeight.w600,
                            ),
                            onSelected: (_) => setState(() => _aspect = choice.$1),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Keep the sound'),
                      value: !_mute,
                      activeThumbColor: MbTokens.leather,
                      onChanged: (keep) => setState(() => _mute = !keep),
                    ),
                    _JoinCard(
                      join: _join,
                      startMs: _joinStartMs,
                      endMs: _joinEndMs,
                      durationMs: _joinDurationMs,
                      onPick: _pickJoin,
                      onClear: _clearJoin,
                      onTrim: (start, end) {
                        setState(() {
                          _joinStartMs = start;
                          _joinEndMs = end;
                        });
                        _joinPlayer?.seekTo(Duration(milliseconds: start));
                      },
                    ),
                    const SizedBox(height: 12),
                    _AiCard(busy: _busy, onPressed: _restyle),
                  ],
                ),
                    if (_busy)
                      Positioned.fill(
                        child: ColoredBox(
                          color: const Color(0x99000000),
                          child: Center(
                            child: _WorkNote(
                              text: _join == null
                                  ? 'Saving this cut'
                                  : 'Joining the two reels',
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
    );
  }

  Future<void> _clearJoin() async {
    final previous = _joinPlayer;
    previous?.removeListener(_followJoin);
    setState(() {
      _join = null;
      _joinPlayer = null;
    });
    await previous?.dispose();
  }
}

class _PreviewRow extends StatelessWidget {
  const _PreviewRow({
    required this.first,
    required this.firstTitle,
    required this.second,
    required this.secondTitle,
  });

  final VideoPlayerController first;
  final String firstTitle;
  final VideoPlayerController? second;
  final String? secondTitle;

  @override
  Widget build(BuildContext context) {
    if (second == null || !second!.value.isInitialized) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _pane(first, firstTitle),
        ],
      );
    }
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _pane(first, '1  ·  $firstTitle')),
            const SizedBox(width: 10),
            Expanded(child: _pane(second!, '2  ·  $secondTitle')),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Join and save plays 1, then 2, as a new reel.',
          style: TextStyle(
            fontFamily: MbTokens.sans,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: MbTokens.inkSoft,
          ),
        ),
      ],
    );
  }

  Widget _pane(VideoPlayerController player, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontFamily: MbTokens.sans,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: MbTokens.ink,
          ),
        ),
        const SizedBox(height: 6),
        MbFilmPlayer(controller: player),
      ],
    );
  }
}

class _WorkNote extends StatelessWidget {
  const _WorkNote({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: MbTokens.cream,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Text(
              text,
              style: const TextStyle(
                fontFamily: MbTokens.sans,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: MbTokens.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

const _aspects = <(String, String)>[
  ('original', 'Original'),
  ('9:16', 'Story'),
  ('4:5', 'Portrait'),
  ('1:1', 'Square'),
  ('16:9', 'Wide'),
];

String _clock(int ms) {
  final total = (ms / 1000).floor();
  final minutes = (total ~/ 60).toString().padLeft(1, '0');
  final seconds = (total % 60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}

class _JoinCard extends StatelessWidget {
  const _JoinCard({
    required this.join,
    required this.startMs,
    required this.endMs,
    required this.durationMs,
    required this.onPick,
    required this.onClear,
    required this.onTrim,
  });

  final ReelRecord? join;
  final int startMs;
  final int endMs;
  final int durationMs;
  final VoidCallback onPick;
  final VoidCallback onClear;
  final void Function(int start, int end) onTrim;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Join',
              style: TextStyle(
                fontFamily: MbTokens.sans,
                fontWeight: FontWeight.w700,
                color: MbTokens.ink,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              join == null
                  ? 'Choose a second reel, then tap Join and save. A new reel is added. These two stay as they are.'
                  : 'Join and save plays this cut, then ${join!.title}.',
              style: const TextStyle(
                fontFamily: MbTokens.sans,
                fontSize: 15,
                height: 1.35,
                color: MbTokens.inkSoft,
              ),
            ),
            if (join != null) ...[
              RangeSlider(
                values: RangeValues(startMs.toDouble(), endMs.toDouble()),
                min: 0,
                max: durationMs.toDouble(),
                activeColor: MbTokens.leather,
                inactiveColor: MbTokens.linen,
                onChanged: (value) {
                  final start = value.start.round().clamp(0, durationMs - 1).toInt();
                  final end = value.end.round().clamp(start + 1, durationMs).toInt();
                  onTrim(start, end);
                },
              ),
            ],
            Row(
              children: [
                TextButton(onPressed: onPick, child: Text(join == null ? 'Choose a reel' : 'Change')),
                if (join != null)
                  TextButton(onPressed: onClear, child: const Text('Remove')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AiCard extends StatelessWidget {
  const _AiCard({
    required this.busy,
    required this.onPressed,
  });

  final bool busy;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: MbTokens.leather,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'AI restyle',
              style: TextStyle(
                fontFamily: MbTokens.serif,
                fontSize: 26,
                color: MbTokens.cream,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'One frame of this cut leaves the phone and comes back as a new moving photo. One credit.',
              style: TextStyle(
                fontFamily: MbTokens.sans,
                fontSize: 15,
                height: 1.4,
                color: MbTokens.cream,
              ),
            ),
            const SizedBox(height: 8),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: MbTokens.cream,
                foregroundColor: MbTokens.leather,
              ),
              onPressed: busy ? null : onPressed,
              child: const Text('Restyle this frame · 1 credit'),
            ),
          ],
        ),
      ),
    );
  }
}
