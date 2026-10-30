class DailyChecklistResponseModel {
  final bool success;
  final int totalDone;
  final int totalCount;
  final List<DayChecklistGroup> groups;

  DailyChecklistResponseModel({
    required this.success,
    required this.totalDone,
    required this.totalCount,
    required this.groups,
  });

  factory DailyChecklistResponseModel.fromJson(Map<String, dynamic> json) {
    final progress = json['progress'] as Map<String, dynamic>? ?? {};
    final list = (json['data'] as List? ?? [])
        .map((e) => DayChecklistGroup.fromJson(e))
        .toList();

    return DailyChecklistResponseModel(
      success: json['success'] == true,
      totalDone: progress['done'] ?? 0,
      totalCount: progress['total'] ?? 0,
      groups: list,
    );
  }
}

class DayChecklistGroup {
  final String date;
  final String label;
  final int done;
  final int total;
  final List<ChecklistItemModel> items;

  DayChecklistGroup({
    required this.date,
    required this.label,
    required this.done,
    required this.total,
    required this.items,
  });

  factory DayChecklistGroup.fromJson(Map<String, dynamic> json) {
    return DayChecklistGroup(
      date: json['date']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      done: int.tryParse(json['done']?.toString() ?? '0') ?? 0,
      total: int.tryParse(json['total']?.toString() ?? '0') ?? 0,
      items: (json['items'] as List? ?? [])
          .map((e) => ChecklistItemModel.fromJson(e))
          .toList(),
    );
  }
}

class ChecklistItemModel {
  final int checklistId;
  final String type;
  final String title;
  final String? details;
  bool isChecked;
  final String? checkedAt;

  ChecklistItemModel({
    required this.checklistId,
    required this.type,
    required this.title,
    this.details,
    required this.isChecked,
    this.checkedAt,
  });

  factory ChecklistItemModel.fromJson(Map<String, dynamic> json) {
    return ChecklistItemModel(
      checklistId: int.tryParse(json['checklist_id']?.toString() ?? '0') ?? 0,
      type: json['type']?.toString() ?? 'itinerary',
      title: json['title']?.toString() ?? '',
      details: json['details']?.toString(),
      isChecked: json['is_checked'] == true || json['is_checked'] == 1,
      checkedAt: json['checked_at']?.toString(),
    );
  }
}
