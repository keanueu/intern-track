import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';

class CompetencyScreen extends StatefulWidget {
  const CompetencyScreen({super.key});

  @override
  State<CompetencyScreen> createState() => _CompetencyScreenState();
}

class _CompetencyScreenState extends State<CompetencyScreen> {
  static const _categoryOrder = ['Technical', 'Soft Skills', 'Domain', 'Tools', 'Process', 'Other'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().loadCompetencies();
    });
  }

  void _addCompetency(BuildContext context, AppState state) {
    final titleCtrl = TextEditingController();
    final c = ThemeColors.of(context);
    final ts = Theme.of(context).textTheme;
    String category = 'Technical';
    bool showTitleError = false;

    showModalBottomSheet(
      context: context,
      backgroundColor: c.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: kRadiusSheet),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 24, right: 24, top: 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildDragHandle(c),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Add Competency', style: ts.titleLarge),
                    HitArea(
                      size: 44,
                      child: TapScale(
                        onTap: () => Navigator.pop(ctx),
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
                Text('Title', style: ts.labelSmall),
                const SizedBox(height: 6),
                TextField(
                  controller: titleCtrl,
                  autofocus: true,
                  textInputAction: TextInputAction.done,
                  style: ts.bodyLarge,
                  decoration: InputDecoration(
                    hintText: 'e.g. REST API Design',
                    errorText: showTitleError ? 'Title is required' : null,
                    focusedBorder: OutlineInputBorder(
                        borderRadius: kRadiusInput,
                        borderSide: BorderSide(color: c.accent, width: 1.5)),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Category', style: ts.labelSmall),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: ['Technical', 'Soft Skills', 'Domain', 'Tools', 'Process'].map((cat) {
                    final selected = category == cat;
                    return TapScale(
                      onTap: () => setSheetState(() => category = cat),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          gradient: selected ? kGreenGradient : null,
                          color: selected ? null : c.surface2,
                          borderRadius: kRadiusBtn,
                          border: Border.all(color: selected ? c.accent : c.border),
                        ),
                        child: Text(cat, style: ts.labelSmall?.copyWith(
                            color: selected ? c.onAccent : c.textPrimary)),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: TapScale(
                    onTap: () {
                      if (titleCtrl.text.trim().isEmpty) {
                        setSheetState(() => showTitleError = true);
                        return;
                      }
                      state.saveCompetency({
                        'id': DateTime.now().millisecondsSinceEpoch.toString(),
                        'user_id': state.profile.id,
                        'title': titleCtrl.text.trim(),
                        'category': category,
                        'description': '',
                        'completed': 0,
                        'completed_at': null,
                        'due_date': null,
                        'evidence_path': null,
                        'created_at': DateTime.now().toIso8601String(),
                      });
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Competency added', style: ts.bodyMedium),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: c.surface,
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: const BoxDecoration(gradient: kGreenGradient, borderRadius: kRadiusBtn),
                      child: Center(
                        child: Text('Add', style: ts.labelLarge?.copyWith(color: c.onAccent)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = ThemeColors.of(context);
    final ts = Theme.of(context).textTheme;
    return Consumer<AppState>(
      builder: (context, state, _) {
        final competencies = state.competencies;
        final completed = state.completedCompetencies;
        final total = state.totalCompetencies;
        final pct = state.competencyPercent;

        final grouped = <String, List<Map<String, dynamic>>>{};
        for (final comp in competencies) {
          final cat = (comp['category'] as String?) ?? 'Other';
          grouped.putIfAbsent(cat, () => []).add(comp);
        }

        final sortedKeys = grouped.keys.toList()
          ..sort((a, b) {
            final ai = _categoryOrder.indexOf(a);
            final bi = _categoryOrder.indexOf(b);
            return (ai == -1 ? 99 : ai).compareTo(bi == -1 ? 99 : bi);
          });

        return Scaffold(
          appBar: AppBar(
            backgroundColor: c.bg,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            leading: TapScale(
              onTap: () => Navigator.pop(context),
              child: Icon(AppIcons.chevronLeft, color: c.textPrimary),
            ),
            title: Text('Competencies', style: ts.titleLarge),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: TapScale(
                  onTap: () => _addCompetency(context, state),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: const BoxDecoration(gradient: kGreenGradient, borderRadius: kRadiusBtn),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(AppIcons.addPerson, color: c.onAccent, size: 16),
                        const SizedBox(width: 4),
                        Text('Add', style: ts.labelSmall?.copyWith(color: c.onAccent, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  FadeSlideIn(
                    index: 0,
                    child: Text('Track your OJT skills and tasks', style: ts.bodyMedium),
                  ),
                  const SizedBox(height: 24),

                  FadeSlideIn(
                    index: 1,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: c.surface,
                        borderRadius: kRadiusCard,
                        border: Border.all(color: c.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Completion', style: ts.titleSmall),
                              Text('$completed / $total',
                                  style: ts.titleSmall?.copyWith(color: c.accent)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          AnimatedGradientBar(value: pct.clamp(0.0, 1.0), height: 8),
                          const SizedBox(height: 6),
                          Text('${(pct * 100).toStringAsFixed(0)}% complete', style: ts.labelSmall),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  if (competencies.isEmpty)
                    FadeSlideIn(
                      index: 2,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Column(
                          children: [
                            Icon(AppIcons.badge, color: c.textSecondary.withValues(alpha: 0.3), size: 48),
                            const SizedBox(height: 12),
                            Text('No competencies yet', style: ts.titleSmall),
                            const SizedBox(height: 4),
                            Text('Track your OJT skills and tasks', style: ts.bodySmall),
                            const SizedBox(height: 16),
                            TapScale(
                              onTap: () => _addCompetency(context, state),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                decoration: const BoxDecoration(gradient: kGreenGradient, borderRadius: kRadiusBtn),
                                child: Text('Add Your First Competency',
                                    style: ts.labelLarge?.copyWith(color: c.onAccent)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  ...sortedKeys.asMap().entries.map((keyEntry) {
                    final idx = keyEntry.key;
                    final entryKey = keyEntry.value;
                    final entry = grouped[entryKey]!;
                    return FadeSlideIn(
                      index: 2 + idx,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(entryKey, style: ts.labelSmall?.copyWith(fontWeight: FontWeight.w700, color: c.textMuted)),
                            const SizedBox(height: 8),
                            Container(
                              decoration: BoxDecoration(color: c.surface2, borderRadius: kRadiusCard),
                              child: Column(
                                children: entry.asMap().entries.map((e) {
                                  final i = e.key;
                                  final comp = e.value;
                                  final isCompleted = comp['completed'] == 1;
                                  return Column(
                                    children: [
                                      if (i > 0) Divider(height: 1, indent: 16, endIndent: 16, color: c.border),
                                      TapScale(
                                        onTap: () {
                                          state.toggleCompetency(comp['id'], isCompleted ? 0 : 1);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  isCompleted ? 'Marked as incomplete' : 'Competency completed!',
                                                  style: ts.bodyMedium),
                                              behavior: SnackBarBehavior.floating,
                                              backgroundColor: c.surface,
                                            ),
                                          );
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 22, height: 22,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: isCompleted ? c.accent : Colors.transparent,
                                                  border: Border.all(
                                                    color: isCompleted ? c.accent : c.textMuted,
                                                    width: 2,
                                                  ),
                                                ),
                                                child: isCompleted
                                                    ? Icon(AppIcons.checkCircle, color: c.onAccent, size: 14)
                                                    : null,
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Text(
                                                  comp['title'] ?? '',
                                                  style: ts.bodyLarge?.copyWith(
                                                    color: isCompleted ? c.textSecondary : c.textPrimary,
                                                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                                                  ),
                                                ),
                                              ),
                                              HitArea(
                                                size: 44,
                                                child: TapScale(
                                                  onTap: () {
                                                    showDialog(
                                                      context: context,
                                                      builder: (_) => AlertDialog(
                                                        backgroundColor: c.surface,
                                                        shape: const RoundedRectangleBorder(borderRadius: kRadiusCard),
                                                        title: Text('Delete Competency', style: ts.titleLarge),
                                                        content: Text('Remove this item from your list?', style: ts.bodyMedium),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () => Navigator.pop(context),
                                                            child: Text('Cancel', style: ts.labelLarge),
                                                          ),
                                                          TextButton(
                                                            onPressed: () {
                                                              state.deleteCompetency(comp['id']);
                                                              Navigator.pop(context);
                                                            },
                                                            child: Text('Delete',
                                                                style: ts.labelLarge?.copyWith(color: c.error)),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                  child: Icon(AppIcons.deleteOutline, color: c.textMuted, size: 18),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
