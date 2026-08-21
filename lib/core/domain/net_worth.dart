/// Net worth = assets − liabilities for overview dashboard.
double computeNetWorth({
  required double savingsTotal,
  required double owedToMeTotal,
  required double bankUsedTotal,
  required double iOweTotal,
}) {
  return savingsTotal + owedToMeTotal - bankUsedTotal - iOweTotal;
}

double sumAmounts(Iterable<double> values) {
  var total = 0.0;
  for (final v in values) {
    total += v;
  }
  return total;
}
