class AIAnalysis {
  final String analysisId;
  final String machineId;
  final String? inputText;
  final List<String>? inputImages;
  final double confidence;
  final List<Cause> causes;
  final String summary;
  final String urgency;
  final String? additionalNotes;
  final String modelVersion;
  final int processingTime;
  final DateTime createdAt;

  AIAnalysis({
    required this.analysisId,
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

  factory AIAnalysis.fromJson(Map<String, dynamic> json) {
    return AIAnalysis(
      analysisId: json['analysis_id'] ?? '',
      machineId: json['machine_id'] ?? '',
      inputText: json['input_text'],
      inputImages: json['input_images'] != null
          ? List<String>.from(json['input_images'])
          : null,
      confidence: (json['confidence'] ?? 0).toDouble(),
      causes: (json['causes'] as List<dynamic>?)
              ?.map((c) => Cause.fromJson(c))
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

  Map<String, dynamic> toJson() {
    return {
      'analysis_id': analysisId,
      'machine_id': machineId,
      'input_text': inputText,
      'input_images': inputImages,
      'confidence': confidence,
      'causes': causes.map((c) => c.toJson()).toList(),
      'summary': summary,
      'urgency': urgency,
      'additional_notes': additionalNotes,
      'model_version': modelVersion,
      'processing_time': processingTime,
      'created_at': createdAt.toIso8601String(),
    };
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

class Cause {
  final String cause;
  final double confidence;
  final String description;
  final String severity;
  final Solution solution;
  final List<SparePart> spareParts;
  final String prevention;

  Cause({
    required this.cause,
    required this.confidence,
    required this.description,
    required this.severity,
    required this.solution,
    required this.spareParts,
    required this.prevention,
  });

  factory Cause.fromJson(Map<String, dynamic> json) {
    return Cause(
      cause: json['cause'] ?? '',
      confidence: (json['confidence'] ?? 0).toDouble(),
      description: json['description'] ?? '',
      severity: json['severity'] ?? 'medium',
      solution: Solution.fromJson(json['solution'] ?? {}),
      spareParts: (json['spare_parts'] as List<dynamic>?)
              ?.map((sp) => SparePart.fromJson(sp))
              .toList() ??
          [],
      prevention: json['prevention'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cause': cause,
      'confidence': confidence,
      'description': description,
      'severity': severity,
      'solution': solution.toJson(),
      'spare_parts': spareParts.map((sp) => sp.toJson()).toList(),
      'prevention': prevention,
    };
  }

  String get severityLabel {
    switch (severity) {
      case 'high':
        return 'สูง';
      case 'medium':
        return 'ปานกลาง';
      case 'low':
        return 'ต่ำ';
      default:
        return severity;
    }
  }
}

class Solution {
  final List<String> steps;
  final int estimatedTimeMinutes;
  final double estimatedCost;
  final String difficulty;

  Solution({
    required this.steps,
    required this.estimatedTimeMinutes,
    required this.estimatedCost,
    required this.difficulty,
  });

  factory Solution.fromJson(Map<String, dynamic> json) {
    return Solution(
      steps: List<String>.from(json['steps'] ?? []),
      estimatedTimeMinutes: json['estimated_time_minutes'] ?? 0,
      estimatedCost: (json['estimated_cost'] ?? 0).toDouble(),
      difficulty: json['difficulty'] ?? 'medium',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'steps': steps,
      'estimated_time_minutes': estimatedTimeMinutes,
      'estimated_cost': estimatedCost,
      'difficulty': difficulty,
    };
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

  String get difficultyLabel {
    switch (difficulty) {
      case 'easy':
        return 'ง่าย';
      case 'medium':
        return 'ปานกลาง';
      case 'hard':
        return 'ยาก';
      default:
        return difficulty;
    }
  }
}

class SparePart {
  final String partName;
  final String partNumber;
  final int quantity;
  final double unitPrice;

  SparePart({
    required this.partName,
    required this.partNumber,
    required this.quantity,
    required this.unitPrice,
  });

  factory SparePart.fromJson(Map<String, dynamic> json) {
    return SparePart(
      partName: json['part_name'] ?? '',
      partNumber: json['part_number'] ?? '',
      quantity: json['quantity'] ?? 1,
      unitPrice: (json['unit_price'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'part_name': partName,
      'part_number': partNumber,
      'quantity': quantity,
      'unit_price': unitPrice,
    };
  }

  double get totalPrice => quantity * unitPrice;

  String get totalPriceLabel {
    return '฿${totalPrice.toStringAsFixed(0)}';
  }
}
