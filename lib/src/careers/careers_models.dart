import '../core/json_value.dart';

class CareerPosting {
  const CareerPosting({
    required this.requisitionNodeId,
    this.title,
    this.location,
    this.department,
    this.employmentType,
    this.description,
    this.publishedAt,
    this.updatedAt,
    this.isOpen,
  });

  final String requisitionNodeId;
  final String? title;
  final String? location;
  final String? department;
  final String? employmentType;
  final String? description;
  final String? publishedAt;
  final String? updatedAt;
  final bool? isOpen;

  factory CareerPosting.fromJson(Map<String, dynamic> json) {
    return CareerPosting(
      requisitionNodeId: json['requisitionNodeId'] as String,
      title: json['title'] as String?,
      location: json['location'] as String?,
      department: json['department'] as String?,
      employmentType: json['employmentType'] as String?,
      description: json['description'] as String?,
      publishedAt: json['publishedAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      isOpen: json['isOpen'] as bool?,
    );
  }
}

class CareerApplicationTemplate {
  const CareerApplicationTemplate({
    required this.templateVersion,
    required this.sections,
  });

  final String templateVersion;
  final List<CareerTemplateSection> sections;

  factory CareerApplicationTemplate.fromJson(Map<String, dynamic> json) {
    return CareerApplicationTemplate(
      templateVersion: json['templateVersion'] as String,
      sections: (json['sections'] as List<dynamic>? ?? const [])
          .map(
            (e) => CareerTemplateSection.fromJson(
              Map<String, dynamic>.from(e as Map),
            ),
          )
          .toList(growable: false),
    );
  }
}

class CareerTemplateSection {
  const CareerTemplateSection({
    required this.id,
    required this.fields,
    this.title,
    this.description,
  });

  final String id;
  final String? title;
  final String? description;
  final List<CareerTemplateField> fields;

  factory CareerTemplateSection.fromJson(Map<String, dynamic> json) {
    return CareerTemplateSection(
      id: json['id'] as String,
      title: json['title'] as String?,
      description: json['description'] as String?,
      fields: (json['fields'] as List<dynamic>? ?? const [])
          .map(
            (e) =>
                CareerTemplateField.fromJson(Map<String, dynamic>.from(e as Map)),
          )
          .toList(growable: false),
    );
  }
}

class CareerTemplateField {
  const CareerTemplateField({
    required this.id,
    required this.type,
    this.label,
    this.required,
    this.options,
    this.helpText,
  });

  final String id;
  final String type;
  final String? label;
  final bool? required;
  final List<String>? options;
  final String? helpText;

  factory CareerTemplateField.fromJson(Map<String, dynamic> json) {
    return CareerTemplateField(
      id: json['id'] as String,
      type: json['type'] as String,
      label: json['label'] as String?,
      required: json['required'] as bool?,
      options: (json['options'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(growable: false),
      helpText: json['helpText'] as String?,
    );
  }
}

class CareerApplication {
  const CareerApplication({
    required this.id,
    this.requisitionNodeId,
    this.applicantEmail,
    this.contactEmail,
    this.templateVersion,
    this.status,
    this.answers,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String? requisitionNodeId;
  final String? applicantEmail;
  final String? contactEmail;
  final String? templateVersion;
  final String? status;
  final Map<String, JsonValue>? answers;
  final String? createdAt;
  final String? updatedAt;

  factory CareerApplication.fromJson(Map<String, dynamic> json) {
    return CareerApplication(
      id: json['id'] as String,
      requisitionNodeId: json['requisitionNodeId'] as String?,
      applicantEmail: json['applicantEmail'] as String?,
      contactEmail: json['contactEmail'] as String?,
      templateVersion: json['templateVersion'] as String?,
      status: json['status'] as String?,
      answers: jsonValueMapFromJson(json['answers']),
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }
}

class SubmitCareerApplicationRequest {
  const SubmitCareerApplicationRequest({
    required this.requisitionNodeId,
    required this.templateVersion,
    required this.applicantEmail,
    required this.answers,
  });

  final String requisitionNodeId;
  final String templateVersion;
  final String applicantEmail;
  final Map<String, JsonValue> answers;

  Map<String, dynamic> toJson() => {
        'requisitionNodeId': requisitionNodeId,
        'templateVersion': templateVersion,
        'applicantEmail': applicantEmail,
        'answers': jsonValueMapToJson(answers),
      };
}
