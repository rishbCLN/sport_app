import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme/colors.dart';
import '../core/theme/typography.dart';
import '../core/widgets/holographic_card.dart';
import '../core/widgets/volt_button.dart';
import '../core/widgets/profile_orb.dart';
import '../core/widgets/ambient_particles.dart';
import '../models/user_stats.dart';
import '../services/auth_service.dart';
import '../services/user_profile_service.dart';
import 'auth/login_screen.dart';

/// PRISM Profile Hub — view and edit your player identity.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    UserProfileService.instance.addListener(_onProfileChanged);
  }

  @override
  void dispose() {
    UserProfileService.instance.removeListener(_onProfileChanged);
    super.dispose();
  }

  void _onProfileChanged() {
    if (mounted) setState(() {});
  }

  // ── Logout ─────────────────────────────────────────────────────────────

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: PrismColors.pitch,
        shape: const RoundedRectangleBorder(),
        title: Text('LOGOUT?',
            style: PrismText.label(color: PrismColors.redAlert)),
        content: Text('Your session will be cleared.', style: PrismText.body()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('CANCEL',
                style: PrismText.label(color: PrismColors.steelGray)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('LOGOUT',
                style: PrismText.label(color: PrismColors.redAlert)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await AuthService().logout();
      UserProfileService.instance.reset();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  // ── Edit sheet ─────────────────────────────────────────────────────────

  void _openEditSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _EditProfileSheet(
        profile: UserProfileService.instance.profile,
        onSave: (updated) {
          UserProfileService.instance.updateProfile(
            name: updated.name,
            mainPosition: updated.mainPosition,
            favoriteGround: updated.favoriteGround,
            rollNumber: updated.rollNumber,
            tags: updated.tags,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = UserProfileService.instance.profile;
    final vibeColor = profile.getVibeColor();

    return AmbientParticles(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: CustomScrollView(
          slivers: [
            // ── Header ───────────────────────────────────────────────────
            SliverToBoxAdapter(child: _buildHeader(profile, vibeColor)),
            // ── Stats card ────────────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              sliver: SliverToBoxAdapter(
                child: _buildStatsCard(profile, vibeColor)
                    .animate()
                    .fadeIn(duration: 300.ms)
                    .slideY(begin: 0.1, end: 0),
              ),
            ),
            // ── Tags section ──────────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              sliver: SliverToBoxAdapter(
                child: _buildTagsSection(profile)
                    .animate(delay: 60.ms)
                    .fadeIn(duration: 280.ms)
                    .slideY(begin: 0.1, end: 0),
              ),
            ),
            // ── Logout ────────────────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 28, 16, 60),
              sliver: SliverToBoxAdapter(
                child: VoltButton(
                  label: 'LOG OUT',
                  variant: VoltButtonVariant.ghost,
                  accentColor: PrismColors.redAlert,
                  fullWidth: true,
                  icon: Icons.logout,
                  onTap: _logout,
                ).animate(delay: 120.ms).fadeIn(duration: 280.ms),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header with orb + edit button ────────────────────────────────────────

  Widget _buildHeader(UserStats profile, Color vibeColor) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, MediaQuery.of(context).padding.top + 16, 20, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            vibeColor.withOpacity(0.10),
            PrismColors.abyss,
            PrismColors.cyanBlitz.withOpacity(0.04),
          ],
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          ProfileOrb(
            name: profile.name,
            photoUrl: profile.photoUrl,
            ringColor: vibeColor,
            isActive: true,
            size: 64,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  profile.name.toUpperCase(),
                  style: PrismText.hero(color: PrismColors.ghostWhite)
                      .copyWith(fontSize: 28),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: vibeColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                              color: vibeColor.withOpacity(0.7),
                              blurRadius: 6),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      profile.mainPosition.isEmpty
                          ? 'POSITION UNSET'
                          : profile.mainPosition.toUpperCase(),
                      style: PrismText.label(color: vibeColor)
                          .copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // ── Edit button in header ─────────────────────────────────────
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              _openEditSheet();
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: PrismColors.concrete,
                border: Border.all(
                    color: PrismColors.voltGreen.withOpacity(0.4), width: 1),
              ),
              child: const Icon(Icons.edit_outlined,
                  color: PrismColors.voltGreen, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  // ── Stats card ────────────────────────────────────────────────────────────

  Widget _buildStatsCard(UserStats profile, Color vibeColor) {
    return HolographicCard(
      accentColor: vibeColor,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('PLAYER PROFILE',
                  style: PrismText.label(color: vibeColor)
                      .copyWith(fontSize: 10)),
              const Spacer(),
              // ── Edit button on card ─────────────────────────────────
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  _openEditSheet();
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: PrismColors.voltGreen.withOpacity(0.10),
                    border: Border.all(
                        color: PrismColors.voltGreen.withOpacity(0.45),
                        width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.edit_outlined,
                          color: PrismColors.voltGreen, size: 12),
                      const SizedBox(width: 5),
                      Text('EDIT',
                          style: PrismText.tag(color: PrismColors.voltGreen)
                              .copyWith(fontSize: 10)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (profile.rollNumber.isNotEmpty)
            _InfoRow(
                label: 'ROLL NO.',
                value: profile.rollNumber,
                color: PrismColors.cyanBlitz),
          if (profile.rollNumber.isNotEmpty) const SizedBox(height: 10),
          _InfoRow(
              label: 'POSITION',
              value: profile.mainPosition.isEmpty
                  ? '—'
                  : profile.mainPosition,
              color: vibeColor),
          const SizedBox(height: 10),
          _InfoRow(
              label: 'FAV. GROUND',
              value: profile.favoriteGround,
              color: PrismColors.amberShock),
        ],
      ),
    );
  }

  // ── Tags section ──────────────────────────────────────────────────────────

  Widget _buildTagsSection(UserStats profile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('PLAYER TAGS', style: PrismText.label()),
            const SizedBox(width: 8),
            Text('${profile.tags.length} TAGS',
                style: PrismText.caption(color: PrismColors.dimGray)
                    .copyWith(fontSize: 10)),
            const Spacer(),
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                _openEditSheet();
              },
              child: Text('MANAGE →',
                  style: PrismText.label(color: PrismColors.voltGreen)
                      .copyWith(fontSize: 10)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (profile.tags.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: PrismColors.concrete,
              border: Border.all(
                  color: PrismColors.dimGray.withOpacity(0.4), width: 1),
            ),
            child: Text('No tags yet — tap MANAGE to add',
                style: PrismText.body(), textAlign: TextAlign.center),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: profile.tags.asMap().entries.map((e) {
              final tag = e.value;
              final color = tagColor(tag);
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.10),
                  border:
                      Border.all(color: color.withOpacity(0.45), width: 1),
                ),
                child: Text(tag.toUpperCase(),
                    style: PrismText.tag(color: color)),
              )
                  .animate(delay: Duration(milliseconds: e.key * 40))
                  .fadeIn(duration: 200.ms)
                  .scale(begin: const Offset(0.85, 0.85));
            }).toList(),
          ),
      ],
    );
  }
}

// ── Info row helper ───────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 110,
          child: Text(label,
              style: PrismText.label(color: PrismColors.dimGray)
                  .copyWith(fontSize: 10)),
        ),
        Expanded(
          child: Text(value, style: PrismText.subtitle(color: color)),
        ),
      ],
    );
  }
}

// ── Edit profile bottom sheet ─────────────────────────────────────────────────

class _EditProfileSheet extends StatefulWidget {
  final UserStats profile;
  final void Function(UserStats updated) onSave;

  const _EditProfileSheet({required this.profile, required this.onSave});

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _rollCtrl;
  late final TextEditingController _customTagCtrl;
  late String _position;
  late String _ground;
  late List<String> _tags;

  static const _positions = [
    'Striker', 'Midfielder', 'Defender', 'Goalkeeper', 'Winger',
  ];
  static const _grounds = ['Sand Ground', 'Hard Ground'];
  static const _presetTags = [
    '#CLUTCH', '#TEAM PLAYER', '#EARLY BIRD', '#CONSISTENT', '#NO CAP',
    '#CAPTAIN', '#BUILT DIFFERENT', '#SLEDGER', '#BALL HOG', '#RAGE QUITTER',
    '#LATE', '#SWEATY', '#CARRYING', '#MID', '#CHILL', '#NPC', '#EXCUSE KING',
  ];

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.profile.name);
    _rollCtrl = TextEditingController(text: widget.profile.rollNumber);
    _customTagCtrl = TextEditingController();
    _position = widget.profile.mainPosition.isEmpty
        ? _positions.first
        : widget.profile.mainPosition;
    _ground = widget.profile.favoriteGround.isEmpty
        ? _grounds.first
        : widget.profile.favoriteGround;
    _tags = List<String>.from(widget.profile.tags);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _rollCtrl.dispose();
    _customTagCtrl.dispose();
    super.dispose();
  }

  void _toggleTag(String tag) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_tags.contains(tag)) {
        _tags.remove(tag);
      } else {
        _tags.add(tag);
      }
    });
  }

  void _addCustomTag() {
    final raw = _customTagCtrl.text.trim();
    if (raw.isEmpty) return;
    final tag = raw.startsWith('#')
        ? raw.toUpperCase()
        : '#${raw.toUpperCase()}';
    if (!_tags.contains(tag)) setState(() => _tags.add(tag));
    _customTagCtrl.clear();
    HapticFeedback.lightImpact();
  }

  void _save() {
    final name = _nameCtrl.text.trim();
    final updated = widget.profile.copyWith(
      name: name.isEmpty ? widget.profile.name : name,
      mainPosition: _position,
      favoriteGround: _ground,
      rollNumber: _rollCtrl.text.trim(),
      tags: _tags,
    );
    widget.onSave(updated);
    HapticFeedback.mediumImpact();
    Navigator.of(context).pop();
  }

  Widget _sectionLabel(String label) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(label,
            style: PrismText.label(color: PrismColors.steelGray)
                .copyWith(fontSize: 10)),
      );

  Widget _inputField(TextEditingController ctrl, String hint,
      {TextCapitalization caps = TextCapitalization.words}) {
    return Container(
      decoration: BoxDecoration(
        color: PrismColors.concrete,
        border: Border.all(
            color: PrismColors.dimGray.withOpacity(0.8), width: 1),
      ),
      child: TextField(
        controller: ctrl,
        textCapitalization: caps,
        style: PrismText.body(color: PrismColors.ghostWhite),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          hintText: hint,
          hintStyle: PrismText.body(color: PrismColors.dimGray),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: PrismColors.pitch,
        border: Border(
          top: BorderSide(color: PrismColors.voltGreen, width: 1),
          left: BorderSide(color: Color(0x2200FF41), width: 1),
          right: BorderSide(color: Color(0x2200FF41), width: 1),
        ),
      ),
      padding: EdgeInsets.fromLTRB(20, 20, 20, viewInset + 24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle + title
            Center(
              child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  width: 36,
                  height: 3,
                  color: PrismColors.concrete),
            ),
            Row(
              children: [
                Text('EDIT PROFILE',
                    style: PrismText.hero(color: PrismColors.ghostWhite)
                        .copyWith(fontSize: 22)),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Icon(Icons.close,
                      color: PrismColors.steelGray, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Display name
            _sectionLabel('DISPLAY NAME'),
            _inputField(_nameCtrl, 'Your name...'),
            const SizedBox(height: 20),

            // Roll number
            _sectionLabel('ROLL NUMBER'),
            _inputField(_rollCtrl, 'e.g. 22BCE1234',
                caps: TextCapitalization.characters),
            const SizedBox(height: 20),

            // Position chips
            _sectionLabel('MAIN POSITION'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _positions.map((p) {
                final active = _position == p;
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _position = p);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: active
                          ? PrismColors.voltGreen.withOpacity(0.12)
                          : PrismColors.concrete,
                      border: Border.all(
                        color: active
                            ? PrismColors.voltGreen
                            : PrismColors.dimGray,
                        width: active ? 1.5 : 1,
                      ),
                      boxShadow: active
                          ? [
                              BoxShadow(
                                  color: PrismColors.voltGreen
                                      .withOpacity(0.25),
                                  blurRadius: 10),
                            ]
                          : null,
                    ),
                    child: Text(p.toUpperCase(),
                        style: PrismText.tag(
                            color: active
                                ? PrismColors.voltGreen
                                : PrismColors.steelGray)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Ground selection
            _sectionLabel('FAVOURITE GROUND'),
            Row(
              children: _grounds.map((g) {
                final active = _ground == g;
                final color = g == 'Sand Ground'
                    ? PrismColors.voltGreen
                    : PrismColors.cyanBlitz;
                final isFirst = g == _grounds.first;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: isFirst ? 8 : 0),
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _ground = g);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        height: 52,
                        decoration: BoxDecoration(
                          color: active
                              ? color.withOpacity(0.10)
                              : PrismColors.concrete,
                          border: Border.all(
                            color: active ? color : PrismColors.dimGray,
                            width: active ? 1.5 : 1,
                          ),
                          boxShadow: active
                              ? [
                                  BoxShadow(
                                      color: color.withOpacity(0.25),
                                      blurRadius: 12),
                                ]
                              : null,
                        ),
                        child: Center(
                          child: Text(g.toUpperCase(),
                              style: PrismText.tag(
                                  color: active
                                      ? color
                                      : PrismColors.steelGray)),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Preset tags
            _sectionLabel('PLAYER TAGS  (tap to toggle)'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _presetTags.map((tag) {
                final active = _tags.contains(tag);
                final color = tagColor(tag);
                return GestureDetector(
                  onTap: () => _toggleTag(tag),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: active
                          ? color.withOpacity(0.15)
                          : PrismColors.concrete,
                      border: Border.all(
                        color: active ? color : PrismColors.dimGray,
                        width: active ? 1.5 : 1,
                      ),
                      boxShadow: active
                          ? [
                              BoxShadow(
                                  color: color.withOpacity(0.3),
                                  blurRadius: 8),
                            ]
                          : null,
                    ),
                    child: Text(tag,
                        style: PrismText.tag(
                                color: active
                                    ? color
                                    : PrismColors.steelGray)
                            .copyWith(fontSize: 11)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Custom tag input
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: PrismColors.concrete,
                      border: Border.all(
                          color: PrismColors.dimGray.withOpacity(0.8),
                          width: 1),
                    ),
                    child: TextField(
                      controller: _customTagCtrl,
                      textCapitalization: TextCapitalization.characters,
                      style: PrismText.body(color: PrismColors.ghostWhite),
                      onSubmitted: (_) => _addCustomTag(),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        hintText: 'Add custom tag...',
                        hintStyle:
                            PrismText.body(color: PrismColors.dimGray),
                        prefixText: '#  ',
                        prefixStyle: PrismText.mono(
                            fontSize: 14, color: PrismColors.voltGreen),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _addCustomTag,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: PrismColors.voltGreen.withOpacity(0.12),
                      border: Border.all(
                          color: PrismColors.voltGreen.withOpacity(0.5),
                          width: 1),
                    ),
                    child: const Icon(Icons.add,
                        color: PrismColors.voltGreen, size: 20),
                  ),
                ),
              ],
            ),

            // Active custom (non-preset) tags
            if (_tags.any((t) => !_presetTags.contains(t))) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _tags
                    .where((t) => !_presetTags.contains(t))
                    .map((tag) {
                  return GestureDetector(
                    onTap: () => _toggleTag(tag),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: tagColor(tag).withOpacity(0.15),
                        border: Border.all(
                            color: tagColor(tag).withOpacity(0.5),
                            width: 1.5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(tag,
                              style: PrismText.tag(color: tagColor(tag))
                                  .copyWith(fontSize: 11)),
                          const SizedBox(width: 5),
                          Icon(Icons.close,
                              color: tagColor(tag).withOpacity(0.7),
                              size: 11),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],

            const SizedBox(height: 28),
            VoltButton(
              label: 'SAVE CHANGES ⚡',
              accentColor: PrismColors.voltGreen,
              fullWidth: true,
              height: 50,
              onTap: _save,
            ),
          ],
        ),
      ),
    );
  }
}
