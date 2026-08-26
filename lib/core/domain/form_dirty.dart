/// True when any tracked field differs from what the form opened with.
///
/// Values are compared trimmed, so trailing whitespace alone does not enable
/// a save button.
bool isFormDirty(List<String> initial, List<String> current) {
  if (initial.length != current.length) return true;
  for (var i = 0; i < initial.length; i++) {
    if (initial[i].trim() != current[i].trim()) return true;
  }
  return false;
}
