import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/booking_model.dart';

class TimeSlotGrid extends StatelessWidget {
  final List<TimeSlotModel> timeSlots;
  final List<TimeSlotModel> selectedSlots;
  final Function(TimeSlotModel) onSlotTap;

  const TimeSlotGrid({
    super.key,
    required this.timeSlots,
    required this.selectedSlots,
    required this.onSlotTap,
  });

  @override
  Widget build(BuildContext context) {
    if (timeSlots.isEmpty) {
      return Container(
        height: 150,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 8),
            const Text('Không có khung giờ nào'),
          ],
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.8,
      ),
      itemCount: timeSlots.length,
      itemBuilder: (context, index) {
        final slot = timeSlots[index];
        final isSelected = selectedSlots.any((s) => s.id == slot.id);
        final isAvailable = slot.isAvailable;

        return GestureDetector(
          onTap: isAvailable ? () => onSlotTap(slot) : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: _getBackgroundColor(isAvailable, isSelected),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _getBorderColor(isAvailable, isSelected),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  slot.startTime,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: _getTextColor(isAvailable, isSelected),
                  ),
                ),
                Text(
                  '${slot.price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}đ',
                  style: TextStyle(
                    fontSize: 10,
                    color: _getTextColor(
                      isAvailable,
                      isSelected,
                    ).withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getBackgroundColor(bool isAvailable, bool isSelected) {
    if (!isAvailable) {
      return Colors.grey[200]!;
    }
    if (isSelected) {
      return AppColors.primary.withOpacity(0.15);
    }
    return Colors.white;
  }

  Color _getBorderColor(bool isAvailable, bool isSelected) {
    if (!isAvailable) {
      return Colors.grey[300]!;
    }
    if (isSelected) {
      return AppColors.primary;
    }
    return AppColors.success;
  }

  Color _getTextColor(bool isAvailable, bool isSelected) {
    if (!isAvailable) {
      return Colors.grey;
    }
    if (isSelected) {
      return AppColors.primary;
    }
    return AppColors.textPrimary;
  }
}
