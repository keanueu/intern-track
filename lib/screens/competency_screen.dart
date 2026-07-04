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
    String category = 'Technical';

    showModalBottomSheet(
      context: context,
      backgroundColor: kSurface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        side: BorderSide(color: kBorder),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
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
                  const Text('Add Competency',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: kWhite)),
                  TapScale(
                    onTap: () => Navigator.pop(ctx),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(color: kSurface2, borderRadius: kRadiusTag),
                      child: const Icon(AppIcons.close, color: kGrey, size: 18),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Title', style: TextStyle(fontSize: 12, color: kGrey, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              TextField(
                controller: titleCtrl,
                style: const TextStyle(color: kWhite),
                decoration: InputDecoration(
                  hintText: 'e.g. REST API Design',
                  filled: true, fillColor: kSurface2,
                  border: OutlineInputBorder(borderRadius: kRadiusInput, borderSide: BorderSide.none),
                  enabledBorder: OutlineInputBorder(borderRadius: kRadiusInput, borderSide: const BorderSide(color: kBorder)),
                  focusedBorder: OutlineInputBorder(borderRadius: kRadiusInput, borderSide: const BorderSide(color: kGreen)),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Category', style: TextStyle(fontSize: 12, color: kGrey, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: ['Technical', 'Soft Skills', 'Domain', 'Tools', 'Process'].map((cat) {
                  final selected = category == cat;
                  return TapScale(
                    onTap: () => setSheetState(() => category = cat),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: selected ? kGreenGradient : null,
                        color: selected ? null : kSurface2,
                        borderRadius: kRadiusBtn,
                        border: Border.all(color: selected ? kGreen : kBorder),
                      ),
                      child: Text(cat,
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600,
                              color: selected ? kBg : kWhite)),
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
                    child: const Center(
                      child: Text('Add', style: TextStyle(color: kBg, fontWeight: FontWeight.w700, fontSize: 15)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final competencies = state.competencies;
        final completed = state.completedCompetencies;
        final total = state.totalCompetencies;
        final pct = state.competencyPercent;

        final grouped = <String, List<Map<String, dynamic>>>{};
        for (final c in competencies) {
          final cat = (c['category'] as String?) ?? 'Other';
          grouped.putIfAbsent(cat, () => []).add(c);
        }

        return Scaffold(
          backgroundColor: kBg,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Competencies',
                          style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800, color: kWhite)),
                      TapScale(
                        onTap: () => _addCompetency(context, state),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: kGreenGradient,
                            borderRadius: kRadiusBtn,
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(AppIcons.addPerson, color: kBg, size: 16),
                              SizedBox(width: 4),
                              Text('Add', style: TextStyle(color: kBg, fontWeight: FontWeight.w700, fontSize: 13)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text('Track your OJT skills and tasks',
                      style: TextStyle(fontSize: 14, color: kGrey)),
                  const SizedBox(height: 24),

                  // Progress card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: kSurface,
                      borderRadius: kRadiusCard,
                      border: Border.all(color: kBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Completion',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: kWhite)),
                            Text('$completed / $total',
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: kGreen)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        AnimatedGradientBar(value: pct.clamp(0.0, 1.0), height: 8),
                        const SizedBox(height: 6),
                        Text('${(pct * 100).toStringAsFixed(0)}% complete',
                            style: const TextStyle(fontSize: 11, color: kGrey)),
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
                          Icon(AppIcons.badge, color: kGrey.withValues(alpha: 0.3), size: 48),
                          const SizedBox(height: 12),
                          const Text('No competencies yet',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: kGrey)),
                          const SizedBox(height: 4),
                          const Text('Tap + to add your first one',
                              style: TextStyle(fontSize: 12, color: kGrey)),
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
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: kGreyDark)),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: kSurface2,
                            borderRadius: kRadiusCard,
                          ),
                          child: Column(
                            children: entry.value.asMap().entries.map((e) {
                              final i = e.key;
                              final c = e.value;
                              final isCompleted = c['completed'] == 1;
                              return Column(
                                children: [
                                  if (i > 0) const Divider(height: 1, indent: 16, endIndent: 16, color: kBorder),
                                  TapScale(
                                    onTap: () => state.toggleCompetency(c['id'], isCompleted ? 0 : 1),
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
                                                color: isCompleted ? kGreen : kGreyDark,
                                                width: 2,
                                              ),
                                            ),
                                            child: isCompleted
                                                ? const Icon(AppIcons.checkCircle, color: kBg, size: 14)
                                                : null,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              c['title'] ?? '',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: isCompleted ? kGrey : kWhite,
                                                decoration: isCompleted ? TextDecoration.lineThrough : null,
                                              ),
                                            ),
                                          ),
                                          TapScale(
                                            onTap: () {
                                              showDialog(
                                                context: context,
                                                builder: (_) => AlertDialog(
                                                  backgroundColor: kSurface,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: kRadiusCard,
                                                    side: const BorderSide(color: kBorder),
                                                  ),
                                                  title: const Text('Delete Competency',
                                                      style: TextStyle(fontWeight: FontWeight.w800, color: kWhite)),
                                                  content: const Text('Remove this item from your list?',
                                                      style: TextStyle(color: kGrey)),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () => Navigator.pop(context),
                                                      child: const Text('Cancel', style: TextStyle(color: kGrey)),
                                                    ),
                                                    TextButton(
                                                      onPressed: () {
                                                        state.deleteCompetency(c['id']);
                                                        Navigator.pop(context);
                                                      },
                                                      child: const Text('Delete', style: TextStyle(color: kRed, fontWeight: FontWeight.w700)),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                            child: const Icon(AppIcons.deleteOutline, color: kGreyDark, size: 18),
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
