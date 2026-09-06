import 'dart:async';
import 'package:coreaxis/features/customer_solution/domain/models/customer_solution.dart';
import 'package:coreaxis/features/customer_solution/domain/models/customer_solution_lifecycle.dart';

class MockCustomerSolutionRepository {
  // Authoritative in-memory state
  final List<CustomerSolution> _solutions = [];
  
  MockCustomerSolutionRepository() {
    // Optionally seed data here if needed, but for now we start empty.
  }
  
  Future<List<CustomerSolution>> getSolutions() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.unmodifiable(_solutions);
  }

  Future<List<CustomerSolution>> getSolutionsForTenant(String tenantId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _solutions.where((s) => s.tenantId == tenantId).toList();
  }

  Future<CustomerSolution?> getSolutionById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _solutions.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<CustomerSolution> createSolution(CustomerSolution solution) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Ensure the ID is unique
    if (_solutions.any((s) => s.id == solution.id)) {
      throw Exception('A Customer Solution with this ID already exists.');
    }
    
    _solutions.add(solution);
    return solution;
  }
  
  Future<CustomerSolution> updateLifecycle(String id, CustomerSolutionLifecycle newState) async {
    await Future.delayed(const Duration(milliseconds: 400));
    
    final index = _solutions.indexWhere((s) => s.id == id);
    if (index == -1) {
      throw Exception('Customer Solution not found.');
    }
    
    final current = _solutions[index];
    
    // Validate transitions
    if (current.lifecycleState == CustomerSolutionLifecycle.provisioning && newState == CustomerSolutionLifecycle.suspended) {
      throw Exception('Cannot transition directly from provisioning to suspended.');
    }
    
    final updated = current.copyWith(
      lifecycleState: newState,
      updatedAt: DateTime.now(),
    );
    
    _solutions[index] = updated;
    return updated;
  }

  Future<CustomerSolution> updateSolution(CustomerSolution solution) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final index = _solutions.indexWhere((s) => s.id == solution.id);
    if (index == -1) throw Exception('Customer Solution not found.');
    
    _solutions[index] = solution;
    return solution;
  }
}
