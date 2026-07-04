import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';

class BreakTrackingScreen extends StatefulWidget {
  const BreakTrackingScreen({super.key});

  @override
  State<BreakTrackingScreen> createState() => _BreakTrackingScreenState();
}

class _BreakTrackingScreenState extends State<BreakTrackingScreen> {
  String _selectedType = 'short';

  void _showSnack(String msg, {bool error = false}) {
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          Icon(error ? AppIcons.warning : AppIcons.checkCircle, color: error ? kRed : kGreen, size: 18),
          const SizedBox(width: 10),
          Text(msg, style: const TextStyle(color: kWhite)),
        ]),
        behavior: SnackBarBehavior.floating,
        backgroundColor: kSurface,
        shape: RoundedRectangleBorder(borderRadius: kRadiusBtn, side: const BorderSide(color: kBorder)),
      ),
    );
  }

  Future<void> _startBreak(AppState state) async {
    final result = await state.startBreak();
    if (result == 'Break started') {
      await state.setBreakType(_selectedType);
      _showSnack('$_breakTypeLabel break started');
      if (mounted) Navigator.pop(context);
    } else {
      _showSnack(result, error: true);
    }
  }

  Future<void> _endBreak(AppState state) async {
    final result = await state.endBreak();
    _showSnack(result.contains('ended') ? 'Break ended' : result, error: !result.contains('ended'));
    if (result.contains('ended') && mounted) Navigator.pop(context);
  }

  String get _breakTypeLabel {
    switch (_selectedType) {
      case 'lunch': return 'Lunch';
      case 'short': return 'Short break';
      default: return 'Break';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final isOnBreak = state.isOnBreak;
        final activeBreak = state.activeBreak;
        final totalBreakMin = state.todayBreakMinutes;

        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Break Tracker',
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
              const SizedBox(height: 8),
              Text('Today\'s break time: ${totalBreakMin}m',
                  style: const TextStyle(fontSize: 12, color: kGrey)),
              const SizedBox(height: 20),

              if (isOnBreak && activeBreak != null)
                _buildBreakActive(activeBreak)
              else
                _buildBreakStart(state),

              const SizedBox(height: 16),

              if (!isOnBreak)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Break Type', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: kWhite)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _typeChip('short', 'Short', Icons.free_breakfast),
                        const SizedBox(width: 8),
                        _typeChip('lunch', 'Lunch', Icons.restaurant),
                      ],
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBreakActive(activeBreak) {
    final duration = DateTime.now().difference(activeBreak.start);
    final mins = duration.inMinutes;
    final secs = duration.inSeconds % 60;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: kGreenGradient,
        borderRadius: kRadiusCard,
        boxShadow: kGreenGlow,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.2),
              borderRadius: kRadiusTag,
            ),
            child: const Text('● Break in Progress', style: TextStyle(color: kWhite, fontSize: 11, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 12),
          Text(
            '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}',
            style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: kWhite, fontFamily: 'Exter'),
          ),
          const SizedBox(height: 4),
          Text(
            activeBreak.type == 'lunch' ? 'Lunch Break' : 'Short Break',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: TapScale(
              onTap: () {
                final state = context.read<AppState>();
                _endBreak(state);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: kWhite,
                  borderRadius: kRadiusBtn,
                ),
                child: const Center(
                  child: Text('End Break',
                      style: TextStyle(color: kBg, fontWeight: FontWeight.w700, fontSize: 15)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakStart(AppState state) {
    if (!state.isPunchedIn) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: kSurface2,
          borderRadius: kRadiusCard,
          border: Border.all(color: kBorder),
        ),
        child: const Column(
          children: [
            Icon(AppIcons.timer, color: kGrey, size: 32),
            SizedBox(height: 8),
            Text('No active session',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: kGrey)),
            SizedBox(height: 4),
            Text('Punch in first to start tracking breaks',
                style: TextStyle(fontSize: 12, color: kGrey)),
          ],
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: TapScale(
        onTap: () => _startBreak(state),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: kGreenGradient,
            borderRadius: kRadiusBtn,
            boxShadow: kGreenGlow,
          ),
          child: const Center(
            child: Text('Start Break',
                style: TextStyle(color: kBg, fontWeight: FontWeight.w700, fontSize: 15)),
          ),
        ),
      ),
    );
  }

  Widget _typeChip(String type, String label, IconData icon) {
    final selected = _selectedType == type;
    return TapScale(
      onTap: () => setState(() => _selectedType = type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: selected ? kGreenGradient : null,
          color: selected ? null : kSurface2,
          borderRadius: kRadiusBtn,
          border: Border.all(color: selected ? kGreen : kBorder),
          boxShadow: selected ? kGreenGlow : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: selected ? kBg : kGrey),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    color: selected ? kBg : kWhite,
                    fontWeight: FontWeight.w600,
                    fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
