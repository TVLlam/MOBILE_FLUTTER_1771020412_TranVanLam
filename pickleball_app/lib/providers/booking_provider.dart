import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/models.dart';
import '../data/services/services.dart';

// Booking Service Provider
final bookingServiceProvider = Provider<BookingService>(
  (ref) => BookingService(),
);

// Courts Provider
final courtsProvider = FutureProvider<List<CourtModel>>((ref) async {
  final bookingService = ref.read(bookingServiceProvider);
  return bookingService.getCourts();
});

// Selected Date Provider
final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

// Selected Court Provider
final selectedCourtProvider = StateProvider<CourtModel?>((ref) => null);

// =============================================================================
// BOOKING STATE & NOTIFIER
// =============================================================================

class BookingState {
  final List<BookingModel> myBookings;
  final List<CourtModel> courts;
  final List<TimeSlotModel> timeSlots;
  final List<TimeSlotModel> selectedSlots;
  final int? selectedCourtId;
  final bool isLoading;
  final bool hasMore;
  final int currentPage;
  final String? error;

  const BookingState({
    this.myBookings = const [],
    this.courts = const [],
    this.timeSlots = const [],
    this.selectedSlots = const [],
    this.selectedCourtId,
    this.isLoading = false,
    this.hasMore = true,
    this.currentPage = 1,
    this.error,
  });

  BookingState copyWith({
    List<BookingModel>? myBookings,
    List<CourtModel>? courts,
    List<TimeSlotModel>? timeSlots,
    List<TimeSlotModel>? selectedSlots,
    int? selectedCourtId,
    bool? isLoading,
    bool? hasMore,
    int? currentPage,
    String? error,
    bool clearSelectedCourt = false,
  }) {
    return BookingState(
      myBookings: myBookings ?? this.myBookings,
      courts: courts ?? this.courts,
      timeSlots: timeSlots ?? this.timeSlots,
      selectedCourtId: clearSelectedCourt
          ? null
          : (selectedCourtId ?? this.selectedCourtId),
      selectedSlots: selectedSlots ?? this.selectedSlots,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      error: error,
    );
  }
}

class BookingNotifier extends StateNotifier<BookingState> {
  final BookingService _bookingService;

  BookingNotifier(this._bookingService) : super(const BookingState());

  // Load courts
  Future<void> loadCourts() async {
    try {
      final courts = await _bookingService.getCourts();
      state = state.copyWith(courts: courts);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // Load time slots for a court and date
  Future<void> loadTimeSlots(DateTime date, {int? courtId}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final targetCourtId = courtId ?? state.selectedCourtId;
      if (targetCourtId == null) {
        // If no court selected, load slots for all courts
        if (state.courts.isEmpty) await loadCourts();
        final allSlots = <TimeSlotModel>[];
        for (final court in state.courts) {
          final slots = await _bookingService.getAvailableSlots(court.id, date);
          allSlots.addAll(slots);
        }
        state = state.copyWith(
          timeSlots: allSlots,
          isLoading: false,
          selectedSlots: [],
        );
      } else {
        final slots = await _bookingService.getAvailableSlots(
          targetCourtId,
          date,
        );
        state = state.copyWith(
          timeSlots: slots,
          selectedCourtId: targetCourtId,
          isLoading: false,
          selectedSlots: [],
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // Select a court
  void selectCourt(int courtId) {
    state = state.copyWith(selectedCourtId: courtId);
  }

  // Toggle slot selection
  void toggleSlotSelection(TimeSlotModel slot) {
    final currentSelection = List<TimeSlotModel>.from(state.selectedSlots);
    final index = currentSelection.indexWhere(
      (s) => s.startTime == slot.startTime,
    );

    if (index >= 0) {
      currentSelection.removeAt(index);
    } else {
      if (slot.isAvailable) {
        currentSelection.add(slot);
      }
    }

    state = state.copyWith(selectedSlots: currentSelection);
  }

  // Clear slot selection
  void clearSlotSelection() {
    state = state.copyWith(selectedSlots: []);
  }

  // Load my bookings
  Future<void> loadMyBookings({bool refresh = false}) async {
    if (state.isLoading) return;
    if (!refresh && !state.hasMore) return;

    final page = refresh ? 1 : state.currentPage;
    state = state.copyWith(isLoading: true, error: null);

    try {
      final bookings = await _bookingService.getMyBookings(page: page);

      state = state.copyWith(
        myBookings: refresh ? bookings : [...state.myBookings, ...bookings],
        isLoading: false,
        hasMore: bookings.length >= 20,
        currentPage: page + 1,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // Create booking
  Future<bool> createBooking({
    required int courtId,
    required DateTime bookingDate,
    required List<String> slotIds,
    String? note,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // Find corresponding slots to get start/end times
      final selectedSlots = state.timeSlots
          .where((slot) => slotIds.contains(slot.id))
          .toList();

      if (selectedSlots.isEmpty) {
        state = state.copyWith(isLoading: false, error: 'No slots selected');
        return false;
      }

      // Sort slots by start time and get earliest start and latest end
      selectedSlots.sort((a, b) => a.startTime.compareTo(b.startTime));
      final startTime = selectedSlots.first.startTime;
      final endTime = selectedSlots.last.endTime;

      final request = CreateBookingRequest(
        courtId: courtId,
        date: bookingDate,
        startTime: startTime,
        endTime: endTime,
        note: note,
      );
      await _bookingService.createBooking(request);
      await loadMyBookings(refresh: true);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  // Cancel booking
  Future<bool> cancelBooking(int bookingId) async {
    try {
      await _bookingService.cancelBooking(bookingId);
      await loadMyBookings(refresh: true);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  void reset() {
    state = const BookingState();
  }
}

// =============================================================================
// PROVIDERS
// =============================================================================

// Main Booking Provider
final bookingProvider = StateNotifierProvider<BookingNotifier, BookingState>((
  ref,
) {
  return BookingNotifier(ref.read(bookingServiceProvider));
});

// Alias for backward compatibility
final myBookingsProvider = bookingProvider;

// My Bookings State (alias)
typedef MyBookingsState = BookingState;
typedef MyBookingsNotifier = BookingNotifier;

// Booking Calendar State
class BookingCalendarState {
  final List<BookingCalendarItem> bookings;
  final bool isLoading;
  final String? error;

  const BookingCalendarState({
    this.bookings = const [],
    this.isLoading = false,
    this.error,
  });

  BookingCalendarState copyWith({
    List<BookingCalendarItem>? bookings,
    bool? isLoading,
    String? error,
  }) {
    return BookingCalendarState(
      bookings: bookings ?? this.bookings,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class BookingCalendarNotifier extends StateNotifier<BookingCalendarState> {
  final BookingService _bookingService;

  BookingCalendarNotifier(this._bookingService)
    : super(const BookingCalendarState());

  Future<void> loadCalendar(DateTime from, DateTime to) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final bookings = await _bookingService.getCalendar(from, to);
      state = state.copyWith(bookings: bookings, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void addBooking(BookingCalendarItem booking) {
    state = state.copyWith(bookings: [...state.bookings, booking]);
  }

  void updateBooking(BookingCalendarItem booking) {
    final bookings = state.bookings.map((b) {
      return b.id == booking.id ? booking : b;
    }).toList();
    state = state.copyWith(bookings: bookings);
  }

  void removeBooking(String bookingId) {
    final bookings = state.bookings.where((b) => b.id != bookingId).toList();
    state = state.copyWith(bookings: bookings);
  }
}

// Booking Calendar Provider
final bookingCalendarProvider =
    StateNotifierProvider<BookingCalendarNotifier, BookingCalendarState>((ref) {
      return BookingCalendarNotifier(ref.read(bookingServiceProvider));
    });

// Available Slots Provider
final availableSlotsProvider =
    FutureProvider.family<List<TimeSlotModel>, ({int courtId, DateTime date})>((
      ref,
      params,
    ) async {
      final bookingService = ref.read(bookingServiceProvider);
      return bookingService.getAvailableSlots(params.courtId, params.date);
    });
