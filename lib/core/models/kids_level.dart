/// The three learning levels supported by the Kuta Kids app.
enum KidsLevel {
  nursery,
  lowerKg,
  upperKg;

  /// Human-readable display name shown in the UI.
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

  /// Short label used on cards and badges.
  String get shortLabel {
    switch (this) {
      case KidsLevel.nursery:
        return 'NRS';
      case KidsLevel.lowerKg:
        return 'LKG';
      case KidsLevel.upperKg:
        return 'UKG';
    }
  }

  /// Age range description shown on level selection screen.
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

  /// Parse from a stored string value (e.g. from shared_preferences).
  static KidsLevel fromString(String value) {
    switch (value) {
      case 'nursery':
        return KidsLevel.nursery;
      case 'lowerKg':
        return KidsLevel.lowerKg;
      case 'upperKg':
        return KidsLevel.upperKg;
      default:
        return KidsLevel.nursery;
    }
  }

  /// Serialise to a string for storage.
  String toStorageString() => name;
}
