enum ReminderType { recipe, shopping, ingredient }
enum ReminderOffset { sameDay, previousDay }
enum ReminderStatus { pending, completed, cancelled }
enum ReminderRecurrence { once, daily, weekly, monthly }

class ReminderSeries {
  const ReminderSeries({
    required this.id,
    required this.sourceType,
    required this.sourceId,
    required this.title,
    required this.description,
    required this.startDate,
    required this.recurrence,
    required this.offset,
    required this.hour,
    required this.minute,
    required this.isEnabled,
    required this.createdAt,
    this.weekday,
    this.monthDay,
    this.endDate,
    this.excludedDates = const {},
  })  : assert(hour >= 0 && hour <= 23),
        assert(minute >= 0 && minute <= 59),
        assert(weekday == null || (weekday >= 1 && weekday <= 7)),
        assert(monthDay == null || (monthDay >= 1 && monthDay <= 31));

  final String id;
  final ReminderType sourceType;
  final String sourceId;
  final String title;
  final String description;
  final DateTime startDate;
  final ReminderRecurrence recurrence;
  final ReminderOffset offset;
  final int hour;
  final int minute;
  final bool isEnabled;
  final DateTime createdAt;
  final int? weekday;
  final int? monthDay;
  final DateTime? endDate;
  final Set<String> excludedDates;

  Map<String, Object?> toJson() => {
    'id': id,
    'source_type': sourceType.name,
    'source_id': sourceId,
    'title': title,
    'description': description,
    'start_date': startDate.toIso8601String(),
    'recurrence': recurrence.name,
    'offset': offset.name,
    'hour': hour,
    'minute': minute,
    'is_enabled': isEnabled,
    'created_at': createdAt.toIso8601String(),
    'weekday': weekday,
    'month_day': monthDay,
    'end_date': endDate?.toIso8601String(),
    'excluded_dates': excludedDates.toList()..sort(),
  };

  factory ReminderSeries.fromJson(Map<String, dynamic> json) {
    T enumValue<T extends Enum>(List<T> values, Object? raw, T fallback) =>
        values.firstWhere((value) => value.name == raw, orElse: () => fallback);
    final start = DateTime.parse(json['start_date'] as String);
    return ReminderSeries(
      id: json['id'] as String,
      sourceType: enumValue(ReminderType.values, json['source_type'], ReminderType.recipe),
      sourceId: json['source_id'] as String,
      title: json['title'] as String? ?? 'Reminder',
      description: json['description'] as String? ?? '',
      startDate: DateTime(start.year, start.month, start.day),
      recurrence: enumValue(ReminderRecurrence.values, json['recurrence'], ReminderRecurrence.once),
      offset: enumValue(ReminderOffset.values, json['offset'], ReminderOffset.sameDay),
      hour: (json['hour'] as num?)?.toInt() ?? 9,
      minute: (json['minute'] as num?)?.toInt() ?? 0,
      isEnabled: json['is_enabled'] != false,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      weekday: (json['weekday'] as num?)?.toInt(),
      monthDay: (json['month_day'] as num?)?.toInt(),
      endDate: DateTime.tryParse(json['end_date'] as String? ?? ''),
      excludedDates: (json['excluded_dates'] as List?)?.whereType<String>().toSet() ?? const {},
    );
  }

  ReminderSeries copyWith({
    String? title,
    String? description,
    ReminderOffset? offset,
    int? hour,
    int? minute,
    bool? isEnabled,
    Set<String>? excludedDates,
  }) => ReminderSeries(
    id: id,
    sourceType: sourceType,
    sourceId: sourceId,
    title: title ?? this.title,
    description: description ?? this.description,
    startDate: startDate,
    recurrence: recurrence,
    offset: offset ?? this.offset,
    hour: hour ?? this.hour,
    minute: minute ?? this.minute,
    isEnabled: isEnabled ?? this.isEnabled,
    createdAt: createdAt,
    weekday: weekday,
    monthDay: monthDay,
    endDate: endDate,
    excludedDates: excludedDates ?? this.excludedDates,
  );

  List<ReminderOccurrence> generateOccurrences({
    required DateTime from,
    required DateTime through,
  }) {
    if (!isEnabled) return const [];
    final first = DateTime(from.year, from.month, from.day);
    final requestedLast = DateTime(through.year, through.month, through.day);
    final seriesEnd = endDate == null ? requestedLast : DateTime(endDate!.year, endDate!.month, endDate!.day);
    final last = seriesEnd.isBefore(requestedLast) ? seriesEnd : requestedLast;
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    if (last.isBefore(first) || last.isBefore(start)) return const [];
    final dates = <DateTime>[];
    if (recurrence == ReminderRecurrence.once) {
      if (!start.isBefore(first) && !start.isAfter(last)) dates.add(start);
    } else {
      for (var date = start.isBefore(first) ? first : start;
          !date.isAfter(last);
          date = date.add(const Duration(days: 1))) {
        final matches = switch (recurrence) {
          ReminderRecurrence.once => false,
          ReminderRecurrence.daily => true,
          ReminderRecurrence.weekly => date.weekday == (weekday ?? start.weekday),
          ReminderRecurrence.monthly => date.day == (monthDay ?? start.day),
        };
        final dateKey = '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        if (matches && !excludedDates.contains(dateKey)) dates.add(date);
      }
    }

    return [
      for (final date in dates)
        ReminderOccurrence(
          id: '$id:${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
          seriesId: id,
          sourceType: sourceType,
          sourceId: sourceId,
          title: title,
          description: description,
          scheduledDate: date,
          notificationDate: DateTime(
            date.year,
            date.month,
            date.day - (offset == ReminderOffset.previousDay ? 1 : 0),
            hour,
            minute,
          ),
          status: ReminderStatus.pending,
          notificationId: _stableNotificationId('$id:${date.toIso8601String()}'),
        ),
    ];
  }
}

class ReminderOccurrence {
  const ReminderOccurrence({
    required this.id,
    required this.seriesId,
    required this.sourceType,
    required this.sourceId,
    required this.title,
    required this.description,
    required this.scheduledDate,
    required this.notificationDate,
    required this.status,
    required this.notificationId,
    this.completedAt,
  });

  final String id;
  final String seriesId;
  final ReminderType sourceType;
  final String sourceId;
  final String title;
  final String description;
  final DateTime scheduledDate;
  final DateTime notificationDate;
  final ReminderStatus status;
  final int notificationId;
  final DateTime? completedAt;

  Map<String, Object?> toJson() => {
    'id': id,
    'series_id': seriesId,
    'source_type': sourceType.name,
    'source_id': sourceId,
    'title': title,
    'description': description,
    'scheduled_date': scheduledDate.toIso8601String(),
    'notification_date': notificationDate.toIso8601String(),
    'status': status.name,
    'notification_id': notificationId,
    'completed_at': completedAt?.toIso8601String(),
  };

  factory ReminderOccurrence.fromJson(Map<String, dynamic> json) {
    T enumValue<T extends Enum>(List<T> values, Object? raw, T fallback) =>
        values.firstWhere((value) => value.name == raw, orElse: () => fallback);
    return ReminderOccurrence(
      id: json['id'] as String,
      seriesId: json['series_id'] as String,
      sourceType: enumValue(ReminderType.values, json['source_type'], ReminderType.recipe),
      sourceId: json['source_id'] as String,
      title: json['title'] as String? ?? 'Reminder',
      description: json['description'] as String? ?? '',
      scheduledDate: DateTime.parse(json['scheduled_date'] as String),
      notificationDate: DateTime.parse(json['notification_date'] as String),
      status: enumValue(ReminderStatus.values, json['status'], ReminderStatus.pending),
      notificationId: (json['notification_id'] as num).toInt(),
      completedAt: DateTime.tryParse(json['completed_at'] as String? ?? ''),
    );
  }

  ReminderOccurrence copyWith({ReminderStatus? status, DateTime? completedAt}) =>
      ReminderOccurrence(
        id: id,
        seriesId: seriesId,
        sourceType: sourceType,
        sourceId: sourceId,
        title: title,
        description: description,
        scheduledDate: scheduledDate,
        notificationDate: notificationDate,
        status: status ?? this.status,
        notificationId: notificationId,
        completedAt: completedAt ?? this.completedAt,
      );
}

int _stableNotificationId(String value) {
  var hash = 0x811c9dc5;
  for (final unit in value.codeUnits) {
    hash ^= unit;
    hash = (hash * 0x01000193) & 0x7fffffff;
  }
  return hash == 0 ? 1 : hash;
}
