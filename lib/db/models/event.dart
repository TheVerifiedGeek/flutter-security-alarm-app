class Event {
  int? id;
  int branchId;
  String type;
  DateTime timestamp;
  String status;
  String? notes;

  Event({
    this.id,
    required this.branchId,
    required this.type,
    required this.timestamp,
    required this.status,
    this.notes,
  });

  // Convert a Dog into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'branch_id': branchId,
      'type': type,
      'timestamp': timestamp.toIso8601String(),
      'status': status,
      'notes': notes,
    };
  }

  // Implement toString to make it easier to see information about
  // each dog when using the print statement.
  @override
  String toString() {
    return 'Event{id: $id, branchId: $branchId, type: $type, timestamp: $timestamp, status: $status, notes: $notes}';
  }

  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'],
      branchId: map['branch_id'],
      type: map['type'],
      timestamp: DateTime.parse(map['timestamp']),
      status: map['status'],
      notes: map['notes'],
    );
  }
}
