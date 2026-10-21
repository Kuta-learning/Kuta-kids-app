enum KidsLevel {
  lkg,
  ukg,
  kg3;

  String get displayName {
    switch (this) {
      case KidsLevel.lkg:
        return 'LKG';
      case KidsLevel.ukg:
        return 'UKG';
      case KidsLevel.kg3:
        return 'KG3';
    }
  }

  // API gradeLevel integer mapping
  int get apiGradeLevel {
    switch (this) {
      case KidsLevel.lkg:
        return 2;
      case KidsLevel.ukg:
        return 3;
      case KidsLevel.kg3:
        return 4;
    }
  }

  static KidsLevel fromString(String value) {
    switch (value) {
      case 'ukg':
        return KidsLevel.ukg;
      case 'kg3':
        return KidsLevel.kg3;
      default:
        return KidsLevel.lkg;
    }
  }

  static KidsLevel fromApiGradeLevel(int level) {
    switch (level) {
      case 3:
        return KidsLevel.ukg;
      case 4:
        return KidsLevel.kg3;
      default:
        return KidsLevel.lkg;
    }
  }

  String toStorageString() => name;
}
