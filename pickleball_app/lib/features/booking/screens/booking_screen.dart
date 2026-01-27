import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/booking_model.dart';
import '../../../data/models/enums.dart';
import '../../../providers/providers.dart';
import '../widgets/time_slot_grid.dart';
import '../widgets/court_selector.dart';

class BookingScreen extends ConsumerStatefulWidget {
  const BookingScreen({super.key});

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedDate = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.week;
  int _selectedCourtId = 1;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await ref.read(bookingProvider.notifier).loadCourts();
    await ref.read(bookingProvider.notifier).loadTimeSlots(_selectedDate);
    await ref.read(bookingProvider.notifier).loadMyBookings();
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDate = selectedDay;
    });
    ref.read(bookingProvider.notifier).loadTimeSlots(selectedDay);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đặt sân'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.calendar_today), text: 'Đặt sân'),
            Tab(icon: Icon(Icons.history), text: 'Lịch sử đặt'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildBookingTab(), _buildHistoryTab()],
      ),
    );
  }

  Widget _buildBookingTab() {
    final bookingState = ref.watch(bookingProvider);

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(bookingProvider.notifier).loadTimeSlots(_selectedDate),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Calendar
            _buildCalendar(),
            const Divider(height: 1),

            // Court selector
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Chọn sân', style: AppTextStyles.heading3),
                  const SizedBox(height: 12),
                  CourtSelector(
                    courts: bookingState.courts,
                    selectedCourtId: _selectedCourtId,
                    onCourtSelected: (id) {
                      setState(() => _selectedCourtId = id);
                    },
                  ),
                ],
              ),
            ),

            // Time slots
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Chọn khung giờ',
                        style: AppTextStyles.heading3,
                      ),
                      _buildLegend(),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (bookingState.isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else
                    TimeSlotGrid(
                      timeSlots: bookingState.timeSlots,
                      selectedSlots: bookingState.selectedSlots,
                      onSlotTap: (slot) {
                        ref
                            .read(bookingProvider.notifier)
                            .toggleSlotSelection(slot);
                      },
                    ),
                ],
              ),
            ),

            // Booking summary
            if (bookingState.selectedSlots.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildBookingSummary(bookingState),
            ],

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    return TableCalendar(
      firstDay: DateTime.now(),
      lastDay: DateTime.now().add(const Duration(days: 30)),
      focusedDay: _selectedDate,
      selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
      calendarFormat: _calendarFormat,
      onDaySelected: _onDaySelected,
      onFormatChanged: (format) {
        setState(() => _calendarFormat = format);
      },
      locale: 'vi_VN',
      startingDayOfWeek: StartingDayOfWeek.monday,
      calendarStyle: CalendarStyle(
        selectedDecoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        todayDecoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.3),
          shape: BoxShape.circle,
        ),
        markersMaxCount: 3,
      ),
      headerStyle: const HeaderStyle(
        formatButtonVisible: true,
        titleCentered: true,
        formatButtonDecoration: BoxDecoration(
          border: Border.fromBorderSide(BorderSide(color: AppColors.primary)),
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      children: [
        _buildLegendItem(AppColors.success, 'Trống'),
        const SizedBox(width: 8),
        _buildLegendItem(AppColors.error, 'Đã đặt'),
        const SizedBox(width: 8),
        _buildLegendItem(AppColors.primary, 'Đang chọn'),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label) {
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
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }

  Widget _buildBookingSummary(BookingState bookingState) {
    final totalPrice = bookingState.selectedSlots.fold<double>(
      0,
      (sum, slot) => sum + slot.price,
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${bookingState.selectedSlots.length} khung giờ đã chọn',
                style: AppTextStyles.bodyLarge,
              ),
              Text(
                '${totalPrice.toStringAsFixed(0)}đ',
                style: AppTextStyles.heading2.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                context.push(
                  '/booking/create',
                  extra: {
                    'selectedDate': _selectedDate,
                    'courtId': _selectedCourtId,
                    'slots': bookingState.selectedSlots,
                  },
                );
              },
              child: const Text('TIẾP TỤC ĐẶT SÂN'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    final bookingState = ref.watch(bookingProvider);

    if (bookingState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (bookingState.myBookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            const Text('Chưa có lịch đặt sân nào'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bookingState.myBookings.length,
      itemBuilder: (context, index) {
        final booking = bookingState.myBookings[index];
        return _buildBookingCard(booking);
      },
    );
  }

  Widget _buildBookingCard(BookingModel booking) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => context.push('/booking/detail/${booking.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Sân ${booking.courtId}', style: AppTextStyles.heading3),
                  _buildStatusChip(booking.status),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatDate(booking.bookingDate),
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.access_time,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${booking.startTime} - ${booking.endTime}',
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Tổng tiền:', style: AppTextStyles.bodyMedium),
                  Text(
                    '${booking.totalPrice.toStringAsFixed(0)}đ',
                    style: AppTextStyles.heading3.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(BookingStatus status) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status) {
      case BookingStatus.pending:
        bgColor = AppColors.warning.withOpacity(0.2);
        textColor = AppColors.warning;
        label = 'Chờ xác nhận';
        break;
      case BookingStatus.pendingPayment:
        bgColor = AppColors.warning.withOpacity(0.3);
        textColor = AppColors.warning;
        label = 'Chờ thanh toán';
        break;
      case BookingStatus.confirmed:
        bgColor = AppColors.success.withOpacity(0.2);
        textColor = AppColors.success;
        label = 'Đã xác nhận';
        break;
      case BookingStatus.cancelled:
        bgColor = AppColors.error.withOpacity(0.2);
        textColor = AppColors.error;
        label = 'Đã hủy';
        break;
      case BookingStatus.completed:
        bgColor = AppColors.info.withOpacity(0.2);
        textColor = AppColors.info;
        label = 'Hoàn thành';
        break;
      case BookingStatus.holding:
        bgColor = AppColors.primary.withOpacity(0.2);
        textColor = AppColors.primary;
        label = 'Đang giữ';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
