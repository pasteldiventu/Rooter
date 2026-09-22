class Area {
  const Area({
    required this.id,
    required this.name,
    required this.number,
    this.assistantGovernor,
  });

  final String id;
  final String name;
  final int number;
  final String? assistantGovernor;

  factory Area.fromJson(Map<String, dynamic> json) {
    return Area(
      id: json['id'] as String,
      name: json['name'] as String,
      number: json['number'] as int,
      assistantGovernor: json['assistant_governor'] as String?,
    );
  }
}

class ClubSummary {
  const ClubSummary({
    required this.id,
    required this.areaId,
    required this.name,
  });

  final String id;
  final String areaId;
  final String name;

  factory ClubSummary.fromJson(Map<String, dynamic> json) {
    return ClubSummary(
      id: json['id'] as String,
      areaId: json['area_id'] as String,
      name: json['name'] as String,
    );
  }
}

class ClubDetail {
  const ClubDetail({
    required this.id,
    required this.areaId,
    required this.name,
    this.presidentName,
    this.presidentPhone,
    this.presidentEmail,
    this.address,
    this.latitude,
    this.longitude,
    this.meetingSchedule,
  });

  final String id;
  final String areaId;
  final String name;
  final String? presidentName;
  final String? presidentPhone;
  final String? presidentEmail;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? meetingSchedule;

  bool get hasLocation =>
      (address != null && address!.trim().isNotEmpty) ||
      (latitude != null && longitude != null);

  bool get hasMeeting =>
      meetingSchedule != null && meetingSchedule!.trim().isNotEmpty;

  factory ClubDetail.fromJson(Map<String, dynamic> json) {
    return ClubDetail(
      id: json['id'] as String,
      areaId: json['area_id'] as String,
      name: json['name'] as String,
      presidentName: json['president_name'] as String?,
      presidentPhone: json['president_phone'] as String?,
      presidentEmail: json['president_email'] as String?,
      address: json['address'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      meetingSchedule: json['meeting_schedule'] as String?,
    );
  }
}
