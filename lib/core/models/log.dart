class AppUser {
  final int? id;
  final String username;
  final String passwordHash; // store salted hash
  final String role; // admin, operator

  const AppUser({this.id, required this.username, required this.passwordHash, required this.role});

  Map<String, dynamic> toMap() => {
    'id': id,
    'username': username,
    'passwordHash': passwordHash,
    'role': role,
  };

  factory AppUser.fromMap(Map<String, dynamic> m) => AppUser(
    id: m['id'] as int?,
    username: m['username'] as String,
    passwordHash: m['passwordHash'] as String,
    role: m['role'] as String,
  );
}
enum LogType { system, strongRoom, police, gsm, alarm, tamper }

class LogEntry {
  final int? id;
  final String branch; // e.g., "OLLIN SACCO KIANYAGA"
  final LogType type;
  final String status; // armed, disarmed, intruder, ack, ok, trouble, late
  final String rawMessage;
  final DateTime timestamp;
  final String compliance; // OK, Late, Trouble, GSM Tested OK @ HH:mm, GSM Not Tested Today

  const LogEntry({
    this.id,
    required this.branch,
    required this.type,
    required this.status,
    required this.rawMessage,
    required this.timestamp,
    required this.compliance,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'branch': branch,
    'type': type.name,
    'status': status,
    'raw_message': rawMessage,
    'timestamp': timestamp.toIso8601String(),
    'compliance': compliance,
  };

  factory LogEntry.fromMap(Map<String, dynamic> m) => LogEntry(
    id: m['id'] as int?,
    branch: m['branch'] as String,
    type: LogType.values.firstWhere((e) => e.name == m['type'] as String),
    status: m['status'] as String,
    rawMessage: m['raw_message'] as String,
    timestamp: DateTime.parse(m['timestamp'] as String),
    compliance: m['compliance'] as String,
  );
}
