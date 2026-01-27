import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/booking_model.dart';
import '../../../providers/providers.dart';

class CreateBookingScreen extends ConsumerStatefulWidget {
  final DateTime selectedDate;
  final int courtId;
  final List<TimeSlotModel> slots;

  const CreateBookingScreen({
    super.key,
    required this.selectedDate,
    required this.courtId,
    required this.slots,
  });

  @override
  ConsumerState<CreateBookingScreen> createState() =>
      _CreateBookingScreenState();
}

class _CreateBookingScreenState extends ConsumerState<CreateBookingScreen> {
  final _noteController = TextEditingController();
  bool _isLoading = false;
  bool _useWalletBalance = true;

  double get _totalPrice =>
      widget.slots.fold(0, (sum, slot) => sum + slot.price);

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _confirmBooking() async {
    setState(() => _isLoading = true);

    final walletBalance = ref.read(walletBalanceProvider);

    if (_useWalletBalance && walletBalance < _totalPrice) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Số dư ví không đủ. Vui lòng nạp thêm tiền.'),
          backgroundColor: AppColors.error,
        ),
      );
      setState(() => _isLoading = false);
      return;
    }

    final success = await ref
        .read(bookingProvider.notifier)
        .createBooking(
          courtId: widget.courtId,
          bookingDate: widget.selectedDate,
          slotIds: widget.slots.map((s) => s.id).toList(),
          note: _noteController.text.isNotEmpty ? _noteController.text : null,
        );

    setState(() => _isLoading = false);

    if (success && mounted) {
      await ref.read(authProvider.notifier).refreshUser();
      _showSuccessDialog();
    } else if (mounted) {
      final error = ref.read(bookingProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Có lỗi xảy ra'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: AppColors.success,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Đặt sân thành công!',
              style: AppTextStyles.heading2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Vui lòng đến đúng giờ để chơi. Xem chi tiết trong lịch sử đặt sân.',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.go('/booking');
              },
              child: const Text('XONG'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final walletBalance = ref.watch(walletBalanceProvider);
    final bookingState = ref.watch(bookingProvider);
    final court = bookingState.courts.firstWhere(
      (c) => c.id == widget.courtId,
      orElse: () => bookingState.courts.first,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Xác nhận đặt sân')),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Booking summary card
                  _buildSummaryCard(court),
                  const SizedBox(height: 24),

                  // Selected time slots
                  const Text(
                    'Khung giờ đã chọn',
                    style: AppTextStyles.heading3,
                  ),
                  const SizedBox(height: 12),
                  _buildTimeSlotsList(),
                  const SizedBox(height: 24),

                  // Note input
                  const Text(
                    'Ghi chú (không bắt buộc)',
                    style: AppTextStyles.heading3,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _noteController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Nhập ghi chú cho lịch đặt sân...',
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Payment method
                  const Text(
                    'Phương thức thanh toán',
                    style: AppTextStyles.heading3,
                  ),
                  const SizedBox(height: 12),
                  _buildPaymentOption(walletBalance),
                ],
              ),
            ),
          ),

          // Bottom bar
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(court) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.sports_tennis, color: Colors.white, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      court.name,
                      style: AppTextStyles.heading2.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      court.description ?? 'Sân Pickleball tiêu chuẩn',
                      style: TextStyle(color: Colors.white.withOpacity(0.8)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoItem(
                  Icons.calendar_today,
                  'Ngày',
                  '${widget.selectedDate.day}/${widget.selectedDate.month}',
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.white.withOpacity(0.3),
                ),
                _buildInfoItem(
                  Icons.access_time,
                  'Số slot',
                  '${widget.slots.length}',
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.white.withOpacity(0.3),
                ),
                _buildInfoItem(
                  Icons.timer,
                  'Tổng giờ',
                  '${widget.slots.length}h',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSlotsList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: widget.slots.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final slot = widget.slots[index];
          return ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.access_time, color: AppColors.primary),
            ),
            title: Text('${slot.startTime} - ${slot.endTime}'),
            trailing: Text(
              '${slot.price.toStringAsFixed(0)}đ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPaymentOption(double walletBalance) {
    return GestureDetector(
      onTap: () => setState(() => _useWalletBalance = !_useWalletBalance),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _useWalletBalance ? AppColors.primary : AppColors.border,
            width: _useWalletBalance ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.account_balance_wallet,
                color: AppColors.success,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Ví CLB', style: AppTextStyles.bodyLarge),
                  Text(
                    'Số dư: ${walletBalance.toStringAsFixed(0)}đ',
                    style: TextStyle(
                      color: walletBalance >= _totalPrice
                          ? AppColors.success
                          : AppColors.error,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Radio<bool>(
              value: true,
              groupValue: _useWalletBalance,
              onChanged: (value) => setState(() => _useWalletBalance = value!),
              activeColor: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Tổng cộng', style: AppTextStyles.caption),
                  Text(
                    '${_totalPrice.toStringAsFixed(0)}đ',
                    style: AppTextStyles.heading2.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: _isLoading ? null : _confirmBooking,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('XÁC NHẬN'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
