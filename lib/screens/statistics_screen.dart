import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/habit.dart';
import '../providers/app_state.dart';
import '../models/meal_entry.dart';
import '../theme/app_theme.dart';
import '../widgets/time_range_selector.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  int _selectedTab = 0;
  TimeRange _timeRange = TimeRange.week;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistik'),
      ),
      body: Column(
        children: [
          // Tab bar
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.neutralGray.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _buildTab('Måltider', 0),
                _buildTab('Vanor', 1),
                _buildTab('Träning', 2),
              ],
            ),
          ),
          
          // Time Range Selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TimeRangeSelector(
              selectedRange: _timeRange,
              onRangeSelected: (range) => setState(() => _timeRange = range),
            ),
          ),
          const SizedBox(height: 16),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _buildContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedTab) {
      case 0:
        return _buildMealStats();
      case 1:
        return _buildHabitStats();
      case 2:
        return _buildWorkoutStats();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildMealStats() {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final meals = state.mealEntries;
        if (meals.isEmpty) {
          return _buildEmptyState('Inga måltider loggade ännu');
        }

        // Filtrera baserat på tidsintervall
        final now = DateTime.now();
        DateTime startDate;
        
        switch (_timeRange) {
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

        final recentMeals = meals.where((m) => m.timestamp.isAfter(startDate)).toList();

        if (recentMeals.isEmpty) {
          return _buildEmptyState('Ingen data för vald period');
        }

        // Gruppera per vecka
        final weeklyRatings = <int, Map<MealRating, int>>{};
        for (var meal in recentMeals) {
          final weekNum = _getWeekNumber(meal.timestamp);
          weeklyRatings.putIfAbsent(weekNum, () => {});
          weeklyRatings[weekNum]!.update(
            meal.rating,
            (count) => count + 1,
            ifAbsent: () => 1,
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Måltidsbetyg per vecka'),
            const SizedBox(height: 16),
            SizedBox(
              height: 220,
              child: _buildMealRatingsChart(weeklyRatings),
            ),
            const SizedBox(height: 32),
            
            _buildSectionTitle('Måltidskänsla fördelning'),
            const SizedBox(height: 16),
            _buildMealRatingsPie(recentMeals),
            const SizedBox(height: 32),
            
            _buildSectionTitle('Hungernivå trend'),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: _buildHungerTrendChart(recentMeals),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMealRatingsChart(Map<int, Map<MealRating, int>> weeklyRatings) {
    if (weeklyRatings.isEmpty) return _buildEmptyState('Ingen data');

    final weeks = weeklyRatings.keys.toList()..sort();
    final lastWeeks = weeks.length > 4 ? weeks.sublist(weeks.length - 4) : weeks;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: weeklyRatings.values
            .map((r) => r.values.fold(0, (a, b) => a + b))
            .reduce((a, b) => a > b ? a : b)
            .toDouble() + 2,
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() < lastWeeks.length) {
                  return Text(
                    'V${lastWeeks[value.toInt()]}',
                    style: const TextStyle(fontSize: 12),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 11),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 2,
          getDrawingHorizontalLine: (value) => FlLine(
            color: AppTheme.neutralGray.withValues(alpha: 0.2),
            strokeWidth: 1,
          ),
        ),
        barGroups: lastWeeks.asMap().entries.map((entry) {
          final ratings = weeklyRatings[entry.value] ?? {};
          final gold = ratings[MealRating.gold]?.toDouble() ?? 0;
          final silver = ratings[MealRating.silver]?.toDouble() ?? 0;
          final bronze = ratings[MealRating.bronze]?.toDouble() ?? 0;
          
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: gold + silver + bronze,
                width: 24,
                rodStackItems: [
                  BarChartRodStackItem(0, bronze, AppTheme.bronzeColor),
                  BarChartRodStackItem(bronze, bronze + silver, AppTheme.silverColor),
                  BarChartRodStackItem(bronze + silver, bronze + silver + gold, AppTheme.goldColor),
                ],
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMealRatingsPie(List<MealEntry> meals) {
    final ratedMeals = meals.where((m) => m.rating != MealRating.none).toList();
    if (ratedMeals.isEmpty) return _buildEmptyState('Inga betygsatta måltider');

    final bronze = ratedMeals.where((m) => m.rating == MealRating.bronze).length;
    final silver = ratedMeals.where((m) => m.rating == MealRating.silver).length;
    final gold = ratedMeals.where((m) => m.rating == MealRating.gold).length;

    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 150,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: [
                  PieChartSectionData(
                    value: bronze.toDouble(),
                    color: AppTheme.bronzeColor,
                    title: bronze > 0 ? '$bronze' : '',
                    radius: 35,
                    titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  PieChartSectionData(
                    value: silver.toDouble(),
                    color: AppTheme.silverColor,
                    title: silver > 0 ? '$silver' : '',
                    radius: 35,
                    titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  PieChartSectionData(
                    value: gold.toDouble(),
                    color: AppTheme.goldColor,
                    title: gold > 0 ? '$gold' : '',
                    radius: 35,
                    titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLegendItem('🥉 Okej', bronze, AppTheme.bronzeColor),
            const SizedBox(height: 8),
            _buildLegendItem('🥈 Bra', silver, AppTheme.silverColor),
            const SizedBox(height: 8),
            _buildLegendItem('🥇 Riktigt bra', gold, AppTheme.goldColor),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, int count, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 8),
        Text('$label ($count)'),
      ],
    );
  }

  Widget _buildHungerTrendChart(List<MealEntry> meals) {
    final mealsWithHunger = meals.where((m) => m.hungerBefore != null).toList();
    if (mealsWithHunger.isEmpty) return _buildEmptyState('Ingen hungerdata');

    mealsWithHunger.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    final recentMeals = mealsWithHunger.length > 14 
        ? mealsWithHunger.sublist(mealsWithHunger.length - 14) 
        : mealsWithHunger;

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: 10,
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() < recentMeals.length && value.toInt() % 3 == 0) {
                  return Text(
                    DateFormat('d/M').format(recentMeals[value.toInt()].timestamp),
                    style: const TextStyle(fontSize: 10),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 2,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 11),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 2,
          getDrawingHorizontalLine: (value) => FlLine(
            color: AppTheme.neutralGray.withValues(alpha: 0.2),
            strokeWidth: 1,
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: recentMeals.asMap().entries.map((entry) {
              return FlSpot(entry.key.toDouble(), entry.value.hungerBefore!.toDouble());
            }).toList(),
            isCurved: true,
            color: AppTheme.primaryColor,
            barWidth: 3,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, bar, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: AppTheme.primaryColor,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitStats() {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final habits = state.activeHabits;
        if (habits.isEmpty) {
          return _buildEmptyState('Inga aktiva vanor');
        }

        // Filtrera baserat på tidsintervall
        final now = DateTime.now();
        int weeksToShow;
        
        switch (_timeRange) {
          case TimeRange.week:
            weeksToShow = 1;
            break;
          case TimeRange.month:
            weeksToShow = 4;
            break;
          case TimeRange.threeMonths:
            weeksToShow = 12;
            break;
          case TimeRange.sixMonths:
            weeksToShow = 26;
            break;
          case TimeRange.year:
            weeksToShow = 52;
            break;
        }

        final weeks = List.generate(weeksToShow, (i) {
          final weekStart = now.subtract(Duration(days: now.weekday - 1 + (i * 7)));
          return weekStart;
        }).reversed.toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Vaneprestanda per vecka'),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: _buildHabitPerformanceChart(state, weeks),
            ),
            const SizedBox(height: 32),
            
            _buildSectionTitle('Vanor denna vecka'),
            const SizedBox(height: 16),
            ...habits.map((habit) => _buildHabitProgress(state, habit)),
          ],
        );
      },
    );
  }

  Widget _buildHabitPerformanceChart(AppState state, List<DateTime> weeks) {
    final habits = state.activeHabits;
    
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 7,
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() < weeks.length) {
                  // Visa bara varannan vecka om det är många
                  if (weeks.length > 8 && value.toInt() % (weeks.length ~/ 6 + 1) != 0) {
                    return const SizedBox.shrink();
                  }
                  return Text(
                    'V${_getWeekNumber(weeks[value.toInt()])}',
                    style: const TextStyle(fontSize: 12),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 11),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 1,
          getDrawingHorizontalLine: (value) => FlLine(
            color: AppTheme.neutralGray.withValues(alpha: 0.2),
            strokeWidth: 1,
          ),
        ),
        barGroups: weeks.asMap().entries.map((weekEntry) {
          final weekStart = weekEntry.value;
          final avgCompletion = habits.isEmpty ? 0.0 : habits.map((habit) {
            int completed = 0;
            for (int i = 0; i < 7; i++) {
              final day = DateTime(weekStart.year, weekStart.month, weekStart.day + i);
              if (state.isHabitCompleted(habit.id, day)) completed++;
            }
            return completed;
          }).reduce((a, b) => a + b) / habits.length;
          
          return BarChartGroupData(
            x: weekEntry.key,
            barRods: [
              BarChartRodData(
                toY: avgCompletion,
                width: 32,
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildHabitProgress(AppState state, habit) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    int completed = 0;
    for (int i = 0; i < 7; i++) {
      final day = DateTime(weekStart.year, weekStart.month, weekStart.day + i);
      if (!day.isAfter(now) && state.isHabitCompleted(habit.id, day)) completed++;
    }
    final daysPassedThisWeek = now.weekday;
    final percentage = daysPassedThisWeek > 0 ? completed / daysPassedThisWeek : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.neutralGray.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(habit.icon, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 12),
              Expanded(child: Text(habit.title)),
              Text(
                '$completed/7',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: AppTheme.neutralGray.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutStats() {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final workouts = state.workoutEntries;
        if (workouts.isEmpty) {
          return _buildEmptyState('Ingen träning loggad ännu');
        }

        // Filtrera baserat på tidsintervall
        final now = DateTime.now();
        int weeksToShow;
        DateTime startDate;
        
        switch (_timeRange) {
          case TimeRange.week:
            weeksToShow = 1;
            startDate = now.subtract(const Duration(days: 7));
            break;
          case TimeRange.month:
            weeksToShow = 4;
            startDate = now.subtract(const Duration(days: 30));
            break;
          case TimeRange.threeMonths:
            weeksToShow = 12;
            startDate = now.subtract(const Duration(days: 90));
            break;
          case TimeRange.sixMonths:
            weeksToShow = 26;
            startDate = now.subtract(const Duration(days: 180));
            break;
          case TimeRange.year:
            weeksToShow = 52;
            startDate = now.subtract(const Duration(days: 365));
            break;
        }

        final recentWorkouts = workouts.where((w) => w.date.isAfter(startDate)).toList();

        if (recentWorkouts.isEmpty) {
          return _buildEmptyState('Ingen träning för vald period');
        }

        final weeks = List.generate(weeksToShow, (i) {
          final weekStart = now.subtract(Duration(days: now.weekday - 1 + (i * 7)));
          return weekStart;
        }).reversed.toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Träningsminuter per vecka'),
            const SizedBox(height: 16),
            SizedBox(
              height: 220,
              child: _buildWorkoutMinutesChart(workouts, weeks),
            ),
            const SizedBox(height: 32),
            
            _buildSectionTitle('Träningstyper'),
            const SizedBox(height: 16),
            _buildWorkoutTypesPie(recentWorkouts, state),
            const SizedBox(height: 32),
            
            _buildWorkoutSummary(recentWorkouts),
          ],
        );
      },
    );
  }

  Widget _buildWorkoutMinutesChart(List workouts, List<DateTime> weeks) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() < weeks.length) {
                  // Visa bara varannan vecka om det är många
                  if (weeks.length > 8 && value.toInt() % (weeks.length ~/ 6 + 1) != 0) {
                    return const SizedBox.shrink();
                  }
                  return Text(
                    'V${_getWeekNumber(weeks[value.toInt()])}',
                    style: const TextStyle(fontSize: 12),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()} min',
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(
            color: AppTheme.neutralGray.withValues(alpha: 0.2),
            strokeWidth: 1,
          ),
        ),
        barGroups: weeks.asMap().entries.map((entry) {
          final weekStart = entry.value;
          final weekEnd = weekStart.add(const Duration(days: 7));
          final weekWorkouts = workouts.where((w) {
            return w.date.isAfter(weekStart.subtract(const Duration(days: 1))) &&
                   w.date.isBefore(weekEnd);
          });
          final totalMinutes = weekWorkouts.fold<int>(0, (sum, w) => sum + w.durationMinutes as int);
          
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: totalMinutes.toDouble(),
                width: 32,
                color: AppTheme.accentWarm,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildWorkoutTypesPie(List<WorkoutEntry> workouts, AppState state) {
    final typeCount = <String, int>{};
    for (var w in workouts) {
      final typeName = state.workoutTypes
          .firstWhere((t) => t.id == w.workoutTypeId,
              orElse: () => WorkoutType(id: 'unknown', icon: '?', title: 'Okänd'))
          .title;
      typeCount.update(typeName, (c) => c + 1, ifAbsent: () => 1);
    }

    final colors = [
      AppTheme.primaryColor,
      AppTheme.accentWarm,
      AppTheme.secondaryColor,
      AppTheme.goldColor,
      AppTheme.bronzeColor,
      AppTheme.silverColor,
    ];

    final entries = typeCount.entries.toList();

    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 150,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: entries.asMap().entries.map((e) {
                  return PieChartSectionData(
                    value: e.value.value.toDouble(),
                    color: colors[e.key % colors.length],
                    title: e.value.value > 0 ? '${e.value.value}' : '',
                    radius: 35,
                    titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: entries.asMap().entries.map((e) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: colors[e.key % colors.length],
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('${e.value.key} (${e.value.value})', style: const TextStyle(fontSize: 12)),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildWorkoutSummary(List workouts) {
    final totalMinutes = workouts.fold<int>(0, (sum, w) => sum + w.durationMinutes as int);
    final totalSessions = workouts.length;
    final avgMinutes = totalSessions > 0 ? totalMinutes ~/ totalSessions : 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildSummaryItem('Totalt', '$totalMinutes min', Icons.timer),
            _buildSummaryItem('Pass', '$totalSessions st', Icons.fitness_center),
            _buildSummaryItem('Snitt', '$avgMinutes min', Icons.show_chart),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primaryColor, size: 28),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium,
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.all(32),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(
            Icons.bar_chart,
            size: 48,
            color: AppTheme.neutralGray,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  int _getWeekNumber(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final daysDiff = date.difference(firstDayOfYear).inDays;
    return ((daysDiff + firstDayOfYear.weekday - 1) / 7).ceil();
  }
}
