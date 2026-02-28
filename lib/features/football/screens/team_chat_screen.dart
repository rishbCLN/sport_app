import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/widgets/holographic_card.dart';
import '../../../core/widgets/volt_button.dart';
import '../../../core/widgets/prism_widgets.dart';
import '../../../core/utils/custom_clippers.dart';
import '../../../models/team_request.dart';
import '../../../models/user_stats.dart';

// expose for parent
class ChatMessage {
  final String senderId;
  final String senderName;
  final String text;
  final DateTime timestamp;

  ChatMessage({
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.timestamp,
  });
}

/// PRISM cinematic team chat screen.
///
/// Features:
/// * Glassmorphism header with countdown
/// * Parallelogram message bubbles
/// * Role tag chips on sender names
/// * Volt-button send with haptic burst
class TeamChatScreen extends StatefulWidget {
  final TeamRequest teamRequest;
  final UserStats currentUser;
  final List<dynamic> initialMessages; // _ChatMessage instances
  final void Function(String text) onMessageSent;

  const TeamChatScreen({
    Key? key,
    required this.teamRequest,
    required this.currentUser,
    required this.initialMessages,
    required this.onMessageSent,
  }) : super(key: key);

  @override
  State<TeamChatScreen> createState() => _TeamChatScreenState();
}

class _TeamChatScreenState extends State<TeamChatScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _textCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  final List<_LocalMsg> _messages = [];
  late Duration _remaining;
  Timer? _countdownTimer;
  late final AnimationController _headerPulseCtrl;

  final Color _accent;

  _TeamChatScreenState()
      : _accent = PrismColors.voltGreen; // init in initState below

  @override
  void initState() {
    super.initState();

    // Build initial messages from parent
    for (final m in widget.initialMessages) {
      try {
        _messages.add(_LocalMsg(
          isOwn: m.senderId == widget.currentUser.userId,
          senderName: m.senderName as String,
          text: m.text as String,
          timestamp: m.timestamp as DateTime,
        ));
      } catch (_) {}
    }

    // Countdown timer (30-min team lifespan)
    final age =
        DateTime.now().difference(widget.teamRequest.createdAt);
    _remaining =
        Duration(minutes: 30) - age;
    if (_remaining.isNegative) _remaining = Duration.zero;

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        if (_remaining.inSeconds > 0) {
          _remaining -= const Duration(seconds: 1);
        } else {
          _countdownTimer?.cancel();
        }
      });
    });

    _headerPulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    _scrollCtrl.dispose();
    _countdownTimer?.cancel();
    _headerPulseCtrl.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _textCtrl.text.trim();
    if (text.isEmpty) return;
    HapticFeedback.lightImpact();
    setState(() {
      _messages.add(_LocalMsg(
        isOwn: true,
        senderName: widget.currentUser.name,
        text: text,
        timestamp: DateTime.now(),
      ));
    });
    _textCtrl.clear();
    widget.onMessageSent(text);
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  bool get _isLowTime => _remaining.inMinutes < 5;
  Color get _accentColor => widget.teamRequest.groundNumber == 1
      ? PrismColors.voltGreen
      : PrismColors.cyanBlitz;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PrismColors.abyss,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(child: _buildMessages()),
          _buildComposer(),
        ],
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return AnimatedBuilder(
      animation: _headerPulseCtrl,
      builder: (_, __) {
        return Container(
          decoration: BoxDecoration(
            color: PrismColors.pitch.withOpacity(0.95),
            border: Border(
              bottom: BorderSide(
                color: _isLowTime
                    ? PrismColors.redAlert.withOpacity(
                        0.3 + _headerPulseCtrl.value * 0.4)
                    : _accentColor.withOpacity(0.25),
                width: 1,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: (_isLowTime
                        ? PrismColors.redAlert
                        : _accentColor)
                    .withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 8,
            bottom: 12,
            left: 8,
            right: 16,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new,
                        size: 18),
                    color: PrismColors.ghostWhite,
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.teamRequest.groundNumber == 1
                              ? 'SAND GROUND SQUAD'
                              : 'HARD GROUND SQUAD',
                          style: PrismText.title(
                              color: PrismColors.ghostWhite)
                              .copyWith(fontSize: 16),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              '${widget.teamRequest.currentPlayers}/${widget.teamRequest.playersNeeded + 1} MEMBERS',
                              style: PrismText.caption(
                                  color: PrismColors.steelGray),
                            ),
                            const SizedBox(width: 10),
                            if (_isLowTime)
                              LiveBadge()
                            else
                              Container(
                                width: 5,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: _accentColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert, size: 20),
                    color: PrismColors.steelGray,
                    onPressed: () {},
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: CountdownBar(
                  remaining: _remaining,
                  total: const Duration(minutes: 30),
                  color: _isLowTime ? null : _accentColor,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Messages ──────────────────────────────────────────────────────────────

  Widget _buildMessages() {
    if (_messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('⚡', style: const TextStyle(fontSize: 40)),
            const SizedBox(height: 12),
            Text(
              'SQUAD IS ASSEMBLED',
              style: PrismText.label(color: _accentColor),
            ),
            const SizedBox(height: 6),
            Text(
              'First message deploys below',
              style: PrismText.body(),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollCtrl,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: _messages.length,
      itemBuilder: (ctx, i) =>
          _buildBubble(_messages[i], i)
              .animate(delay: Duration(milliseconds: i * 30))
              .fadeIn(duration: 250.ms)
              .slideX(
                  begin: _messages[i].isOwn ? 0.06 : -0.06,
                  end: 0,
                  curve: Curves.easeOutCubic),
    );
  }

  Widget _buildBubble(_LocalMsg msg, int idx) {
    final isOwn = msg.isOwn;
    final accent = isOwn ? _accentColor : PrismColors.cyanBlitz;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment:
            isOwn ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isOwn) ...[
            // Other sender dot
            Container(
              width: 28,
              height: 28,
              margin: const EdgeInsets.only(right: 6, bottom: 2),
              decoration: BoxDecoration(
                color: PrismColors.concrete,
                border: Border.all(
                    color: PrismColors.cyanBlitz.withOpacity(0.4),
                    width: 1),
              ),
              child: Center(
                child: Text(
                  msg.senderName.isNotEmpty
                      ? msg.senderName[0].toUpperCase()
                      : '?',
                  style: PrismText.tag(
                      color: PrismColors.cyanBlitz)
                      .copyWith(fontSize: 12),
                ),
              ),
            ),
          ],
          Flexible(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.72,
              ),
              child: ClipPath(
                clipper: ParallelogramClipper(
                    skew: isOwn ? 6 : -6),
                child: Container(
                  decoration: BoxDecoration(
                    color: isOwn
                        ? accent.withOpacity(0.12)
                        : PrismColors.pitch,
                    border: Border.all(
                      color: accent.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(
                      12, 8, 12, 8),
                  child: Column(
                    crossAxisAlignment: isOwn
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      if (!isOwn) ...[
                        Text(
                          msg.senderName.toUpperCase(),
                          style: PrismText.tag(
                                  color: PrismColors.cyanBlitz)
                              .copyWith(fontSize: 10),
                        ),
                        const SizedBox(height: 3),
                      ],
                      Text(
                        msg.text,
                        style: PrismText.body(
                            color: PrismColors.ghostWhite),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _timeLabel(msg.timestamp),
                        style: PrismText.caption(
                            color:
                                PrismColors.dimGray),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (isOwn) ...[
            Container(
              width: 28,
              height: 28,
              margin: const EdgeInsets.only(left: 6, bottom: 2),
              decoration: BoxDecoration(
                color: _accentColor.withOpacity(0.12),
                border: Border.all(
                    color: _accentColor.withOpacity(0.4), width: 1),
              ),
              child: Center(
                child: Text(
                  msg.senderName.isNotEmpty
                      ? msg.senderName[0].toUpperCase()
                      : '?',
                  style: PrismText.tag(color: _accentColor)
                      .copyWith(fontSize: 12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _timeLabel(DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inSeconds < 60) return 'NOW';
    if (diff.inMinutes == 1) return '1M AGO';
    return '${diff.inMinutes}M AGO';
  }

  // ── Composer ──────────────────────────────────────────────────────────────

  Widget _buildComposer() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        12,
        10,
        12,
        MediaQuery.of(context).padding.bottom + 10,
      ),
      decoration: BoxDecoration(
        color: PrismColors.pitch.withOpacity(0.96),
        border: Border(
          top: BorderSide(
              color: PrismColors.concrete, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Input field
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: PrismColors.concrete,
                border: Border.all(
                    color: PrismColors.dimGray, width: 1),
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14),
              child: TextField(
                controller: _textCtrl,
                style: PrismText.body(
                    color: PrismColors.ghostWhite),
                maxLines: null,
                textCapitalization:
                    TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Type message...',
                  hintStyle: PrismText.body(
                      color: PrismColors.dimGray),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 12),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Send button
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _textCtrl,
            builder: (_, val, __) {
              final hasText = val.text.trim().isNotEmpty;
              return VoltButton(
                label: '⚡',
                onTap: hasText ? _sendMessage : null,
                accentColor: _accentColor,
                height: 48,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _LocalMsg {
  final bool isOwn;
  final String senderName;
  final String text;
  final DateTime timestamp;

  _LocalMsg({
    required this.isOwn,
    required this.senderName,
    required this.text,
    required this.timestamp,
  });
}
