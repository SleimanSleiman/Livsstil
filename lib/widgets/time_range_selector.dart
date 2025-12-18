import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum TimeRange {
  week,
  month,
  threeMonths,
  sixMonths,
  year;

  String get label {
    switch (this) {
      case TimeRange.week:
        return '1V';
      case TimeRange.month:
        return '1M';
      case TimeRange.threeMonths:
        return '3M';
      case TimeRange.sixMonths:
        return '6M';
      case TimeRange.year:
        return '1Å';
    }
  }
  
  String get fullLabel {
    switch (this) {
      case TimeRange.week:
        return 'Vecka';
      case TimeRange.month:
        return 'Månad';
      case TimeRange.threeMonths:
        return '3 Månader';
      case TimeRange.sixMonths:
        return '6 Månader';
      case TimeRange.year:
        return '1 År';
    }
  }
}

class TimeRangeSelector extends StatelessWidget {
  final TimeRange selectedRange;
  final Function(TimeRange) onRangeSelected;

  const TimeRangeSelector({
    super.key,
    required this.selectedRange,
    required this.onRangeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.neutralGray.withValues(alpha: 0.2),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final itemWidth = (constraints.maxWidth - 8) / TimeRange.values.length;
          
          return Row(
            mainAxisSize: MainAxisSize.max,
            children: TimeRange.values.map((range) {
              final isSelected = range == selectedRange;
              
              return GestureDetector(
                onTap: () => onRangeSelected(range),
                child: Container(
                  width: itemWidth,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? AppTheme.primaryColor 
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    range.label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected 
                          ? Colors.white 
                          : Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
