import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/widgets/holographic_card.dart';
import '../../../core/widgets/volt_button.dart';
import '../../../core/widgets/confetti_overlay.dart';
import '../../../core/utils/custom_clippers.dart';

/// Full-screen takeover modal for creating a new football team request.
///
/// 2-step flow:
/// Step 1 — Select ground + players needed
/// Step 2 — Summary + CREATE TEAM
class TeamCreationModal extends StatefulWidget {
  final void Function(int ground, int playersNeeded) onTeamCreated;

  const TeamCreationModal({Key? key, required this.onTeamCreated})
      : super(key: key);

  @override
  State<TeamCreationModal> createState() => _TeamCreationModalState();
}

class _TeamCreationModalState extends State<TeamCreationModal>
    with SingleTickerProviderStateMixin {
  int _step = 1;
  int? _selectedGround;
  int? _selectedPlayers;

  late final AnimationController _stepCtrl;

  @override
  void initState() {
    super.initState();
    _stepCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    )..forward();
  }

  @override
  void dispose() {
    _stepCtrl.dispose();
    super.dispose();
  }

  bool get _step1Valid =>
      _selectedGround != null && _selectedPlayers != null;

  Future<void> _nextStep() async {
    if (!_step1Valid) return;
    await _stepCtrl.reverse();
    setState(() => _step = 2);
    _stepCtrl.forward();
  }

  Future<void> _createTeam() async {
    widget.onTeamCreated(_selectedGround!, _selectedPlayers!);
    // Show confetti celebration
    await ConfettiOverlay.show(
      context,
      winnerName: 'TEAM CREATED',
      accentColor: PrismColors.voltGreen,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        margin: EdgeInsets.fromLTRB(
          16,
          MediaQuery.of(context).padding.top + 20,
          16,
          MediaQuery.of(context).padding.bottom + 20,
        ),
        decoration: BoxDecoration(
          color: PrismColors.pitch,
          border: Border.all(
            color: PrismColors.voltGreen.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Modal header ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'STEP $_step / 2',
                          style: PrismText.label(
                              color: PrismColors.voltGreen
                                  .withOpacity(0.6)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _step == 1
                              ? 'FORM YOUR SQUAD'
                              : 'CONFIRM & DEPLOY',
                          style: PrismText.hero(
                              color: PrismColors.ghostWhite)
                              .copyWith(fontSize: 26),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    color: PrismColors.steelGray,
                  ),
                ],
              ),
            ),
            // Progress bar
            Stack(
              children: [
                Container(height: 2, color: PrismColors.concrete),
                AnimatedFractionallySizedBox(
                  widthFactor: _step / 2,
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    height: 2,
                    color: PrismColors.voltGreen,
                    foregroundDecoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: PrismColors.voltGreen.withOpacity(0.6),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // ── Step content ───────────────────────────────────────────────
            Expanded(
              child: AnimatedBuilder(
                animation: _stepCtrl,
                builder: (_, child) => FadeTransition(
                  opacity: _stepCtrl,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.05, 0),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: _stepCtrl,
                      curve: Curves.easeOutCubic,
                    )),
                    child: child,
                  ),
                ),
                child: _step == 1
                    ? _buildStep1()
                    : _buildStep2(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Step 1: Ground + Player count ─────────────────────────────────────────

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('SELECT GROUND', style: PrismText.label()),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _GroundSelector(
                  label: 'SAND GROUND',
                  subtitle: 'Natural surface',
                  emoji: '🏖️',
                  value: 1,
                  selected: _selectedGround == 1,
                  accentColor: PrismColors.voltGreen,
                  onTap: () =>
                      setState(() => _selectedGround = 1),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _GroundSelector(
                  label: 'HARD GROUND',
                  subtitle: 'Concrete pitch',
                  emoji: '🏟️',
                  value: 2,
                  selected: _selectedGround == 2,
                  accentColor: PrismColors.cyanBlitz,
                  onTap: () =>
                      setState(() => _selectedGround = 2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Text('PLAYERS NEEDED', style: PrismText.label()),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: List.generate(5, (i) {
              final n = i + 1;
              final active = _selectedPlayers == n;
              return GestureDetector(
                onTap: () =>
                    setState(() => _selectedPlayers = n),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: active
                        ? PrismColors.voltGreen.withOpacity(0.15)
                        : PrismColors.concrete,
                    border: Border.all(
                      color: active
                          ? PrismColors.voltGreen
                          : PrismColors.dimGray,
                      width: active ? 2 : 1,
                    ),
                    boxShadow: active
                        ? [
                            BoxShadow(
                              color: PrismColors.voltGreen
                                  .withOpacity(0.3),
                              blurRadius: 12,
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      '$n',
                      style: PrismText.mono(
                        fontSize: 22,
                        color: active
                            ? PrismColors.voltGreen
                            : PrismColors.steelGray,
                      ),
                    ),
                  ),
                ),
              )
                  .animate(delay: Duration(milliseconds: i * 40))
                  .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1))
                  .fadeIn();
            }),
          ),
          const SizedBox(height: 40),
          VoltButton(
            label: 'NEXT: CONFIRM →',
            fullWidth: true,
            onTap: _step1Valid ? _nextStep : null,
          ),
        ],
      ),
    );
  }

  // ── Step 2: Summary & confirm ─────────────────────────────────────────────

  Widget _buildStep2() {
    final groundName =
        _selectedGround == 1 ? 'SAND GROUND' : 'HARD GROUND';
    final accent = _selectedGround == 1
        ? PrismColors.voltGreen
        : PrismColors.cyanBlitz;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('SQUAD SUMMARY', style: PrismText.label()),
          const SizedBox(height: 16),
          HolographicCard(
            accentColor: accent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SummaryRow(
                  label: 'GROUND',
                  value: groundName,
                  color: accent,
                ),
                const SizedBox(height: 12),
                _SummaryRow(
                  label: 'LOOKING FOR',
                  value:
                      '$_selectedPlayers MORE PLAYER${_selectedPlayers! > 1 ? 'S' : ''}',
                  color: accent,
                ),
                const SizedBox(height: 12),
                _SummaryRow(
                  label: 'EXPIRES IN',
                  value: '30 MINUTES',
                  color: PrismColors.amberShock,
                ),
                const SizedBox(height: 12),
                _SummaryRow(
                  label: 'STATUS',
                  value: 'BROADCAST TO ALL PLAYERS',
                  color: PrismColors.voltGreen,
                ),
              ],
            ),
          ),
          const Spacer(),
          Row(
            children: [
              VoltButton(
                label: '← BACK',
                variant: VoltButtonVariant.ghost,
                onTap: () async {
                  await _stepCtrl.reverse();
                  setState(() => _step = 1);
                  _stepCtrl.forward();
                },
              ),
              const SizedBox(width: 12),
              Expanded(
                child: VoltButton(
                  label: 'DEPLOY TEAM ⚡',
                  fullWidth: true,
                  onTap: _createTeam,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Helper widgets ────────────────────────────────────────────────────────────

class _GroundSelector extends StatefulWidget {
  final String label;
  final String subtitle;
  final String emoji;
  final int value;
  final bool selected;
  final Color accentColor;
  final VoidCallback onTap;

  const _GroundSelector({
    required this.label,
    required this.subtitle,
    required this.emoji,
    required this.value,
    required this.selected,
    required this.accentColor,
    required this.onTap,
  });

  @override
  State<_GroundSelector> createState() => _GroundSelectorState();
}

class _GroundSelectorState extends State<_GroundSelector>
    with SingleTickerProviderStateMixin {
  late final AnimationController _glowCtrl;

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    super.dispose();
  }

  void _handleTap() {
    widget.onTap();
    _glowCtrl.forward().then((_) => _glowCtrl.reverse());
  }

  @override
  Widget build(BuildContext context) {
    final columnChild = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(widget.emoji, style: const TextStyle(fontSize: 32)),
        const SizedBox(height: 8),
        Text(
          widget.label,
          style: PrismText.tag(
            color: widget.selected
                ? widget.accentColor
                : PrismColors.ghostWhite,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          widget.subtitle,
          style: PrismText.caption(color: PrismColors.steelGray),
          textAlign: TextAlign.center,
        ),
      ],
    );

    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _glowCtrl,
        builder: (_, child) {
          final glowPulse = _glowCtrl.value;
          final effectiveOpacity = widget.selected
              ? (0.25 + glowPulse * 0.4)
              : glowPulse * 0.55;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            height: 120,
            decoration: BoxDecoration(
              color: widget.selected
                  ? widget.accentColor.withOpacity(0.1)
                  : PrismColors.concrete,
              border: Border.all(
                color: widget.selected
                    ? widget.accentColor
                    : PrismColors.dimGray,
                width: widget.selected ? 2 : 1,
              ),
              boxShadow: effectiveOpacity > 0.01
                  ? [
                      BoxShadow(
                        color: widget.accentColor
                            .withOpacity(effectiveOpacity),
                        blurRadius: 16 + glowPulse * 20,
                        spreadRadius: 1 + glowPulse * 2,
                      ),
                    ]
                  : null,
            ),
            child: child,
          );
        },
        child: columnChild,
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryRow({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(label, style: PrismText.label(color: PrismColors.dimGray).copyWith(fontSize: 10)),
        ),
        Expanded(
          child: Text(value,
              style: PrismText.subtitle(color: color)
                  .copyWith(fontSize: 14)),
        ),
      ],
    );
  }
}
