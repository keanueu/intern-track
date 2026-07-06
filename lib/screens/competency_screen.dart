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
    String category = 'Technical';

    showModalBottomSheet(
      context: context,
      backgroundColor: c.surface,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        side: BorderSide(color: c.border),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          final c = ThemeColors.of(ctx);
          return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 24, right: 24, top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Add Competency',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: c.textPrimary)),
                  TapScale(
                    onTap: () => Navigator.pop(ctx),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(color: c.surface2, borderRadius: kRadiusTag),
                      child: Icon(AppIcons.close, color: c.textSecondary, size: 18),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text('Title', style: TextStyle(fontSize: 12, color: c.textSecondary, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              TextField(
                controller: titleCtrl,
                style: TextStyle(color: c.textPrimary),
                decoration: InputDecoration(
                  hintText: 'e.g. REST API Design',
                  filled: true, fillColor: c.surface2,
                  border: OutlineInputBorder(borderRadius: kRadiusInput, borderSide: BorderSide.none),
                  enabledBorder: OutlineInputBorder(borderRadius: kRadiusInput, borderSide: BorderSide(color: c.border)),
                  focusedBorder: OutlineInputBorder(borderRadius: kRadiusInput, borderSide: const BorderSide(color: kGreen)),
                ),
              ),
              const SizedBox(height: 16),
              Text('Category', style: TextStyle(fontSize: 12, color: c.textSecondary, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: ['Technical', 'Soft Skills', 'Domain', 'Tools', 'Process'].map((cat) {
                  final selected = category == cat;
                  return TapScale(
                    onTap: () => setSheetState(() => category = cat),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
                      decoration: BoxDecoration(
                        gradient: selected ? kGreenGradient : null,
                        color: selected ? null : c.surface2,
                        borderRadius: kRadiusBtn,
                        border: Border.all(color: selected ? kGreen : c.border),
                      ),
                      child: Text(cat,
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600,
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
                    if (titleCtrl.text.trim().isEmpty) return;
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
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(gradient: kGreenGradient, borderRadius: kRadiusBtn),
                    child: Center(
                      child: Text('Add', style: TextStyle(color: c.onAccent, fontWeight: FontWeight.w700, fontSize: 15)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = ThemeColors.of(context);
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

        return Scaffold(
          backgroundColor: c.bg,
          appBar: AppBar(
            backgroundColor: c.bg,
            elevation: 0,
            leading: TapScale(
              onTap: () => Navigator.pop(context),
              child: Icon(AppIcons.chevronLeft, color: c.textPrimary),
            ),
            title: Text('Competencies',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: c.textPrimary)),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: TapScale(
                  onTap: () => _addCompetency(context, state),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: kGreenGradient,
                      borderRadius: kRadiusBtn,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(AppIcons.addPerson, color: c.onAccent, size: 16),
                        const SizedBox(width: 4),
                        Text('Add', style: TextStyle(color: c.onAccent, fontWeight: FontWeight.w700, fontSize: 13)),
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
                  Text('Track your OJT skills and tasks',
                      style: TextStyle(fontSize: 14, color: c.textSecondary)),
                  const SizedBox(height: 24),

                  // Progress card
                  Container(
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
                            Text('Completion',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: c.textPrimary)),
                            Text('$completed / $total',
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: kGreen)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        AnimatedGradientBar(value: pct.clamp(0.0, 1.0), height: 8),
                        const SizedBox(height: 6),
                        Text('${(pct * 100).toStringAsFixed(0)}% complete',
                            style: TextStyle(fontSize: 11, color: c.textSecondary)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  if (competencies.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Column(
                        children: [
                          Icon(AppIcons.badge, color: c.textSecondary.withValues(alpha: 0.3), size: 48),
                          const SizedBox(height: 12),
                          Text('No competencies yet',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: c.textSecondary)),
                          const SizedBox(height: 4),
                          Text('Tap + to add your first one',
                              style: TextStyle(fontSize: 12, color: c.textSecondary)),
                        ],
                      ),
                    ),

                  // Grouped competencies
                  ...grouped.entries.map((entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(entry.key,
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: c.textMuted)),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: c.surface2,
                            borderRadius: kRadiusCard,
                          ),
                          child: Column(
                            children: entry.value.asMap().entries.map((e) {
                              final i = e.key;
                              final comp = e.value;
                              final isCompleted = comp['completed'] == 1;
                              return Column(
                                children: [
                                  if (i > 0) Divider(height: 1, indent: 16, endIndent: 16, color: c.border),
                                  TapScale(
                                    onTap: () => state.toggleCompetency(comp['id'], isCompleted ? 0 : 1),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 22, height: 22,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: isCompleted ? kGreen : Colors.transparent,
                                              border: Border.all(
                                                color: isCompleted ? kGreen : c.textMuted,
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
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: isCompleted ? c.textSecondary : c.textPrimary,
                                                decoration: isCompleted ? TextDecoration.lineThrough : null,
                                              ),
                                            ),
                                          ),
                                          TapScale(
                                            onTap: () {
                                              showDialog(
                                                context: context,
                                                builder: (_) => AlertDialog(
                                                  backgroundColor: c.surface,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: kRadiusCard,
                                                    side: BorderSide(color: c.border),
                                                  ),
                                                  title: Text('Delete Competency',
                                                      style: TextStyle(fontWeight: FontWeight.w800, color: c.textPrimary)),
                                                  content: Text('Remove this item from your list?',
                                                      style: TextStyle(color: c.textSecondary)),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () => Navigator.pop(context),
                                                      child: Text('Cancel', style: TextStyle(color: c.textSecondary)),
                                                    ),
                                                    TextButton(
                                                      onPressed: () {
                                                        state.deleteCompetency(comp['id']);
                                                        Navigator.pop(context);
                                                      },
                                                      child: const Text('Delete', style: TextStyle(color: kRed, fontWeight: FontWeight.w700)),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                            child: Icon(AppIcons.deleteOutline, color: c.textMuted, size: 18),
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
                  )),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
