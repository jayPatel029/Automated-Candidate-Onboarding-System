import 'dart:convert';

// class User {
//   String? id;
//   String? name;
//   Address? permanentAddress;
//   Address? currentAddress;
//   String? dateOfBirth;
//   String? age;
//   String? gender;
//   String? passport;
//   String? mobile;
//   String? panNo;
//   String? visa;
//   String? emailId;
//   String? emergencyContactName;
//   String? emergencyContactNumber;
//   String? availableForRelocation;
//   List<EducationalQualification>? educationalQualifications;
//   List<TrainingDetail>? trainingDetails;
//   List<TechnicalCertification>? technicalCertifications;
//   List<FamilyDetail>? familyDetails;
//   List<Reference>? references;
//
//   User({
//     this.id,
//     this.name,
//     this.permanentAddress,
//     this.currentAddress,
//     this.dateOfBirth,
//     this.age,
//     this.gender,
//     this.passport,
//     this.mobile,
//     this.panNo,
//     this.visa,
//     this.emailId,
//     this.emergencyContactName,
//     this.emergencyContactNumber,
//     this.availableForRelocation,
//     this.educationalQualifications,
//     this.trainingDetails,
//     this.technicalCertifications,
//     this.familyDetails,
//     this.references,
//   });
//
//   factory User.fromJson(Map<String, dynamic> json) {
//     return User(
//       id: json['_id']?['\$oid'],
//       name: json['Name'],
//       permanentAddress: json['Permanent Address'] != null
//           ? Address.fromJson(json['Permanent Address'])
//           : null,
//       currentAddress: json['Current Address'] != null
//           ? Address.fromJson(json['Current Address'])
//           : null,
//       dateOfBirth: json['Date of Birth'],
//       age: json['Age'],
//       gender: json['Gender'],
//       passport: json['Passport'],
//       mobile: json['Mobile'],
//       panNo: json['PAN No'],
//       visa: json['Visa'],
//       emailId: json['Email ID'],
//       emergencyContactName: json['Emergency Contact Name'],
//       emergencyContactNumber: json['Emergency Contact Number'],
//       availableForRelocation: json['Available for Relocation'],
//       educationalQualifications: json['Educational Qualifications'] != null
//           ? (json['Educational Qualifications'] as List)
//           .map((e) => EducationalQualification.fromJson(e))
//           .toList()
//           : null,
//       trainingDetails: json['Training Details'] != null
//           ? (json['Training Details'] as List)
//           .map((e) => TrainingDetail.fromJson(e))
//           .toList()
//           : null,
//       technicalCertifications: json['Technical Certifications'] != null
//           ? (json['Technical Certifications'] as List)
//           .map((e) => TechnicalCertification.fromJson(e))
//           .toList()
//           : null,
//       familyDetails: json['Family Details'] != null
//           ? (json['Family Details'] as List)
//           .map((e) => FamilyDetail.fromJson(e))
//           .toList()
//           : null,
//       references: json['References'] != null
//           ? (json['References'] as List)
//           .map((e) => Reference.fromJson(e))
//           .toList()
//           : null,
//     );
//   }
//
//   @override
//   String toString() {
//     return 'User{id: $id, name: $name, permanentAddress: $permanentAddress, currentAddress: $currentAddress, dateOfBirth: $dateOfBirth, age: $age, gender: $gender, passport: $passport, mobile: $mobile, panNo: $panNo, visa: $visa, emailId: $emailId, emergencyContactName: $emergencyContactName, emergencyContactNumber: $emergencyContactNumber, availableForRelocation: $availableForRelocation, educationalQualifications: $educationalQualifications, trainingDetails: $trainingDetails, technicalCertifications: $technicalCertifications, familyDetails: $familyDetails, references: $references}';
//   }
// }



class User {
  String? id;
  String? name;
  Address? permanentAddress;
  Address? currentAddress;
  String? dateOfBirth;
  String? age;
  String? gender;
  String? passport;
  String? mobile;
  String? panNo;
  String? visa;
  String? emailId;
  String? emergencyContactName;
  String? emergencyContactNumber;
  String? availableForRelocation;
  List<EducationalQualification>? educationalQualifications;
  List<TrainingDetail>? trainingDetails;
  List<TechnicalCertification>? technicalCertifications;
  List<FamilyDetail>? familyDetails;
  List<Reference>? references;
  List<ImageModel>? images; // New field for images

  User({
    this.id,
    this.name,
    this.permanentAddress,
    this.currentAddress,
    this.dateOfBirth,
    this.age,
    this.gender,
    this.passport,
    this.mobile,
    this.panNo,
    this.visa,
    this.emailId,
    this.emergencyContactName,
    this.emergencyContactNumber,
    this.availableForRelocation,
    this.educationalQualifications,
    this.trainingDetails,
    this.technicalCertifications,
    this.familyDetails,
    this.references,
    this.images, // Initialize images
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id']?['\$oid'],
      name: json['Name'],
      permanentAddress: json['Permanent Address'] != null
          ? Address.fromJson(json['Permanent Address'])
          : null,
      currentAddress: json['Current Address'] != null
          ? Address.fromJson(json['Current Address'])
          : null,
      dateOfBirth: json['Date of Birth'],
      age: json['Age'],
      gender: json['Gender'],
      passport: json['Passport'],
      mobile: json['Mobile'],
      panNo: json['PAN No'],
      visa: json['Visa'],
      emailId: json['Email ID'],
      emergencyContactName: json['Emergency Contact Name'],
      emergencyContactNumber: json['Emergency Contact Number'],
      availableForRelocation: json['Available for Relocation'],
      educationalQualifications: json['Educational Qualifications'] != null
          ? (json['Educational Qualifications'] as List)
          .map((e) => EducationalQualification.fromJson(e))
          .toList()
          : null,
      trainingDetails: json['Training Details'] != null
          ? (json['Training Details'] as List)
          .map((e) => TrainingDetail.fromJson(e))
          .toList()
          : null,
      technicalCertifications: json['Technical Certifications'] != null
          ? (json['Technical Certifications'] as List)
          .map((e) => TechnicalCertification.fromJson(e))
          .toList()
          : null,
      familyDetails: json['Family Details'] != null
          ? (json['Family Details'] as List)
          .map((e) => FamilyDetail.fromJson(e))
          .toList()
          : null,
      references: json['References'] != null
          ? (json['References'] as List)
          .map((e) => Reference.fromJson(e))
          .toList()
          : null,
      images: json['images'] != null
          ? (json['images'] as List).map((e) => ImageModel.fromJson(e)).toList()
          : null, // Parse images
    );
  }

  @override
  String toString() {
    return 'User{id: $id, name: $name, permanentAddress: $permanentAddress, currentAddress: $currentAddress, dateOfBirth: $dateOfBirth, age: $age, gender: $gender, passport: $passport, mobile: $mobile, panNo: $panNo, visa: $visa, emailId: $emailId, emergencyContactName: $emergencyContactName, emergencyContactNumber: $emergencyContactNumber, availableForRelocation: $availableForRelocation, educationalQualifications: $educationalQualifications, trainingDetails: $trainingDetails, technicalCertifications: $technicalCertifications, familyDetails: $familyDetails, references: $references, images: $images}';
  }
}




class Address {
  String? streetAddress;
  String? city;
  String? state;
  String? zipCode;
  String? country;

  Address({
    this.streetAddress,
    this.city,
    this.state,
    this.zipCode,
    this.country,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      streetAddress: json['Street Address'],
      city: json['City'],
      state: json['State'],
      zipCode: json['Zip Code'],
      country: json['Country'],
    );
  }

  @override
  String toString() {
    return 'Address{streetAddress: $streetAddress, city: $city, state: $state, zipCode: $zipCode, country: $country}';
  }
}

class EducationalQualification {
  String? srNo;
  String? nameOfSchoolUniversity;
  String? qualification;
  String? cgpa;
  String? passOutYear;

  EducationalQualification({
    this.srNo,
    this.nameOfSchoolUniversity,
    this.qualification,
    this.cgpa,
    this.passOutYear,
  });

  factory EducationalQualification.fromJson(Map<String, dynamic> json) {
    return EducationalQualification(
      srNo: json['Sr No.'],
      nameOfSchoolUniversity: json['Name of the School/ University'],
      qualification: json['Qualification'],
      cgpa: json['% or CGPA'],
      passOutYear: json['Pass out Year'],
    );
  }

  @override
  String toString() {
    return 'EducationalQualification{srNo: $srNo, nameOfSchoolUniversity: $nameOfSchoolUniversity, qualification: $qualification, cgpa: $cgpa, passOutYear: $passOutYear}';
  }
}

class TrainingDetail {
  String? program;
  String? contents;
  String? organizedBy;
  String? duration;

  TrainingDetail({
    this.program,
    this.contents,
    this.organizedBy,
    this.duration,
  });

  factory TrainingDetail.fromJson(Map<String, dynamic> json) {
    return TrainingDetail(
      program: json['Program'],
      contents: json['Contents'],
      organizedBy: json['Organized By'],
      duration: json['Duration'],
    );
  }

  @override
  String toString() {
    return 'TrainingDetail{program: $program, contents: $contents, organizedBy: $organizedBy, duration: $duration}';
  }
}

class TechnicalCertification {
  String? srNo;
  String? certification;
  String? duration;

  TechnicalCertification({
    this.srNo,
    this.certification,
    this.duration,
  });

  factory TechnicalCertification.fromJson(Map<String, dynamic> json) {
    return TechnicalCertification(
      srNo: json['Sr No'],
      certification: json['Certification'],
      duration: json['Duration'],
    );
  }

  @override
  String toString() {
    return 'TechnicalCertification{srNo: $srNo, certification: $certification, duration: $duration}';
  }
}

class FamilyDetail {
  String? relation;
  String? occupation;
  String? residentLocation;

  FamilyDetail({
    this.relation,
    this.occupation,
    this.residentLocation,
  });

  factory FamilyDetail.fromJson(Map<String, dynamic> json) {
    return FamilyDetail(
      relation: json['Relation'],
      occupation: json['Occupation/Profession'],
      residentLocation: json['Resident Location'],
    );
  }

  @override
  String toString() {
    return 'FamilyDetail{relation: $relation, occupation: $occupation, residentLocation: $residentLocation}';
  }
}

class Reference {
  String? name;
  String? designation;
  String? contactNo;

  Reference({
    this.name,
    this.designation,
    this.contactNo,
  });

  factory Reference.fromJson(Map<String, dynamic> json) {
    return Reference(
      name: json['Name'],
      designation: json['Designation'],
      contactNo: json['Contact No'],
    );
  }

  @override
  String toString() {
    return 'Reference{name: $name, designation: $designation, contactNo: $contactNo}';
  }
}


class ImageModel {
  String? type;
  String? fileName;
  String? content;

  ImageModel({
    this.type,
    this.fileName,
    this.content,
  });

  factory ImageModel.fromJson(Map<String, dynamic> json) {
    return ImageModel(
      type: json['type'],
      fileName: json['file_name'],
      content: json['content'],
    );
  }

  @override
  String toString() {
    return 'Image{type: $type, fileName: $fileName}';
  }
}
