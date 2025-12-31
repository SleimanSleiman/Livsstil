import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/daily_reflection.dart';
import '../theme/app_theme.dart';

class DailyReflectionScreen extends StatefulWidget {
  final DateTime? date;
  
  const DailyReflectionScreen({super.key, this.date});

  @override
  State<DailyReflectionScreen> createState() => _DailyReflectionScreenState();
}

class _DailyReflectionScreenState extends State<DailyReflectionScreen> {
  final _gratitudeController = TextEditingController();
  final _highlightController = TextEditingController();
  final _challengeController = TextEditingController();
  final _tomorrowController = TextEditingController();
  int? _moodRating;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.date ?? DateTime.now();
    _loadExistingReflection();
  }

  @override
  void didUpdateWidget(covariant DailyReflectionScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the requested date changes, reload (or clear) the controllers
    final newDate = widget.date ?? DateTime.now();
    if (newDate.year != _selectedDate.year || newDate.month != _selectedDate.month || newDate.day != _selectedDate.day) {
      _selectedDate = newDate;
      _clearControllers();
      _loadExistingReflection();
    }
  }

  void _loadExistingReflection() {
    final state = context.read<AppState>();
    final reflection = state.getDailyReflectionForDate(_selectedDate);
    if (reflection != null) {
      _gratitudeController.text = reflection.gratitude ?? '';
      _highlightController.text = reflection.highlight ?? '';
      _challengeController.text = reflection.challenge ?? '';
      _tomorrowController.text = reflection.tomorrowFocus ?? '';
      _moodRating = reflection.moodRating;
    } else {
      _clearControllers();
    }
  }

  void _clearControllers() {
    _gratitudeController.text = '';
    _highlightController.text = '';
    _challengeController.text = '';
    _tomorrowController.text = '';
    _moodRating = null;
  }

  @override
  void dispose() {
    _gratitudeController.dispose();
    _highlightController.dispose();
    _challengeController.dispose();
    _tomorrowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isToday = _isToday(_selectedDate);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isToday ? 'Dagens reflektion' : _formatDate(_selectedDate)),
        actions: [
          TextButton(
            onPressed: _saveReflection,
            child: const Text('Spara'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(),
            const SizedBox(height: 24),
            
            // Humör
            _buildMoodSection(),
            const SizedBox(height: 24),
            
            // Tacksam för
            _buildQuestionCard(
              emoji: '🙏',
              question: 'Vad är jag tacksam för idag?',
              hint: 'Små eller stora saker...',
              controller: _gratitudeController,
            ),
            const SizedBox(height: 16),
            
            // Höjdpunkt
            _buildQuestionCard(
              emoji: '⭐',
              question: 'Dagens höjdpunkt',
              hint: 'Något som gick bra eller kändes meningsfullt...',
              controller: _highlightController,
            ),
            const SizedBox(height: 16),
            
            // Utmaning
            _buildQuestionCard(
              emoji: '💪',
              question: 'Vad var utmanande?',
              hint: 'Utan att döma, bara observera...',
              controller: _challengeController,
            ),
            const SizedBox(height: 16),
            
            // Imorgon
            _buildQuestionCard(
              emoji: '🎯',
              question: 'Vad vill jag fokusera på imorgon?',
              hint: 'En sak att prioritera...',
              controller: _tomorrowController,
            ),
            const SizedBox(height: 24),
            
            // Info
            _buildInfoText(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dagsreflektion',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        const SizedBox.shrink(),
      ],
    );
  }

  Widget _buildMoodSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('😊', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 12),
                Text(
                  'Hur mår du idag?',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(5, (index) {
                final mood = index + 1;
                final isSelected = _moodRating == mood;
                return GestureDetector(
                  onTap: () => setState(() => _moodRating = mood),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primaryColor.withValues(alpha: 0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.primaryColor
                            : AppTheme.neutralGray.withValues(alpha: 0.2),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        DailyReflection.moodEmoji(mood),
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionCard({
    required String emoji,
    required String question,
    required String hint,
    required TextEditingController controller,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    question,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  color: AppTheme.textSecondary.withValues(alpha: 0.6),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).inputDecorationTheme.fillColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoText() {
    return const SizedBox.shrink();
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  String _formatDate(DateTime date) {
    final weekdays = ['Mån', 'Tis', 'Ons', 'Tor', 'Fre', 'Lör', 'Sön'];
    return '${weekdays[date.weekday - 1]} ${date.day}/${date.month}';
  }

  void _saveReflection() {
    final reflection = DailyReflection(
      date: _selectedDate,
      gratitude: _gratitudeController.text.isEmpty ? null : _gratitudeController.text,
      highlight: _highlightController.text.isEmpty ? null : _highlightController.text,
      challenge: _challengeController.text.isEmpty ? null : _challengeController.text,
      tomorrowFocus: _tomorrowController.text.isEmpty ? null : _tomorrowController.text,
      moodRating: _moodRating,
    );

    context.read<AppState>().saveDailyReflection(reflection);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Reflektion sparad'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );

    Navigator.pop(context);
  }
}
