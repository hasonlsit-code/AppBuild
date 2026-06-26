import 'package:flutter/material.dart';
import '../services/database_service.dart';

class HomeViewModel extends ChangeNotifier {
  int totalTasks = 0;
  int completedTasks = 0;
  int pendingTasks = 0;
  bool isLoading = false;

  final _db = DatabaseService();

  Future<void> loadStats() async {
    isLoading = true;
    notifyListeners();

    totalTasks = await _db.getTotalCount();
    completedTasks = await _db.getCompletedCount();
    pendingTasks = await _db.getPendingCount();

    isLoading = false;
    notifyListeners();
  }
}
