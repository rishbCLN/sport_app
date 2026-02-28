import 'package:flutter/material.dart';
import '../../models/tournament.dart';
import '../../services/tournament_service.dart';
import '../../services/auth_service.dart';

class TournamentCreationWizard extends StatefulWidget {
  const TournamentCreationWizard({Key? key}) : super(key: key);

  @override
  State<TournamentCreationWizard> createState() => _TournamentCreationWizardState();
}

class _TournamentCreationWizardState extends State<TournamentCreationWizard> {
  int _step = 0;
  final _formKeys = List.generate(5, (_) => GlobalKey<FormState>());

  final _nameCtrl = TextEditingController();
  String? _sport;
  String? _venue;
  DateTime? _startDate;
  DateTime? _endDate;
  DateTime? _regOpen;
  DateTime? _regDeadline;
  String? _format;
  int _maxTeams = 8;
  int _matchDuration = 15;
  final _prizePoolCtrl = TextEditingController();
  final _firstPrizeCtrl = TextEditingController();
  final _secondPrizeCtrl = TextEditingController();
  final _thirdPrizeCtrl = TextEditingController();
  final _rulesCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  bool _confirm = false;
  bool _publish = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _prizePoolCtrl.dispose();
    _firstPrizeCtrl.dispose();
    _secondPrizeCtrl.dispose();
    _thirdPrizeCtrl.dispose();
    _rulesCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (!_validateStep(_step)) return;
    if (_step < 4) {
      setState(() => _step++);
    }
  }

  void _back() {
    if (_step > 0) setState(() => _step--);
  }

  Future<void> _pickDate(ValueChanged<DateTime> onPicked, {DateTime? initial}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial ?? now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) onPicked(picked);
  }

  void _publishTournament() {
    if (!_validateStep(_step)) return;

    final now = DateTime.now();
    final id = TournamentService.instance.generateId();
    final status = _computeStatus(now);

    final tournament = Tournament(
      id: id,
      name: _nameCtrl.text.trim(),
      sport: _sport ?? 'Football',
      format: _format ?? 'Single Elimination',
      startDate: _startDate!,
      endDate: _endDate!,
      registrationDeadline: _regDeadline ?? _startDate!,
      maxTeams: _maxTeams,
      currentTeams: 0,
      registeredTeamIds: const [],
      status: status,
      matchSchedule: const [],
      bracket: const {},
      winners: const [],
      createdBy: AuthService().currentUserId ?? 'admin_001',
      createdAt: now,
      prizePool: _prizePoolCtrl.text.isEmpty ? null : _prizePoolCtrl.text,
      rules: _rulesCtrl.text.isEmpty ? null : _rulesCtrl.text,
      venue: _venue ?? 'Sand Ground',
    );

    TournamentService.instance.addTournament(tournament);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tournament created successfully!')),
    );
    Navigator.pop(context);
  }

  bool _validateStep(int step) {
    switch (step) {
      case 0:
        final formValid = _formKeys[0].currentState?.validate() ?? false;
        final requiredSelections = _sport != null && _venue != null;
        if (!requiredSelections) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Select sport and venue to proceed')), 
          );
        }
        return formValid && requiredSelections;
      case 1:
        final hasDates = _startDate != null && _endDate != null && _regDeadline != null;
        if (!hasDates) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Select all dates to proceed')),
          );
          return false;
        }
        if (_startDate!.isBefore(DateTime.now())) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Start date must be in the future')),
          );
          return false;
        }
        if (_endDate!.isBefore(_startDate!)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('End date must be after start date')),
          );
          return false;
        }
        if (_regDeadline!.isAfter(_startDate!)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registration deadline must be before start date')),
          );
          return false;
        }
        return true;
      case 2:
        if (_format == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Select a format to proceed')),
          );
          return false;
        }
        return true;
      case 3:
        _formKeys[3].currentState?.validate();
        return true;
      case 4:
        if (!_confirm) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please confirm details before publishing')),
          );
          return false;
        }
        return true;
      default:
        return true;
    }
  }

  String _computeStatus(DateTime now) {
    if (_regDeadline != null && now.isBefore(_regDeadline!)) {
      return 'registration_open';
    }
    if (now.isBefore(_startDate!)) {
      return 'upcoming';
    }
    if (now.isAfter(_endDate!)) {
      return 'completed';
    }
    return 'ongoing';
  }

  @override
  Widget build(BuildContext context) {
    final steps = [
      _stepCard('Step 1 of 5 - Basic Information', 0, _basicInfo()),
      _stepCard('Step 2 of 5 - Tournament Schedule', 1, _schedule()),
      _stepCard('Step 3 of 5 - Tournament Format', 2, _formatSelection()),
      _stepCard('Step 4 of 5 - Prizes & Rules', 3, _prizes()),
      _stepCard('Step 5 of 5 - Review & Publish', 4, _review()),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Host Tournament'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bottomInset = MediaQuery.of(context).viewInsets.bottom;
          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(16, 16, 16, bottomInset + 16),
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - bottomInset,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  LinearProgressIndicator(value: (_step + 1) / 5),
                  const SizedBox(height: 16),
                  steps[_step],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (_step > 0)
                        OutlinedButton(onPressed: _back, child: const Text('Back')),
                      const Spacer(),
                      if (_step < 4)
                        ElevatedButton(onPressed: _next, child: const Text('Next'))
                      else
                        ElevatedButton(
                          onPressed: _confirm ? _publishTournament : null,
                          child: const Text('Publish Tournament'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _stepCard(String title, int index, Widget child) {
    return Card(
      color: Colors.white10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKeys[index],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              child,
            ],
          ),
        ),
      ),
    );
  }

  Widget _basicInfo() {
    return Column(
      children: [
        TextFormField(
          controller: _nameCtrl,
          decoration: const InputDecoration(
            labelText: 'Tournament Name',
            hintText: 'e.g., VIT Inter-Hostel Cup 2024',
          ),
          validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
        ),
        const SizedBox(height: 12),
        _pillSelector(
          title: 'Sport',
          options: const ['Football', 'Badminton', 'Cricket'],
          current: _sport,
          onSelect: (v) => setState(() => _sport = v),
          validator: () => _sport == null ? 'Select a sport' : null,
        ),
        const SizedBox(height: 12),
        _pillSelector(
          title: 'Venue/Ground',
          options: const ['Sand Ground', 'Hard Ground', 'Both Grounds'],
          current: _venue,
          onSelect: (v) => setState(() => _venue = v),
          validator: () => _venue == null ? 'Select a venue' : null,
        ),
      ],
    );
  }

  Widget _schedule() {
    return Column(
      children: [
        _dateRow('Start Date', _startDate, (d) => setState(() => _startDate = d)),
        _dateRow('End Date', _endDate, (d) => setState(() => _endDate = d)),
        _dateRow('Registration Opens', _regOpen, (d) => setState(() => _regOpen = d)),
        _dateRow('Registration Deadline', _regDeadline, (d) => setState(() => _regDeadline = d)),
      ],
    );
  }

  Widget _formatSelection() {
    final formats = [
      'Single Elimination',
      'Double Elimination',
      'Round Robin',
      'Group + Knockout',
    ];
    return Column(
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: formats
              .map((f) => ChoiceChip(
                    selectedColor: Colors.green.shade700,
                    label: Text(f),
                    selected: _format == f,
                    onSelected: (_) => setState(() => _format = f),
                  ))
              .toList(),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Text('Max Teams:'),
            const SizedBox(width: 12),
            DropdownButton<int>(
              value: _maxTeams,
              items: const [4, 8, 16, 32]
                  .map((e) => DropdownMenuItem(value: e, child: Text('$e')))
                  .toList(),
              onChanged: (v) => setState(() => _maxTeams = v ?? 8),
            ),
            const Spacer(),
            const Text('Match Duration'),
            const SizedBox(width: 12),
            DropdownButton<int>(
              value: _matchDuration,
              items: const [10, 15, 20, 30]
                  .map((e) => DropdownMenuItem(value: e, child: Text('$e min')))
                  .toList(),
              onChanged: (v) => setState(() => _matchDuration = v ?? 15),
            ),
          ],
        ),
      ],
    );
  }

  Widget _prizes() {
    return Column(
      children: [
        TextFormField(
          controller: _prizePoolCtrl,
          decoration: const InputDecoration(hintText: 'Prize Pool (optional)'),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _firstPrizeCtrl,
          decoration: const InputDecoration(labelText: '1st Place Prize', hintText: 'Trophy + ₹3000'),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _secondPrizeCtrl,
          decoration: const InputDecoration(labelText: '2nd Place Prize', hintText: 'Trophy + ₹1500'),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _thirdPrizeCtrl,
          decoration: const InputDecoration(labelText: '3rd Place Prize', hintText: 'Trophy + ₹500'),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _rulesCtrl,
          maxLines: 3,
          decoration: const InputDecoration(labelText: 'Tournament Rules'),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _notesCtrl,
          maxLines: 2,
          decoration: const InputDecoration(labelText: 'Additional Notes'),
        ),
      ],
    );
  }

  Widget _review() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _summaryTile('Tournament name', _nameCtrl.text),
        _summaryTile('Sport', _sport ?? '-'),
        _summaryTile('Venue', _venue ?? '-'),
        _summaryTile('Dates', _formatDateRange()),
        _summaryTile('Format', _format ?? '-'),
        _summaryTile('Max teams', '$_maxTeams'),
        _summaryTile('Prizes', _prizePoolCtrl.text.isEmpty ? 'Not set' : _prizePoolCtrl.text),
        const SizedBox(height: 8),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          value: _confirm,
          onChanged: (v) => setState(() => _confirm = v ?? false),
          title: const Text('I confirm all details are correct'),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Publish immediately'),
          value: _publish,
          onChanged: (v) => setState(() => _publish = v),
        ),
      ],
    );
  }

  Widget _summaryTile(String title, String value) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      subtitle: Text(value),
      trailing: const Icon(Icons.edit, size: 18),
      onTap: () {},
    );
  }

  Widget _dateRow(String label, DateTime? value, ValueChanged<DateTime> onPick) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      subtitle: Text(value != null ? _fmt(value) : 'Select date'),
      trailing: const Icon(Icons.calendar_today),
      onTap: () => _pickDate(onPick, initial: value),
    );
  }

  Widget _pillSelector({
    required String title,
    required List<String> options,
    required String? current,
    required ValueChanged<String> onSelect,
    required String? Function() validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(title, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(width: 8),
            if (validator() != null)
              const Text('*', style: TextStyle(color: Colors.red, fontSize: 18)),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 8,
          children: options
              .map(
                (o) => ChoiceChip(
                  selectedColor: Colors.green.shade700,
                  label: Text(o),
                  selected: current == o,
                  onSelected: (_) => onSelect(o),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  String _fmt(DateTime d) => '${d.day}/${d.month}/${d.year}';

  String _formatDateRange() {
    if (_startDate == null || _endDate == null) return '-';
    return '${_fmt(_startDate!)} - ${_fmt(_endDate!)}';
  }
}
