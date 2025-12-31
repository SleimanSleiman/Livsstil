import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../models/meal_entry.dart';
import '../widgets/time_range_selector.dart';
import 'reflection_screen.dart';
import 'reflection_history_screen.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  TimeRange _weightTimeRange = TimeRange.month;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Insikter'),
      ),
      body: Consumer<AppState>(
        builder: (context, state, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Välkomstkort
                _buildWelcomeCard(context, state),
                const SizedBox(height: 20),
                
                // Veckans sammanfattning
                _buildWeekSummary(context, state),
                const SizedBox(height: 20),
                
                // Vanor progress
                _buildHabitsProgress(context, state),
                const SizedBox(height: 20),
                
                // Träningsöversikt
                _buildWorkoutOverview(context, state),
                const SizedBox(height: 20),
                
                // Måltidsmönster
                _buildMealInsights(context, state),
                const SizedBox(height: 20),

                // Viktgraf
                _buildWeightGraph(context, state),
                const SizedBox(height: 20),
                
                // Reflektioner
                _buildReflectionCard(context, state),
                const SizedBox(height: 20),
                
                // Motiverande budskap (removed)
                const SizedBox.shrink(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context, AppState state) {
    final hour = DateTime.now().hour;
    String greeting;
    String emoji;
    
    if (hour < 12) {
      greeting = 'God morgon';
      emoji = '🌅';
    } else if (hour < 17) {
      greeting = 'God eftermiddag';
      emoji = '☀️';
    } else {
      greeting = 'God kväll';
      emoji = '🌙';
    }
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor.withValues(alpha: 0.15),
            AppTheme.primaryColor.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(height: 12),
          Text(
            greeting,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Här är din sammanfattning',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekSummary(BuildContext context, AppState state) {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    
    // Räkna vanor avklarade denna vecka
    int habitsCompleted = 0;
    int totalPossible = 0;
    
    for (int i = 0; i < now.weekday; i++) {
      final date = monday.add(Duration(days: i));
      for (final habit in state.activeHabits) {
        totalPossible++;
        if (state.isHabitCompleted(habit.id, date)) {
          habitsCompleted++;
        }
      }
    }
    
    // Räkna träningspass denna vecka
    final workoutsThisWeek = state.workoutEntries.where((w) {
      final workoutDate = w.date;
      return workoutDate.isAfter(monday.subtract(const Duration(days: 1))) &&
             workoutDate.isBefore(now.add(const Duration(days: 1)));
    }).length;
    
    // Räkna måltider denna vecka
    final mealsThisWeek = state.mealEntries.where((m) {
      return m.timestamp.isAfter(monday.subtract(const Duration(days: 1))) &&
             m.timestamp.isBefore(now.add(const Duration(days: 1)));
    }).length;
    
    final completionRate = totalPossible > 0 
        ? (habitsCompleted / totalPossible * 100).round() 
        : 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('📊', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 12),
                Text(
                  'Denna vecka',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    icon: '✅',
                    value: '$completionRate%',
                    label: 'Vanor',
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    context,
                    icon: '🏃',
                    value: '$workoutsThisWeek',
                    label: 'Träningspass',
                    color: AppTheme.accentWarm,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    context,
                    icon: '🍽️',
                    value: '$mealsThisWeek',
                    label: 'Måltider',
                    color: AppTheme.accentCool,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, {
    required String icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHabitsProgress(BuildContext context, AppState state) {
    if (state.activeHabits.isEmpty) return const SizedBox.shrink();
    
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('📋', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 12),
                Text(
                  'Vanor denna vecka',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            ...state.activeHabits.map((habit) {
              int completed = 0;
              for (int i = 0; i < now.weekday; i++) {
                final date = weekStart.add(Duration(days: i));
                if (state.isHabitCompleted(habit.id, date)) {
                  completed++;
                }
              }
              final progress = now.weekday > 0 ? completed / now.weekday : 0.0;
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(habit.icon, style: const TextStyle(fontSize: 18)),
                            const SizedBox(width: 8),
                            Text(habit.title),
                          ],
                        ),
                        Text(
                          '$completed/${now.weekday}',
                          style: Theme.of(context).textTheme.bodySmall,
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
                          progress >= 0.8 
                              ? AppTheme.primaryColor 
                              : progress >= 0.5 
                                  ? AppTheme.accentWarm 
                                  : AppTheme.neutralGray,
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
  }

  Widget _buildWorkoutOverview(BuildContext context, AppState state) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    
    // Samla träningsdata per typ denna vecka
    final Map<String, int> workoutMinutesByType = {};
    final Map<String, int> workoutCountByType = {};
    
    for (final entry in state.workoutEntries) {
      if (entry.date.isAfter(weekStart.subtract(const Duration(days: 1))) &&
          entry.date.isBefore(now.add(const Duration(days: 1)))) {
        final type = state.getWorkoutTypeById(entry.workoutTypeId);
        if (type != null) {
          workoutMinutesByType[type.title] = (workoutMinutesByType[type.title] ?? 0) + entry.durationMinutes;
          workoutCountByType[type.title] = (workoutCountByType[type.title] ?? 0) + 1;
        }
      }
    }
    
    if (workoutCountByType.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Text('🏃', style: TextStyle(fontSize: 32)),
              const SizedBox(height: 12),
              Text(
                'Inga träningspass denna vecka',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Checka in träning på hemskärmen!',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    final totalMinutes = workoutMinutesByType.values.fold(0, (a, b) => a + b);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text('🏃', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 12),
                    Text(
                      'Träning denna vecka',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.accentWarm.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$totalMinutes min',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.accentWarm,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            ...workoutCountByType.entries.map((entry) {
              final type = state.workoutTypes.firstWhere(
                (t) => t.title == entry.key,
                orElse: () => state.workoutTypes.first,
              );
              final minutes = workoutMinutesByType[entry.key] ?? 0;
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Text(type.icon, style: const TextStyle(fontSize: 22)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(entry.key, style: const TextStyle(fontWeight: FontWeight.w500)),
                          Text(
                            '${entry.value} pass • $minutes min',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
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
  }

  Widget _buildMealInsights(BuildContext context, AppState state) {
    final meals = state.mealEntries;
    if (meals.isEmpty) return const SizedBox.shrink();
    
    // Senaste 7 dagars måltider
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final recentMeals = meals.where((m) => m.timestamp.isAfter(weekAgo)).toList();
    
    if (recentMeals.isEmpty) return const SizedBox.shrink();
    
    // Räkna betyg
    final ratedMeals = recentMeals.where((m) => m.rating != MealRating.none).toList();
    final goldCount = ratedMeals.where((m) => m.rating == MealRating.gold).length;
    final silverCount = ratedMeals.where((m) => m.rating == MealRating.silver).length;
    final bronzeCount = ratedMeals.where((m) => m.rating == MealRating.bronze).length;
    
    // Räkna mättnadsnivåer
    final satisfiedMeals = recentMeals.where((m) => m.satietyAfter != null).toList();
    final avgSatiety = satisfiedMeals.isNotEmpty 
        ? satisfiedMeals.map((m) => m.satietyAfter!).reduce((a, b) => a + b) / satisfiedMeals.length
        : 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('🍽️', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 12),
                Text(
                  'Måltidsinsikter',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Betygfördelning
            if (ratedMeals.isNotEmpty) ...[
              Text(
                'Hur måltiderna kändes',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildRatingChip('🥇', goldCount, AppTheme.goldColor),
                  const SizedBox(width: 8),
                  _buildRatingChip('🥈', silverCount, AppTheme.silverColor),
                  const SizedBox(width: 8),
                  _buildRatingChip('🥉', bronzeCount, AppTheme.bronzeColor),
                ],
              ),
              const SizedBox(height: 16),
            ],
            
            // Genomsnittlig mättnad
            if (satisfiedMeals.isNotEmpty) ...[
              Text(
                'Genomsnittlig mättnad',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: avgSatiety / 10,
                        backgroundColor: AppTheme.neutralGray.withValues(alpha: 0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentCool),
                        minHeight: 10,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${avgSatiety.toStringAsFixed(1)}/10',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRatingChip(String emoji, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Text(
            '$count',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightGraph(BuildContext context, AppState state) {
    final allWeightEntries = state.weightEntries;
    
    // Filtrera baserat på tidsintervall
    final now = DateTime.now();
    DateTime startDate;
    
    switch (_weightTimeRange) {
      case TimeRange.week:
        startDate = now.subtract(const Duration(days: 7));
        break;
      case TimeRange.month:
        startDate = now.subtract(const Duration(days: 30));
        break;
      case TimeRange.threeMonths:
        startDate = now.subtract(const Duration(days: 90));
        break;
      case TimeRange.sixMonths:
        startDate = now.subtract(const Duration(days: 180));
        break;
      case TimeRange.year:
        startDate = now.subtract(const Duration(days: 365));
        break;
    }

    final weightEntries = allWeightEntries
        .where((e) => e.date.isAfter(startDate) || e.date.isAtSameMomentAs(startDate))
        .toList();

    // Sortera efter datum
    weightEntries.sort((a, b) => a.date.compareTo(b.date));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('⚖️', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 12),
                Text(
                  'Viktförändring',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Tidsintervall-väljare
            TimeRangeSelector(
              selectedRange: _weightTimeRange,
              onRangeSelected: (range) => setState(() => _weightTimeRange = range),
            ),
            
            const SizedBox(height: 24),
            
            if (weightEntries.isEmpty)
              Container(
                height: 200,
                alignment: Alignment.center,
                child: Text(
                  'Ingen viktdata för denna period',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              )
            else
              SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: false),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index >= 0 && index < weightEntries.length) {
                              // Visa bara varannan datum om det är många
                              if (weightEntries.length > 7 && index % (weightEntries.length ~/ 5 + 1) != 0) {
                                return const SizedBox.shrink();
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  DateFormat('d/M').format(weightEntries[index].date),
                                  style: const TextStyle(fontSize: 10),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                          interval: 1,
                        ),
                      ),
                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: weightEntries.asMap().entries.map((e) {
                          return FlSpot(e.key.toDouble(), e.value.weight);
                        }).toList(),
                        isCurved: true,
                        color: AppTheme.primaryColor,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: FlDotData(show: true),
                        belowBarData: BarAreaData(show: false),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildReflectionCard(BuildContext context, AppState state) {
    final reflections = state.reflections;
    final latestReflection = reflections.isNotEmpty ? reflections.first : null;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text('💭', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 12),
                    Text(
                      'Reflektion',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ReflectionHistoryScreen()),
                      ),
                      child: const Text('Historik'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ReflectionScreen()),
                      ),
                      child: const Text('Skriv'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (latestReflection == null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.neutralGray.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.edit_note,
                      size: 40,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Skriv en veckoreflektion',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Vad fungerade? Vad kan du justera?',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Senaste reflektionen',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryColor,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (latestReflection.whatWorked != null && latestReflection.whatWorked!.isNotEmpty)
                      Text(
                        '✅ ${latestReflection.whatWorked}',
                        style: Theme.of(context).textTheme.bodyMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (latestReflection.nextWeekAdjustment != null && latestReflection.nextWeekAdjustment!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        '💡 ${latestReflection.nextWeekAdjustment}',
                        style: Theme.of(context).textTheme.bodyMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  
}
