class Report {
  final int? id;
  final int branchId;
  final String dateRange;
  final String filePath;

  Report({
    this.id,
    required this.branchId,
    required this.dateRange,
    required this.filePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'branch_id': branchId,
      'date_range': dateRange,
      'file_path': filePath,
    };
  }

  factory Report.fromMap(Map<String, dynamic> map) {
    return Report(id: map['id'], branchId: map['branch_id'], dateRange: map['date_range'], filePath: map['file_path']);
  }
}

