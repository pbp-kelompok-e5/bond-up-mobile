import 'package:flutter/material.dart';
import 'package:bond_up_mobile/features/partner_matching/data/datasources/partner_matching_remote_datasource.dart';
import 'package:bond_up_mobile/features/partner_matching/data/model/connection_model.dart';
import 'package:bond_up_mobile/features/partner_matching/data/model/user_match_model.dart';

class ConnectionsProvider extends ChangeNotifier {
  final PartnerMatchingRemoteDataSource dataSource;

  ConnectionsProvider(this.dataSource);

  // STATE 
  Connection? _data;
  bool _isLoading = false;
  String _errorMessage = '';

  // GETTERS
  List<UserMatchModel> get myFriends => _data?.myFriends ?? [];
  List<UserMatchModel> get receivedRequests => _data?.receivedRequests ?? [];
  List<UserMatchModel> get sentRequests => _data?.sentRequests ?? [];
  List<UserMatchModel> get recommendations => _data?.recommendations ?? [];
  
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  // ACTIONS 

  // 1. Fetch Data Awal
  Future<void> loadConnections() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final result = await dataSource.fetchConnections();
      _data = result;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 2. Handle Action (Accept, Reject, Remove, Cancel, Connect)
  Future<void> handleAction(String action, int userId) async {
    
    try {
      final success = await dataSource.sendConnectionAction(action, userId);
      
      if (success) {
        // Jika sukses, refresh data connections
        await loadConnections();
      } else {
        // Error handling jika aksi gagal
        print("Gagal melakukan aksi $action");
      }
    } catch (e) {
      print("Error action: $e");
    }
  }
}