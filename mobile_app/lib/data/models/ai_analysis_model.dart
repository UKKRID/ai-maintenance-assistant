class AIAnalysisResponse {
  final String analysisId;
  final String? repairId;
  final String machineId;
  final String? inputText;
  final List<String>? inputImages;
  final double confidence;
  final List<CauseResponse> causes;
  final String summary;
  final String urgency;
  final String? additionalNotes;
  final String modelVersion;
  final int processingTime;
  final DateTime createdAt;

  AIAnalysisResponse({
    required this.analysisId,
    this.repairId,
    required this.machineId,
    this.inputText,
    this.inputImages,
    required this.confidence,
    required this.causes,
    required this.summary,
    required this.urgency,
    this.additionalNotes,
    required this.modelVersion,
    required this.processingTime,
    required this.createdAt,
  });

  factory AIAnalysisResponse.fromJson(Map<String, dynamic> json) {
    return AIAnalysisResponse(
      analysisId: json['analysis_id'] ?? '',
      repairId: json['repair_id'],
      machineId: json['machine_id'] ?? '',
      inputText: json['input_text'],
      inputImages: json['input_images'] != null
          ? List<String>.from(json['input_images'])
          : null,
      confidence: (json['confidence'] ?? 0).toDouble(),
      causes: (json['causes'] as List<dynamic>?)
              ?.map((c) => CauseResponse.fromJson(c))
              .toList() ??
          [],
      summary: json['summary'] ?? '',
      urgency: json['urgency'] ?? 'within_hour',
      additionalNotes: json['additional_notes'],
      modelVersion: json['model_version'] ?? '',
      processingTime: json['processing_time'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  String get urgencyLabel {
    switch (urgency) {
      case 'immediate':
        return 'ทันที';
      case 'within_hour':
        return 'ภายใน 1 ชั่วโมง';
      case 'within_day':
        return 'ภายในวันนี้';
      case 'can_wait':
        return 'รอได้';
      default:
        return urgency;
    }
  }
}

class CauseResponse {
  final String cause;
  final double confidence;
  final String description;
  final String severity;
  final SolutionResponse solution;
  final List<SparePartResponse> spareParts;
  final String prevention;

  CauseResponse({
    required this.cause,
    required this.confidence,
    required this.description,
    required this.severity,
    required this.solution,
    required this.spareParts,
    required this.prevention,
  });

  factory CauseResponse.fromJson(Map<String, dynamic> json) {
    return CauseResponse(
      cause: json['cause'] ?? '',
      confidence: (json['confidence'] ?? 0).toDouble(),
      description: json['description'] ?? '',
      severity: json['severity'] ?? 'medium',
      solution: SolutionResponse.fromJson(json['solution'] ?? {}),
      spareParts: (json['spare_parts'] as List<dynamic>?)
              ?.map((sp) => SparePartResponse.fromJson(sp))
              .toList() ??
          [],
      prevention: json['prevention'] ?? '',
    );
  }

  String get severityLabel {
    switch (severity) {
      case 'high':
        return 'High';
      case 'medium':
        return 'Medium';
      case 'low':
        return 'Low';
      default:
        return severity;
    }
  }
}

class SolutionResponse {
  final List<String> steps;
  final int estimatedTimeMinutes;
  final double estimatedCost;
  final String difficulty;

  SolutionResponse({
    required this.steps,
    required this.estimatedTimeMinutes,
    required this.estimatedCost,
    required this.difficulty,
  });

  factory SolutionResponse.fromJson(Map<String, dynamic> json) {
    return SolutionResponse(
      steps: List<String>.from(json['steps'] ?? []),
      estimatedTimeMinutes: json['estimated_time_minutes'] ?? 0,
      estimatedCost: (json['estimated_cost'] ?? 0).toDouble(),
      difficulty: json['difficulty'] ?? 'medium',
    );
  }

  String get estimatedTimeLabel {
    if (estimatedTimeMinutes < 60) {
      return '$estimatedTimeMinutes นาที';
    }
    final hours = estimatedTimeMinutes ~/ 60;
    final minutes = estimatedTimeMinutes % 60;
    if (minutes == 0) return '$hours ชั่วโมง';
    return '$hours ชม. $minutes นาที';
  }

  String get estimatedCostLabel {
    return '฿${estimatedCost.toStringAsFixed(0)}';
  }
}

class SparePartResponse {
  final String partName;
  final String partNumber;
  final int quantity;
  final double unitPrice;

  SparePartResponse({
    required this.partName,
    required this.partNumber,
    required this.quantity,
    required this.unitPrice,
  });

  factory SparePartResponse.fromJson(Map<String, dynamic> json) {
    return SparePartResponse(
      partName: json['part_name'] ?? '',
      partNumber: json['part_number'] ?? '',
      quantity: json['quantity'] ?? 1,
      unitPrice: (json['unit_price'] ?? 0).toDouble(),
    );
  }
}
