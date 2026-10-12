import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:crm_panel/models/order_model.dart';
import 'package:crm_panel/repositories/orders_repository.dart';

void main() {
  late SupabaseClient supabaseClient;
  late OrdersRepository repository;
  late MockClient mockHttpClient;
  late List<http.Request> capturedRequests;
  late List<Map<String, dynamic>> responseRows;

  final mockOrder = <String, dynamic>{
    'id': 'order-1',
    'user_id': 'user-1',
    'customer_name': 'Test User',
    'customer_phone': '1234567890',
    'order_type': 'delivery',
    'status': 'pending',
    'total_amount': 50000.0,
    'estimated_ready_minutes': null,
    'admin_note': null,
    'completed_at': null,
    'created_at': '2023-10-01T10:00:00Z',
    'updated_at': '2023-10-01T10:00:00Z',
    'order_items': <Map<String, dynamic>>[],
  };

  setUp(() {
    capturedRequests = <http.Request>[];

    responseRows = <Map<String, dynamic>>[Map<String, dynamic>.from(mockOrder)];

    // Use a real SupabaseClient with mocked HTTP transport.
    // No real Supabase connection is required.
    mockHttpClient = MockClient((request) async {
      capturedRequests.add(request);

      if (request.url.path == '/rest/v1/orders_view' &&
          request.method == 'GET') {
        return http.Response(
          jsonEncode(responseRows),
          200,
          headers: const <String, String>{
            'content-type': 'application/json; charset=utf-8',
          },
          request: request,
        );
      }

      if (request.url.path == '/rest/v1/orders' && request.method == 'PATCH') {
        return http.Response('', 204, request: request);
      }

      return http.Response(
        jsonEncode(<String, dynamic>{
          'message': 'Unexpected request in OrdersRepository test',
          'method': request.method,
          'path': request.url.path,
        }),
        404,
        headers: const <String, String>{
          'content-type': 'application/json; charset=utf-8',
        },
        request: request,
      );
    });

    supabaseClient = SupabaseClient(
      'http://localhost:54321',
      'test-anon-key',
      httpClient: mockHttpClient,
      // Prevent the tests from requiring a real authentication session.
      accessToken: () async => 'test-access-token',
    );

    repository = OrdersRepository(client: supabaseClient);

    addTearDown(() async {
      await supabaseClient.dispose();
      mockHttpClient.close();
    });
  });

  group('OrdersRepository', () {
    test('getOrders fetches orders_view and maps rows to OrderModel', () async {
      final result = await repository.getOrders(page: 1, pageSize: 20);

      expect(result, isA<List<OrderModel>>());
      expect(result, hasLength(1));
      expect(result.first.id, 'order-1');
      expect(result.first.customerName, 'Test User');

      expect(capturedRequests, hasLength(1));
      expect(capturedRequests.single.method, 'GET');
      expect(capturedRequests.single.url.path, '/rest/v1/orders_view');
      expect(
        capturedRequests.single.url.queryParameters['order'],
        startsWith('created_at.desc'),
      );

      // Verify pagination.
      expect(capturedRequests.single.url.queryParameters['offset'], '0');
      expect(capturedRequests.single.url.queryParameters['limit'], '20');
    });

    test('getOrders adds an OR filter when searchQuery is provided', () async {
      await repository.getOrders(searchQuery: 'Test');

      expect(capturedRequests, hasLength(1));

      final orFilter = capturedRequests.single.url.queryParameters['or'];

      expect(orFilter, isNotNull);
      expect(orFilter, contains('id.ilike.%Test%'));
      expect(orFilter, contains('customer_name.ilike.%Test%'));
      expect(orFilter, contains('customer_phone.ilike.%Test%'));
    });

    test('getOrders applies the status filter', () async {
      await repository.getOrders(status: 'pending');

      expect(capturedRequests, hasLength(1));

      expect(
        capturedRequests.single.url.queryParameters['status'],
        'eq.pending',
      );
    });

    test(
      'getOrders returns an empty list when the response has no rows',
      () async {
        responseRows = <Map<String, dynamic>>[];

        final result = await repository.getOrders();

        expect(result, isEmpty);
        expect(capturedRequests, hasLength(1));
      },
    );

    test(
      'updateOrderStatus sends a PATCH request to the orders table',
      () async {
        await repository.updateOrderStatus('order-1', 'completed');

        expect(capturedRequests, hasLength(1));

        final request = capturedRequests.single;

        expect(request.method, 'PATCH');
        expect(request.url.path, '/rest/v1/orders');

        expect(request.url.queryParameters['id'], 'eq.order-1');

        final body = jsonDecode(request.body) as Map<String, dynamic>;

        expect(body['status'], 'completed');
        expect(body['updated_at'], isA<String>());
        expect(DateTime.tryParse(body['updated_at'] as String), isNotNull);
      },
    );

    test('getOrders rejects an invalid page number', () async {
      await expectLater(
        repository.getOrders(page: 0),
        throwsA(isA<ArgumentError>()),
      );

      expect(capturedRequests, isEmpty);
    });

    test('getOrders rejects an invalid page size', () async {
      await expectLater(
        repository.getOrders(pageSize: 0),
        throwsA(isA<ArgumentError>()),
      );

      expect(capturedRequests, isEmpty);
    });
  });
}
