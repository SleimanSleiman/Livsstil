import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';

class MonthlyOverviewScreen extends StatefulWidget {
  const MonthlyOverviewScreen({super.key});

  @override
  State<MonthlyOverviewScreen> createState() => _MonthlyOverviewScreenState();
}

class _MonthlyOverviewScreenState extends State<MonthlyOverviewScreen> {
  late DateTime _selectedMonth;

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Månadsöversikt'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Månadsväljare
            _buildMonthSelector(),
            const SizedBox(height: 24),
            
            // Identitetsprocent
            _buildIdentityCard(),
            const SizedBox(height: 24),
            
            // Vanestatistik
            _buildHabitStats(),
            const SizedBox(height: 24),
            
            // Info-text
            _buildInfoText(),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthSelector() {
    final monthNames = [
      'Januari', 'Februari', 'Mars', 'April', 'Maj', 'Juni',
      'Juli', 'Augusti', 'September', 'Oktober', 'November', 'December'
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () {
            setState(() {
              _selectedMonth = DateTime(
                _selectedMonth.year,
                _selectedMonth.month - 1,
              );
            });
          },
          icon: const Icon(Icons.chevron_left),
        ),
        Text(
          '${monthNames[_selectedMonth.month - 1]} ${_selectedMonth.year}',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        IconButton(
          onPressed: _selectedMonth.month < DateTime.now().month ||
                     _selectedMonth.year < DateTime.now().year
              ? () {
                  setState(() {
                    _selectedMonth = DateTime(
                      _selectedMonth.year,
                      _selectedMonth.month + 1,
                    );
                  });
                }
              : null,
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }

  Widget _buildIdentityCard() {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final percentage = state.getMonthlyIdentityPercentage(
          _selectedMonth.year,
          _selectedMonth.month,
        );

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryColor,
                AppTheme.primaryColor.withValues(alpha: 0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Text(
                '${percentage.round()}%',
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'av dagarna agerade du som\nen hälsosam person',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHabitStats() {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final stats = state.getMonthlyHabitStats(
          _selectedMonth.year,
          _selectedMonth.month,
        );
        final daysInMonth = state.getDaysInMonth(
          _selectedMonth.year,
          _selectedMonth.month,
        );

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Vanor denna månad',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                
                ...state.activeHabits.map((habit) {
                  final count = stats[habit.id] ?? 0;
                  final progress = count / daysInMonth;
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              habit.icon,
                              style: const TextStyle(fontSize: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                habit.title,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                            Text(
                              '$count / $daysInMonth',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: AppTheme.neutralGray.withValues(alpha: 0.2),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.primaryColor.withValues(alpha: 0.7),
                            ),
                            minHeight: 8,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
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
          const Text('🌿', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Detta visar beteendemönster, inte perfektion. Varje dag räknas.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
