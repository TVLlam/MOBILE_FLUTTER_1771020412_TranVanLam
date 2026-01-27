import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/court_model.dart';

class CourtSelector extends StatelessWidget {
  final List<CourtModel> courts;
  final int selectedCourtId;
  final Function(int) onCourtSelected;

  const CourtSelector({
    super.key,
    required this.courts,
    required this.selectedCourtId,
    required this.onCourtSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (courts.isEmpty) {
      return const SizedBox(
        height: 100,
        child: Center(child: Text('Không có sân nào')),
      );
    }

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: courts.length,
        itemBuilder: (context, index) {
          final court = courts[index];
          final isSelected = court.id == selectedCourtId;

          return GestureDetector(
            onTap: court.isAvailable ? () => onCourtSelected(court.id) : null,
            child: Container(
              width: 120,
              margin: EdgeInsets.only(
                right: index < courts.length - 1 ? 12 : 0,
              ),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withOpacity(0.1)
                    : court.isAvailable
                    ? Colors.white
                    : Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : court.isAvailable
                      ? AppColors.border
                      : Colors.grey[300]!,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.sports_tennis,
                    color: isSelected
                        ? AppColors.primary
                        : court.isAvailable
                        ? AppColors.textPrimary
                        : Colors.grey,
                    size: 28,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    court.name,
                    style: TextStyle(
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                      color: isSelected
                          ? AppColors.primary
                          : court.isAvailable
                          ? AppColors.textPrimary
                          : Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    court.isAvailable
                        ? '${court.pricePerHour.toStringAsFixed(0)}đ/h'
                        : 'Bảo trì',
                    style: TextStyle(
                      fontSize: 11,
                      color: court.isAvailable
                          ? AppColors.textSecondary
                          : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
