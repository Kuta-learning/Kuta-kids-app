enum KidsLevel {
  nursery,
  lowerKg,
  upperKg;

  String get displayName {
    switch (this) {
      case KidsLevel.nursery:
        return 'Nursery';
      case KidsLevel.lowerKg:
        return 'Lower KG';
      case KidsLevel.upperKg:
        return 'Upper KG';
    }
  }

  String get ageRange {
    switch (this) {
      case KidsLevel.nursery:
        return 'Ages 2½ – 3½';
      case KidsLevel.lowerKg:
        return 'Ages 3½ – 4½';
      case KidsLevel.upperKg:
        return 'Ages 4½ – 5½';
    }
  }

  static KidsLevel fromString(String value) {
    switch (value) {
      case 'lowerKg':
        return KidsLevel.lowerKg;
      case 'upperKg':
        return KidsLevel.upperKg;
      default:
        return KidsLevel.nursery;
    }
  }

  String toStorageString() => name;
}
