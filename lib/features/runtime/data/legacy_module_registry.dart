import 'package:flutter/material.dart';
import '../domain/models/module_runtime_descriptor.dart';

/// A Strangler Pattern registry mapping Marketplace/Blueprint module codes to 
/// complete [ModuleRuntimeDescriptor] objects.
/// 
/// This allows existing Legacy Business Modules to be mounted by the generic 
/// Tenant Runtime without modifying the legacy module source code.
/// 
/// It acts purely as a runtime adapter/lookup, NOT as a secondary business 
/// module catalog or dependency authority.
class LegacyModuleRegistry {
  static const Map<String, ModuleRuntimeDescriptor> _descriptors = {
    'CORE_SALES': ModuleRuntimeDescriptor(
      moduleCode: 'CORE_SALES',
      displayName: 'Sales',
      icon: Icons.monetization_on_outlined,
      requiredPermission: 'manage_sales_orders', // Maps to existing RBAC permission
      primaryRoute: '/sales-orders',
      routePrefixes: ['/sales-orders', '/quotations', '/customers', '/inquiries'],
    ),
    'CORE_PRODUCTION': ModuleRuntimeDescriptor(
      moduleCode: 'CORE_PRODUCTION',
      displayName: 'Production',
      icon: Icons.precision_manufacturing_outlined,
      requiredPermission: 'manage_production_orders',
      primaryRoute: '/production',
      routePrefixes: ['/production', '/bom', '/job-orders'],
    ),
    'CORE_REPORTS': ModuleRuntimeDescriptor(
      moduleCode: 'CORE_REPORTS',
      displayName: 'Reports',
      icon: Icons.bar_chart_outlined,
      requiredPermission: 'view_reports',
      primaryRoute: '/reports',
      routePrefixes: ['/reports'],
    ),
    'CORE_USERS': ModuleRuntimeDescriptor(
      moduleCode: 'CORE_USERS',
      displayName: 'Users',
      icon: Icons.people_outline,
      requiredPermission: 'manage_users',
      primaryRoute: '/users',
      routePrefixes: ['/users'],
    ),
    'CORE_ROLES': ModuleRuntimeDescriptor(
      moduleCode: 'CORE_ROLES',
      displayName: 'Roles',
      icon: Icons.admin_panel_settings_outlined,
      requiredPermission: 'manage_roles',
      primaryRoute: '/roles',
      routePrefixes: ['/roles'],
    ),
    'CORE_DASHBOARD': ModuleRuntimeDescriptor(
      moduleCode: 'CORE_DASHBOARD',
      displayName: 'Dashboard',
      icon: Icons.dashboard_outlined,
      requiredPermission: 'view_dashboard',
      primaryRoute: '/dashboard',
      routePrefixes: ['/dashboard', '/sales-dashboard', '/manufacturing-dashboard', '/delivery-dashboard'],
    ),
    'CORE_INVENTORY': ModuleRuntimeDescriptor(
      moduleCode: 'CORE_INVENTORY',
      displayName: 'Inventory',
      icon: Icons.inventory_2_outlined,
      // Fallback permission assumption for mock purposes, but uses explicit existing API
      requiredPermission: 'manage_inventory', 
      primaryRoute: '/inventory',
      routePrefixes: ['/inventory', '/delivery'],
    ),
    'CORE_FINANCE': ModuleRuntimeDescriptor(
      moduleCode: 'CORE_FINANCE',
      displayName: 'Finance',
      icon: Icons.account_balance_wallet_outlined,
      requiredPermission: 'manage_finance',
      primaryRoute: '/finance',
      routePrefixes: ['/finance', '/invoices'],
    ),
    'CORE_CATALOG': ModuleRuntimeDescriptor(
      moduleCode: 'CORE_CATALOG',
      displayName: 'Catalog',
      icon: Icons.category_outlined,
      requiredPermission: 'manage_catalog',
      primaryRoute: '/catalog',
      routePrefixes: ['/catalog'],
    ),
  };

  /// Retrieve all registered descriptors
  static List<ModuleRuntimeDescriptor> get allDescriptors => _descriptors.values.toList();

  /// Retrieve a descriptor by its exact module code
  static ModuleRuntimeDescriptor? getDescriptor(String moduleCode) {
    return _descriptors[moduleCode];
  }
}
