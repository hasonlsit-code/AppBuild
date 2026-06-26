import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../services/database_service.dart';

class TaskViewModel extends ChangeNotifier {
  List<TaskModel> _allTasks = [];
  List<TaskModel> filteredTasks = [];
  String searchQuery = '';
  int? statusFilter;
  bool isLoading = false;

  final _db = DatabaseService();

  Future<void> loadTasks() async {
    isLoading = true;
    notifyListeners();

    _allTasks = await _db.getAllTasks();
    _applyFilter();

    isLoading = false;
    notifyListeners();
  }

  Future<void> addTask(TaskModel task) async {
    await _db.insertTask(task);
    await loadTasks();
  }

  Future<void> toggleStatus(int id, int currentStatus) async {
    final newStatus = currentStatus == 0 ? 1 : 0;
    await _db.updateTaskStatus(id, newStatus);
    await loadTasks();
  }

  Future<void> deleteTask(int id) async {
    await _db.deleteTask(id);
    await loadTasks();
  }

  void setSearch(String query) {
    searchQuery = query;
    _applyFilter();
    notifyListeners();
  }

  void setStatusFilter(int? status) {
    statusFilter = status;
    _applyFilter();
    notifyListeners();
  }

  void _applyFilter() {
    filteredTasks = _allTasks.where((task) {
      final matchesSearch = searchQuery.isEmpty ||
          task.title.toLowerCase().contains(searchQuery.toLowerCase());
      final matchesStatus = statusFilter == null || task.status == statusFilter;
      return matchesSearch && matchesStatus;
    }).toList();
  }
}
