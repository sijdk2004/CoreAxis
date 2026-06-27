import 'package:dio/dio.dart';

class MockDataInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Determine the route and return mock data if it matches known endpoints
    final path = options.path;

    if (path.endsWith('/v1/auth/login')) {
      return handler.resolve(Response(
        requestOptions: options,
        statusCode: 200,
        data: {
          'data': {
            'token': 'mock_access_token',
            'user': {
              'id': '1',
              'username': options.data['username'] ?? 'admin@erp.com',
              'email': options.data['username'] ?? 'admin@erp.com',
              'first_name': 'Mock',
              'last_name': 'User',
              'role': 'Admin',
              'permissions': ['PLATFORM_ADMIN'],
              'avatar_url': '',
              'status': 'active',
              'department': 'IT',
              'tenant_id': options.data['tenant_id'] ?? 'SYSTEM_TENANT',
            }
          }
        },
      ));
    }

    if (path.endsWith('/v1/system/menus')) {
      return handler.resolve(Response(
        requestOptions: options,
        statusCode: 200,
        data: {
          'data': [
            {"MenuName": "CEO Dashboard", "ScreenCode": "DSH_HOME", "IconName": "pieChart", "ModuleCode": "DSH"},
            {"MenuName": "Sales Dashboard", "ScreenCode": "SLS_DSH", "IconName": "barChart", "ModuleCode": "SLS"},
            {"MenuName": "Master Data", "ScreenCode": "SYS_MASTER_DATA", "IconName": "settings", "ModuleCode": "SYS"},
            {"MenuName": "Quotations", "ScreenCode": "QTN_LIST", "IconName": "fileText", "ModuleCode": "QTN"},
            {"MenuName": "Sales Orders", "ScreenCode": "SO_LIST", "IconName": "shoppingCart", "ModuleCode": "SO"},
            {"MenuName": "Manufacturing Dashboard", "ScreenCode": "MFG_DSH", "IconName": "factory", "ModuleCode": "MFG"},
            {"MenuName": "Delivery Dashboard", "ScreenCode": "DLV_DSH", "IconName": "truck", "ModuleCode": "DLV"},
            {"MenuName": "Users", "ScreenCode": "USR_LIST", "IconName": "users", "ModuleCode": "USR"},
            {"MenuName": "Customers", "ScreenCode": "CUS_LIST", "IconName": "users", "ModuleCode": "CUS"},
            {"MenuName": "Roles", "ScreenCode": "ROL_LIST", "IconName": "users", "ModuleCode": "ROL"},
            {"MenuName": "Catalog", "ScreenCode": "PRD_LIST", "IconName": "box", "ModuleCode": "PRD"},
            {"MenuName": "BOM", "ScreenCode": "BOM_LIST", "IconName": "box", "ModuleCode": "BOM"},
            {"MenuName": "Production Orders", "ScreenCode": "MFG_ORD_LIST", "IconName": "factory", "ModuleCode": "MFG"},
            {"MenuName": "Tracking Board", "ScreenCode": "TRK_BOARD", "IconName": "box", "ModuleCode": "TRK"},
            {"MenuName": "Deliveries", "ScreenCode": "DLV_LIST", "IconName": "truck", "ModuleCode": "DLV"}
          ]
        },
      ));
    }

    if (path.contains('dashboard/data')) {
      return handler.resolve(Response(
        requestOptions: options,
        statusCode: 200,
        data: {
          'success': true,
          'data': {
            'kpis': {
              'total_revenue': 1250000.0,
              'revenue_growth': 14.2,
              'monthly_revenue': 250000.0,
              'sales_orders': 142,
              'active_orders_growth': 5.4,
              'active_quotations': 45,
              'quotations_growth': 2.1,
              'total_customers': 890,
              'customers_growth': 1.2,
              'production_orders': 24,
              'ready_for_delivery': 12,
              'delivered_orders': 156,
            },
            'charts': {
              'hierarchical_sales_trend': [
                {'category': 'Office Furniture', 'date': '2023-01-01', 'value': 45000},
                {'category': 'Home Living', 'date': '2023-01-01', 'value': 32000},
                {'category': 'Custom Projects', 'date': '2023-01-01', 'value': 25000},
              ],
            },
            'widgets': {
              'recent_orders': [
                {'order_number': 'ORD-2023-001', 'customer': 'Acme Corp', 'amount': 15000.0, 'status': 'Processing'},
                {'order_number': 'ORD-2023-002', 'customer': 'Global Tech', 'amount': 22500.0, 'status': 'Delivered'},
                {'order_number': 'ORD-2023-003', 'customer': 'Design Studio', 'amount': 8500.0, 'status': 'Pending'},
              ]
            }
          }
        },
      ));
    }
    
    // For any other path, just return empty success to prevent crashes.
    return handler.resolve(Response(
      requestOptions: options,
      statusCode: 200,
      data: {'data': []},
    ));
  }
}
