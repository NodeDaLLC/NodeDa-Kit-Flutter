enum SupportPriority {
  low('low'),
  medium('medium'),
  high('high'),
  urgent('urgent');

  const SupportPriority(this.wire);
  final String wire;
}

enum SupportCategory {
  billing('billing'),
  technical('technical'),
  account('account'),
  featureRequest('feature_request'),
  general('general'),
  other('other');

  const SupportCategory(this.wire);
  final String wire;
}

class SupportTicket {
  const SupportTicket({
    required this.id,
    required this.contactEmail,
    required this.subject,
    this.applicationName,
    this.body,
    this.priority,
    this.category,
    this.status,
    this.channel,
    this.environment,
    this.deviceInfo,
    this.relatedUrl,
    this.requesterName,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String contactEmail;
  final String? applicationName;
  final String subject;
  final String? body;
  final String? priority;
  final String? category;
  final String? status;
  final String? channel;
  final String? environment;
  final String? deviceInfo;
  final String? relatedUrl;
  final String? requesterName;
  final String? createdAt;
  final String? updatedAt;

  factory SupportTicket.fromJson(Map<String, dynamic> json) {
    return SupportTicket(
      id: json['id'] as String,
      contactEmail: json['contactEmail'] as String,
      applicationName: json['applicationName'] as String?,
      subject: json['subject'] as String,
      body: json['body'] as String?,
      priority: json['priority'] as String?,
      category: json['category'] as String?,
      status: json['status'] as String?,
      channel: json['channel'] as String?,
      environment: json['environment'] as String?,
      deviceInfo: json['deviceInfo'] as String?,
      relatedUrl: json['relatedUrl'] as String?,
      requesterName: json['requesterName'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }
}

class SupportComment {
  const SupportComment({
    required this.id,
    required this.body,
    this.ticketId,
    this.authorDisplayName,
    this.authorEmail,
    this.isInternal,
    this.createdAt,
  });

  final String id;
  final String? ticketId;
  final String body;
  final String? authorDisplayName;
  final String? authorEmail;
  final bool? isInternal;
  final String? createdAt;

  factory SupportComment.fromJson(Map<String, dynamic> json) {
    return SupportComment(
      id: json['id'] as String,
      ticketId: json['ticketId'] as String?,
      body: json['body'] as String,
      authorDisplayName: json['authorDisplayName'] as String?,
      authorEmail: json['authorEmail'] as String?,
      isInternal: json['isInternal'] as bool?,
      createdAt: json['createdAt'] as String?,
    );
  }
}

class CreateSupportTicketRequest {
  const CreateSupportTicketRequest({
    required this.contactEmail,
    required this.applicationName,
    required this.subject,
    required this.body,
    this.priority,
    this.category,
    this.channel,
    this.environment,
    this.deviceInfo,
    this.relatedUrl,
    this.requesterName,
  });

  final String contactEmail;
  final String applicationName;
  final String subject;
  final String body;
  final SupportPriority? priority;
  final SupportCategory? category;
  final String? channel;
  final String? environment;
  final String? deviceInfo;
  final String? relatedUrl;
  final String? requesterName;

  Map<String, dynamic> toJson() => {
        'contactEmail': contactEmail,
        'applicationName': applicationName,
        'subject': subject,
        'body': body,
        if (priority != null) 'priority': priority!.wire,
        if (category != null) 'category': category!.wire,
        if (channel != null) 'channel': channel,
        if (environment != null) 'environment': environment,
        if (deviceInfo != null) 'deviceInfo': deviceInfo,
        if (relatedUrl != null) 'relatedUrl': relatedUrl,
        if (requesterName != null) 'requesterName': requesterName,
      };
}

class CreateSupportCommentRequest {
  const CreateSupportCommentRequest({
    required this.body,
    this.authorDisplayName,
    this.authorEmail,
    this.isInternal,
  });

  final String body;
  final String? authorDisplayName;
  final String? authorEmail;
  final bool? isInternal;

  Map<String, dynamic> toJson() => {
        'body': body,
        if (authorDisplayName != null) 'authorDisplayName': authorDisplayName,
        if (authorEmail != null) 'authorEmail': authorEmail,
        if (isInternal != null) 'isInternal': isInternal,
      };
}
