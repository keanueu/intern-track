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

    final activity = ActivityEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      tag: _selectedTag,
      note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
      durationMinutes: 0,
    );

    state.addActivity(activity).then((result) {
      _showSnack(result == 'Activity added' ? 'Activity logged' : result, error: result != 'Activity added');
      if (result == 'Activity added') {
        _noteCtrl.clear();
        setState(() {});
      }
    });
  }

  void _removeActivity(AppState state, String activityId) {
    state.removeActivity(activityId).then((result) {
      _showSnack(result == 'Activity removed' ? 'Removed' : result, error: result != 'Activity removed');
    });
  }

  void _showSnack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          Icon(error ? AppIcons.warning : AppIcons.checkCircle,
              color: error ? kRed : kGreen, size: 18),
          const SizedBox(width: 10),
          Expanded(child: Text(msg, style: const TextStyle(color: kWhite))),
        ]),
        behavior: SnackBarBehavior.floating,
        backgroundColor: kSurface,
        shape: RoundedRectangleBorder(borderRadius: kRadiusBtn, side: const BorderSide(color: kBorder)),
      ),
    );
  }

  String _tagLabel(String tag) {
    for (final t in _activityTags) {
      if (t.$1 == tag) return t.$2;
    }
    return tag;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final sessionActivities = state.isPunchedIn && state.openLog != null
            ? state.openLog!.activities
            : <ActivityEntry>[];

        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Activity Log',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: kWhite)),
                  TapScale(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(color: kSurface2, borderRadius: kRadiusTag),
                      child: const Icon(AppIcons.close, color: kGrey, size: 18),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Current session activities
              if (sessionActivities.isNotEmpty) ...[
                const Text('Current Session',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: kGreyDark)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: sessionActivities.map((a) => Chip(
                    label: Text(
                      a.note != null ? '${_tagLabel(a.tag)}: ${a.note}' : _tagLabel(a.tag),
                      style: const TextStyle(fontSize: 11, color: kWhite),
                    ),
                    backgroundColor: kSurface2,
                    side: const BorderSide(color: kBorder),
                    deleteIcon: const Icon(AppIcons.close, size: 14, color: kGrey),
                    onDeleted: () => _removeActivity(state, a.id),
                    shape: RoundedRectangleBorder(borderRadius: kRadiusTag),
                  )).toList(),
                ),
                const SizedBox(height: 16),
                const Divider(height: 1, color: kBorder),
                const SizedBox(height: 16),
              ],

              // Tag selector
              const Text('What are you working on?',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: kWhite)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _activityTags.map((t) {
                  final selected = _selectedTag == t.$1;
                  return TapScale(
                    onTap: () => setState(() => _selectedTag = t.$1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: selected ? kGreenGradient : null,
                        color: selected ? null : kSurface2,
                        borderRadius: kRadiusBtn,
                        border: Border.all(color: selected ? kGreen : kBorder),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(t.$3, size: 14, color: selected ? kBg : kGrey),
                          const SizedBox(width: 4),
                          Text(t.$2,
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: selected ? kBg : kWhite)),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),

              // Note field
              TextField(
                controller: _noteCtrl,
                style: const TextStyle(color: kWhite, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Add a note (optional)',
                  hintStyle: const TextStyle(color: kGrey, fontSize: 13),
                  filled: true,
                  fillColor: kSurface2,
                  border: OutlineInputBorder(borderRadius: kRadiusInput, borderSide: BorderSide.none),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: kRadiusInput, borderSide: const BorderSide(color: kBorder)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: kRadiusInput, borderSide: const BorderSide(color: kGreen)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: TapScale(
                  onTap: () => _addActivity(state),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      gradient: kGreenGradient,
                      borderRadius: kRadiusBtn,
                      boxShadow: kGreenGlow,
                    ),
                    child: const Center(
                      child: Text('Log Activity',
                          style: TextStyle(color: kBg, fontWeight: FontWeight.w700, fontSize: 15)),
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
