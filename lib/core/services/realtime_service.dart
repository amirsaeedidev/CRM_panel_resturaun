import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';
import 'logger_service.dart';

class RealtimeService {
  RealtimeService._();

  /// Subscribes to changes (INSERT, UPDATE, DELETE) on a specific table.
  static RealtimeChannel subscribeToTable({
    required String table,
    String schema = 'public',
    required void Function(PostgresChangePayload payload) onInsert,
    required void Function(PostgresChangePayload payload) onUpdate,
    required void Function(PostgresChangePayload payload) onDelete,
  }) {
    LoggerService.info('Subscribing to realtime changes for table: $table');

    final channel = SupabaseService.client
        .channel('public:$table')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: schema,
          table: table,
          callback: (payload) {
            LoggerService.debug('Realtime INSERT on $table: ${payload.newRecord}');
            onInsert(payload);
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: schema,
          table: table,
          callback: (payload) {
            LoggerService.debug('Realtime UPDATE on $table: ${payload.newRecord}');
            onUpdate(payload);
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.delete,
          schema: schema,
          table: table,
          callback: (payload) {
            LoggerService.debug('Realtime DELETE on $table: ${payload.oldRecord}');
            onDelete(payload);
          },
        )
        .subscribe();

    return channel;
  }

  /// Unsubscribes from a specific realtime channel.
  static void unsubscribe(RealtimeChannel channel) {
    SupabaseService.client.removeChannel(channel);
    // Changed from channel.name to channel.topic for supabase_flutter v2
    LoggerService.info('Unsubscribed from channel: ${channel.topic}');
  }
}