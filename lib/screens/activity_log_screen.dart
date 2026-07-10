import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../models/dtr_model.dart';
import '../theme/app_theme.dart';

class ActivityLogScreen extends StatefulWidget {
  const ActivityLogScreen({super.key});

  @override
  State<ActivityLogScreen> createState() => _ActivityLogScreenState();
}

class _ActivityLogScreenState extends State<ActivityLogScreen> {
  final _noteCtrl = TextEditingController();
  String _selectedTag = 'coding';
  bool _isSubmitting = false;

  static const _activityTags = [
    ('coding', 'Coding', Icons.code),
    ('meetings', 'Meetings', Icons.groups),
    ('docs', 'Docs', Icons.description),
    ('testing', 'Testing', Icons.shield),
    ('research', 'Research', Icons.search),
    ('admin', 'Admin', Icons.inventory_2),
    ('learning', 'Learning', Icons.menu_book),
    ('other', 'Other', Icons.more_horiz),
  ];

  static final _tagLabels = {for (final t in _activityTags) t.$1: t.$2};

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  void _addActivity(AppState state) {
    if (!state.isPunchedIn) {
      _showSnack('No active session', error: true);
      return;
    }
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);

    final activity = ActivityEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      tag: _selectedTag,
      note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
      durationMinutes: 0,
    );

    state.addActivity(activity).then((result) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      _showSnack(result == 'Activity added' ? 'Activity logged' : result, error: result != 'Activity added');
      if (result == 'Activity added') _noteCtrl.clear();
    });
  }

  void _removeActivity(AppState state, String activityId) {
    state.removeActivity(activityId).then((result) {
      if (!mounted) return;
      _showSnack(result == 'Activity removed' ? 'Removed' : result, error: result != 'Activity removed');
    });
  }

  void _showSnack(String msg, {bool error = false}) {
    final c = ThemeColors.of(context);
    final ts = Theme.of(context).textTheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          Icon(error ? AppIcons.warning : AppIcons.checkCircle,
              color: error ? c.error : c.accent, size: 18),
          const SizedBox(width: 10),
          Expanded(child: Text(msg, style: ts.bodyMedium)),
        ]),
        behavior: SnackBarBehavior.floating,
        backgroundColor: c.surface,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final c = ThemeColors.of(context);
        final ts = Theme.of(context).textTheme;
        final sessionActivities = state.isPunchedIn && state.openLog != null
            ? state.openLog!.activities
            : <ActivityEntry>[];

        return SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildDragHandle(c),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Activity Log', style: ts.titleLarge),
                  HitArea(
                    size: 44,
                    child: TapScale(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(color: c.surface2, borderRadius: kRadiusTag),
                        child: Icon(AppIcons.close, color: c.textSecondary, size: 18),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (sessionActivities.isNotEmpty) ...[
                Text('Current Session', style: ts.labelSmall?.copyWith(fontWeight: FontWeight.w700, color: c.textMuted)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: sessionActivities.map((a) => Chip(
                    label: Text(
                      a.note != null ? '${_tagLabels[a.tag] ?? a.tag}: ${a.note}' : (_tagLabels[a.tag] ?? a.tag),
                      style: ts.labelSmall,
                    ),
                    backgroundColor: c.surface2,
                    side: BorderSide(color: c.border),
                    deleteIcon: Icon(AppIcons.close, size: 14, color: c.textSecondary),
                    onDeleted: () => _removeActivity(state, a.id),
                    shape: const RoundedRectangleBorder(borderRadius: kRadiusTag),
                  )).toList(),
                ),
                const SizedBox(height: 16),
                Divider(height: 1, color: c.border),
                const SizedBox(height: 16),
              ] else if (!state.isPunchedIn) ...[
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text('Punch in to start logging activities.', style: ts.bodySmall),
                ),
              ] else ...[
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text('No activities logged yet this session.', style: ts.bodySmall),
                ),
              ],

              Text('What are you working on?', style: ts.labelLarge),
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _activityTags.map((t) {
                  final selected = _selectedTag == t.$1;
                  return TapScale(
                    onTap: () => setState(() => _selectedTag = t.$1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: selected ? kGreenGradient : null,
                        color: selected ? null : c.surface2,
                        borderRadius: kRadiusBtn,
                        border: Border.all(color: selected ? c.accent : c.border),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(t.$3, size: 14, color: selected ? c.onAccent : c.textSecondary),
                          const SizedBox(width: 4),
                          Text(t.$2, style: ts.labelSmall?.copyWith(
                              color: selected ? c.onAccent : c.textPrimary)),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: _noteCtrl,
                maxLines: 3,
                maxLength: 200,
                textInputAction: TextInputAction.done,
                style: ts.bodyMedium,
                decoration: InputDecoration(
                  hintText: 'Add a note (optional)',
                  focusedBorder: OutlineInputBorder(
                      borderRadius: kRadiusInput,
                      borderSide: BorderSide(color: c.accent, width: 1.5)),
                ),
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: TapScale(
                  onTap: _isSubmitting ? null : () => _addActivity(state),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      gradient: _isSubmitting ? null : kGreenGradient,
                      color: _isSubmitting ? c.surface2 : null,
                      borderRadius: kRadiusBtn,
                    ),
                    child: Center(
                      child: _isSubmitting
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(color: c.textMuted, strokeWidth: 2),
                            )
                          : Text('Log Activity',
                              style: ts.labelLarge?.copyWith(color: c.onAccent)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
