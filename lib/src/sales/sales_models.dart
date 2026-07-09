enum SalesLeadStatus {
  newly('new'),
  working('working'),
  qualified('qualified'),
  unqualified('unqualified'),
  converted('converted');

  const SalesLeadStatus(this.wire);
  final String wire;
}

class SalesSubmission {
  const SalesSubmission({
    required this.id,
    required this.contactEmail,
    this.formName,
    this.firstName,
    this.lastName,
    this.message,
    this.details,
    this.leadStatus,
    this.leadSource,
    this.company,
    this.companySize,
    this.companyWebsite,
    this.address,
    this.phone,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String contactEmail;
  final String? formName;
  final String? firstName;
  final String? lastName;
  final String? message;
  final String? details;
  final String? leadStatus;
  final String? leadSource;
  final String? company;
  final String? companySize;
  final String? companyWebsite;
  final String? address;
  final String? phone;
  final String? createdAt;
  final String? updatedAt;

  factory SalesSubmission.fromJson(Map<String, dynamic> json) {
    return SalesSubmission(
      id: json['id'] as String,
      contactEmail: json['contactEmail'] as String,
      formName: json['formName'] as String?,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      message: json['message'] as String?,
      details: json['details'] as String?,
      leadStatus: json['leadStatus'] as String?,
      leadSource: json['leadSource'] as String?,
      company: json['company'] as String?,
      companySize: json['companySize'] as String?,
      companyWebsite: json['companyWebsite'] as String?,
      address: json['address'] as String?,
      phone: json['phone'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }
}

class SalesComment {
  const SalesComment({
    required this.id,
    required this.body,
    this.authorDisplayName,
    this.authorEmail,
    this.createdAt,
  });

  final String id;
  final String body;
  final String? authorDisplayName;
  final String? authorEmail;
  final String? createdAt;

  factory SalesComment.fromJson(Map<String, dynamic> json) {
    return SalesComment(
      id: json['id'] as String,
      body: json['body'] as String,
      authorDisplayName: json['authorDisplayName'] as String?,
      authorEmail: json['authorEmail'] as String?,
      createdAt: json['createdAt'] as String?,
    );
  }
}

class CreateSalesSubmissionRequest {
  const CreateSalesSubmissionRequest({
    required this.contactEmail,
    required this.formName,
    required this.firstName,
    required this.lastName,
    this.message,
    this.details,
    this.leadStatus,
    this.leadSource,
    this.company,
    this.companySize,
    this.companyWebsite,
    this.address,
    this.phone,
  });

  final String contactEmail;
  final String formName;
  final String firstName;
  final String lastName;
  final String? message;
  final String? details;
  final SalesLeadStatus? leadStatus;
  final String? leadSource;
  final String? company;
  final String? companySize;
  final String? companyWebsite;
  final String? address;
  final String? phone;

  Map<String, dynamic> toJson() => {
        'contactEmail': contactEmail,
        'formName': formName,
        'firstName': firstName,
        'lastName': lastName,
        if (message != null) 'message': message,
        if (details != null) 'details': details,
        if (leadStatus != null) 'leadStatus': leadStatus!.wire,
        if (leadSource != null) 'leadSource': leadSource,
        if (company != null) 'company': company,
        if (companySize != null) 'companySize': companySize,
        if (companyWebsite != null) 'companyWebsite': companyWebsite,
        if (address != null) 'address': address,
        if (phone != null) 'phone': phone,
      };
}

class CreateSalesCommentRequest {
  const CreateSalesCommentRequest({
    required this.body,
    this.authorDisplayName,
    this.authorEmail,
  });

  final String body;
  final String? authorDisplayName;
  final String? authorEmail;

  Map<String, dynamic> toJson() => {
        'body': body,
        if (authorDisplayName != null) 'authorDisplayName': authorDisplayName,
        if (authorEmail != null) 'authorEmail': authorEmail,
      };
}
