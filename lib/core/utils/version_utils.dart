class VersionUtils {
  /// Compares two semantic version strings (e.g., '1.2.0' and '2.0.1').
  /// Returns:
  ///   < 0 if a < b
  ///   0 if a == b
  ///   > 0 if a > b
  static int compareVersions(String a, String b) {
    final partsA = a.split('.').map((s) => int.tryParse(s) ?? 0).toList();
    final partsB = b.split('.').map((s) => int.tryParse(s) ?? 0).toList();

    final maxLength = partsA.length > partsB.length ? partsA.length : partsB.length;

    for (int i = 0; i < maxLength; i++) {
      final partA = i < partsA.length ? partsA[i] : 0;
      final partB = i < partsB.length ? partsB[i] : 0;

      if (partA < partB) return -1;
      if (partA > partB) return 1;
    }

    return 0; // Versions are strictly equal
  }

  static bool isValidSemanticVersion(String version) {
    final RegExp regex = RegExp(r'^\d+\.\d+\.\d+$');
    return regex.hasMatch(version);
  }

  static String bumpPatchVersion(String version) {
    if (!isValidSemanticVersion(version)) return version;
    final parts = version.split('.').map(int.parse).toList();
    parts[2]++;
    return parts.join('.');
  }

  static bool satisfiesConstraint(String version, String constraint) {
    if (constraint == 'any' || constraint.isEmpty) return true;
    if (constraint.startsWith('^')) {
      final baseVersion = constraint.substring(1);
      if (!isValidSemanticVersion(version) || !isValidSemanticVersion(baseVersion)) return false;
      final vParts = version.split('.').map(int.parse).toList();
      final bParts = baseVersion.split('.').map(int.parse).toList();
      
      // Must not be less than base version
      if (compareVersions(version, baseVersion) < 0) return false;
      
      // Major version must match, unless it's 0, then minor must match
      if (bParts[0] > 0) {
        return vParts[0] == bParts[0];
      } else if (bParts[1] > 0) {
        return vParts[0] == 0 && vParts[1] == bParts[1];
      } else {
        return vParts[0] == 0 && vParts[1] == 0 && vParts[2] == bParts[2];
      }
    }
    
    // Direct match
    return compareVersions(version, constraint) == 0;
  }
}
