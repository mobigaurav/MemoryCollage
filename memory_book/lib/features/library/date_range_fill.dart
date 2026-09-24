import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme/tokens.dart';

class DateRangeFillFields extends StatelessWidget {
  const DateRangeFillFields({
    super.key,
    required this.enabled,
    required this.start,
    required this.end,
    required this.onEnabled,
    required this.onStart,
    required this.onEnd,
  });

  final bool enabled;
  final DateTime start;
  final DateTime end;
  final ValueChanged<bool> onEnabled;
  final ValueChanged<DateTime> onStart;
  final ValueChanged<DateTime> onEnd;

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat.yMMMd();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Fill from a date range'),
          subtitle: const Text(
            'Pull photos from this trip or week onto empty pages.',
            style: TextStyle(color: MbTokens.paperDeep),
          ),
          value: enabled,
          onChanged: onEnabled,
        ),
        if (enabled) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _preset(context, 'Last week', 7),
              _preset(context, 'Last month', 30),
              _preset(context, 'This year', DateTime.now().difference(DateTime(DateTime.now().year)).inDays),
            ],
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('From'),
            trailing: Text(fmt.format(start)),
            onTap: () => _pick(context, start, onStart),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('To'),
            trailing: Text(fmt.format(end)),
            onTap: () => _pick(context, end, onEnd),
          ),
        ],
      ],
    );
  }

  Widget _preset(BuildContext context, String label, int days) {
    return ActionChip(
      label: Text(label),
      onPressed: () {
        final now = DateTime.now();
        onStart(DateTime(now.year, now.month, now.day).subtract(Duration(days: days)));
        onEnd(now);
      },
    );
  }

  Future<void> _pick(
    BuildContext context,
    DateTime initial,
    ValueChanged<DateTime> onPicked,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) onPicked(picked);
  }
}

Future<(DateTime start, DateTime end)?> pickFillRange(
  BuildContext context, {
  DateTime? start,
  DateTime? end,
}) async {
  var from = start ?? DateTime.now().subtract(const Duration(days: 7));
  var to = end ?? DateTime.now();
  var enabled = true;
  return showModalBottomSheet<(DateTime, DateTime)>(
    context: context,
    backgroundColor: MbTokens.leatherDark,
    isScrollControlled: true,
    builder: (ctx) {
      return Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 16,
          bottom: MediaQuery.viewInsetsOf(ctx).bottom + 24,
        ),
        child: StatefulBuilder(
          builder: (ctx, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Fill empty pages',
                  style: Theme.of(ctx).textTheme.titleLarge,
                ),
                DateRangeFillFields(
                  enabled: enabled,
                  start: from,
                  end: to,
                  onEnabled: (v) => setState(() => enabled = v),
                  onStart: (v) => setState(() => from = v),
                  onEnd: (v) => setState(() => to = v),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: enabled ? () => Navigator.pop(ctx, (from, to)) : null,
                  child: const Text('Collect photos'),
                ),
              ],
            );
          },
        ),
      );
    },
  );
}
