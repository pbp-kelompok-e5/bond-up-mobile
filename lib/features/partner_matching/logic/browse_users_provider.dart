import 'package:bond_up_mobile/features/partner_matching/data/models/user_match_model.dart';
import 'package:flutter/material.dart';
import '../data/services/partner_matching_service.dart';

class BrowseUsersProvider extends ChangeNotifier {
  final PartnerMatchingService dataSource;

  // Constructor menerima datasource (Dependency Injection)
  BrowseUsersProvider(this.dataSource);

  // STATE VARIABLES
  List<UserMatchModel> _users = [];
  bool _isLoading = false;
  String _errorMessage = '';

  String _selectedSport = '';
  String _selectedSkill = '';
  String _selectedCity = '';
  String _currentQuery = '';

  List<UserMatchModel> get users => _users;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  String get selectedSport => _selectedSport;
  String get selectedSkill => _selectedSkill;
  String get selectedCity => _selectedCity;

  void applyFilters({String? sport, String? skill, String? city}) {
    if (sport != null) _selectedSport = sport;
    if (skill != null) _selectedSkill = skill;
    if (city != null) _selectedCity = city;

    searchUsers(query: _currentQuery);
  }

  void clearFilters() {
    _selectedSport = '';
    _selectedSkill = '';
    _selectedCity = '';

    searchUsers(query: _currentQuery);
  }

  // Fungsi utama untuk mengambil data user
  Future<void> searchUsers({String query = ''}) async {
    _currentQuery = query;
    // 1. Set status jadi Loading & Beri tahu UI
    _isLoading = true;
    _errorMessage = '';
    notifyListeners(); // Update UI supaya nampilin loading spinner

    try {
      // 2. Panggil Datasource buat ambil data
      final result = await dataSource.fetchUsers(
        query: query,
        sport: _selectedSport,
        skill: _selectedSkill,
        city: _selectedCity,
      );

      // 3. Kalau sukses, simpan data
      _users = result;
    } catch (e) {
      // 4. Kalau gagal, simpan error
      _errorMessage = e.toString();
      _users = []; // Kosongkan list kalau error
    } finally {
      // 5. Matikan loading, apapun hasilnya
      _isLoading = false;
      notifyListeners(); // Update UI lagi (Loading spinner hilang)
    }
  }

  // Fungsi helper buat reset state (misal pas keluar halaman)
  void clear() {
    _users = [];
    _isLoading = false;
    _errorMessage = '';
    notifyListeners();
  }
}
