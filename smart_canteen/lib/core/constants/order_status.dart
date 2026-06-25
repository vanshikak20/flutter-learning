class OrderStatus {
  static const String pending = 'pending';
  static const String preparing = 'preparing';
  static const String ready = 'ready';
  static const String completed = 'completed';

  static const List<String> all = [
    pending,
    preparing,
    ready,
    completed,
  ];

  // returns the next logical status
  static String? getNextStatus(String current) {
    switch (current) {
      case pending:
        return preparing;
      case preparing:
        return ready;
      case ready:
        return completed;
      default:
        return null;
    }
  }

  // human readable label
  static String getLabel(String status) {
    switch (status) {
      case pending:
        return 'Pending';
      case preparing:
        return 'Preparing';
      case ready:
        return 'Ready';
      case completed:
        return 'Completed';
      default:
        return 'Unknown';
    }
  }

  // color for each status
  static int getColor(String status) {
    switch (status) {
      case pending:
        return 0xFFFF9800;    // orange
      case preparing:
        return 0xFF2196F3;    // blue
      case ready:
        return 0xFF4CAF50;    // green
      case completed:
        return 0xFF9E9E9E;    // grey
      default:
        return 0xFF9E9E9E;
    }
  }
}