import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/reflection.dart';
import '../theme/app_theme.dart';

class ReflectionScreen extends StatefulWidget {
  const ReflectionScreen({super.key});

  @override
  State<ReflectionScreen> createState() => _ReflectionScreenState();
}

class _ReflectionScreenState extends State<ReflectionScreen> {
  final _whatWorkedController = TextEditingController();
  final _whatWasDifficultController = TextEditingController();
  final _nextWeekController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadExistingReflection();
  }

  void _loadExistingReflection() {
    final state = context.read<AppState>();
    final reflection = state.getReflectionForWeek(DateTime.now());
    if (reflection != null) {
      _whatWorkedController.text = reflection.whatWorked ?? '';
      _whatWasDifficultController.text = reflection.whatWasDifficult ?? '';
      _nextWeekController.text = reflection.nextWeekAdjustment ?? '';
    }
  }

  @override
  void dispose() {
    _whatWorkedController.dispose();
    _whatWasDifficultController.dispose();
    _nextWeekController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Veckoreflexion'),
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
            
            // Fråga 1
            _buildQuestionCard(
              emoji: '✨',
              question: 'Vad fungerade denna vecka?',
              hint: 'Små eller stora saker som gick bra...',
              controller: _whatWorkedController,
            ),
            const SizedBox(height: 16),
            
            // Fråga 2
            _buildQuestionCard(
              emoji: '🤔',
              question: 'Vad var svårt?',
              hint: 'Utan att döma, bara observera...',
              controller: _whatWasDifficultController,
            ),
            const SizedBox(height: 16),
            
            // Fråga 3
            _buildQuestionCard(
              emoji: '🌱',
              question: 'Vad vill jag justera nästa vecka?',
              hint: 'Små förändringar, inte perfektion...',
              controller: _nextWeekController,
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
          'Stanna upp en stund',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'Inga krav, bara reflektion. Svara på det du vill.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Text('📝', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Detta är inget dagbokskrav. Skriv när det känns rätt.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _saveReflection() {
    final reflection = Reflection(
      date: DateTime.now(),
      whatWorked: _whatWorkedController.text.isEmpty ? null : _whatWorkedController.text,
      whatWasDifficult: _whatWasDifficultController.text.isEmpty ? null : _whatWasDifficultController.text,
      nextWeekAdjustment: _nextWeekController.text.isEmpty ? null : _nextWeekController.text,
    );

    context.read<AppState>().saveReflection(reflection);

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
