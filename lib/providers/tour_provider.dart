import 'package:flutter/foundation.dart';
import '../models/tour.dart';
import '../models/city_stay.dart';
import '../models/expense.dart';
import '../database/database_helper.dart';

class TourProvider with ChangeNotifier {
  List<Tour> _tours = [];
  List<CityStay> _currentCityStays = [];
  List<Expense> _currentExpenses = [];
  
  bool _isLoading = false;

  List<Tour> get tours => _tours;
  List<CityStay> get currentCityStays => _currentCityStays;
  List<Expense> get currentExpenses => _currentExpenses;
  bool get isLoading => _isLoading;

  double _currentTourAdvanceDeducted = 0.0;
  double _currentTourMiscDeducted = 0.0;

  double get currentTourAdvanceDeducted => _currentTourAdvanceDeducted;
  double get currentTourMiscDeducted => _currentTourMiscDeducted;

  final dbHelper = DatabaseHelper.instance;

  // --- Toures ---
  Future<void> loadTours() async {
    _isLoading = true;
    notifyListeners();
    _tours = await dbHelper.getTours();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addTour(Tour tour) async {
    await dbHelper.insertTour(tour);
    await loadTours();
  }

  Future<void> updateTour(Tour tour) async {
    await dbHelper.updateTour(tour);
    await loadTours();
  }

  Future<void> deleteTour(String id) async {
    await dbHelper.deleteTour(id);
    await loadTours();
  }

  Future<void> loadTourDeductions(String tourId) async {
    _currentTourAdvanceDeducted = await dbHelper.getDeductedAmountForTour(tourId, 'Advance Cash');
    _currentTourMiscDeducted = await dbHelper.getDeductedAmountForTour(tourId, 'Miscellaneous');
    notifyListeners();
  }

  // --- City Stays ---
  Future<void> loadCityStays(String tourId) async {
    _isLoading = true;
    notifyListeners();
    _currentCityStays = await dbHelper.getCityStays(tourId);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addCityStay(CityStay cityStay) async {
    await dbHelper.insertCityStay(cityStay);
    await loadCityStays(cityStay.tourId);
  }

  Future<void> updateCityStay(CityStay cityStay) async {
    await dbHelper.updateCityStay(cityStay);
    await loadCityStays(cityStay.tourId);
  }

  Future<void> deleteCityStay(String id, String tourId) async {
    await dbHelper.deleteCityStay(id);
    await loadCityStays(tourId);
  }

  // --- Expenses ---
  Future<void> loadExpenses(String cityStayId) async {
    _isLoading = true;
    notifyListeners();
    _currentExpenses = await dbHelper.getExpenses(cityStayId);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addExpense(Expense expense) async {
    await dbHelper.insertExpense(expense);
    await loadExpenses(expense.cityStayId);
    _refreshTourDeductionsForCityStay(expense.cityStayId);
  }

  Future<void> updateExpense(Expense expense) async {
    await dbHelper.updateExpense(expense);
    await loadExpenses(expense.cityStayId);
    _refreshTourDeductionsForCityStay(expense.cityStayId);
  }

  Future<void> deleteExpense(String id, String cityStayId) async {
    await dbHelper.deleteExpense(id);
    await loadExpenses(cityStayId);
    _refreshTourDeductionsForCityStay(cityStayId);
  }

  void _refreshTourDeductionsForCityStay(String cityStayId) {
    try {
      final cityStay = _currentCityStays.firstWhere((cs) => cs.id == cityStayId);
      loadTourDeductions(cityStay.tourId);
    } catch (e) {
      // Ignored if city stay is not in the list for some reason
    }
  }

  // Utilities
  double getTotalExpensesForCityStay(String cityStayId) {
    if (_currentExpenses.isEmpty) return 0.0;
    // Assuming UI loaded the expenses for this city stay.
    return _currentExpenses
        .where((e) => e.cityStayId == cityStayId)
        .fold(0.0, (sum, item) => sum + item.amount);
  }
}
