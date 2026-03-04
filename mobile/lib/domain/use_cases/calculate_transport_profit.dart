/// Use case: calculate net profit after transport costs when selling at a
/// remote market versus the local market.
class CalculateTransportProfit {
  /// Returns a [TransportProfitResult] with the breakdown.
  TransportProfitResult call({
    required double localPricePerKg,
    required double remotePricePerKg,
    required double quantityKg,
    required double distanceKm,
    double costPerKmPerTon = 3.0, // ₹ per km per tonne
    double loadingCharge = 500.0,
    double unloadingCharge = 500.0,
    double commissionPercent = 2.5,
    double wastagePercent = 1.0,
  }) {
    // Revenue at remote market
    final grossRemoteRevenue = remotePricePerKg * quantityKg;

    // Revenue at local market (baseline)
    final localRevenue = localPricePerKg * quantityKg;

    // Transport cost
    final tonnes = quantityKg / 1000;
    final transportCost = distanceKm * costPerKmPerTon * tonnes;

    // Commission at remote market
    final commission = grossRemoteRevenue * (commissionPercent / 100);

    // Wastage loss
    final wastageLoss = remotePricePerKg * quantityKg * (wastagePercent / 100);

    // Loading / unloading
    final handlingCharges = loadingCharge + unloadingCharge;

    // Total costs
    final totalCosts = transportCost + commission + wastageLoss + handlingCharges;

    // Net remote revenue
    final netRemoteRevenue = grossRemoteRevenue - totalCosts;

    // Profit vs local sale
    final additionalProfit = netRemoteRevenue - localRevenue;
    final profitPercent =
        localRevenue > 0 ? (additionalProfit / localRevenue) * 100 : 0;

    return TransportProfitResult(
      localRevenue: localRevenue,
      grossRemoteRevenue: grossRemoteRevenue,
      transportCost: transportCost,
      commission: commission,
      wastageLoss: wastageLoss,
      handlingCharges: handlingCharges,
      totalCosts: totalCosts,
      netRemoteRevenue: netRemoteRevenue,
      additionalProfit: additionalProfit,
      profitPercent: profitPercent.toDouble(),
      isWorthTransporting: additionalProfit > 0,
    );
  }
}

class TransportProfitResult {
  final double localRevenue;
  final double grossRemoteRevenue;
  final double transportCost;
  final double commission;
  final double wastageLoss;
  final double handlingCharges;
  final double totalCosts;
  final double netRemoteRevenue;
  final double additionalProfit;
  final double profitPercent;
  final bool isWorthTransporting;

  const TransportProfitResult({
    required this.localRevenue,
    required this.grossRemoteRevenue,
    required this.transportCost,
    required this.commission,
    required this.wastageLoss,
    required this.handlingCharges,
    required this.totalCosts,
    required this.netRemoteRevenue,
    required this.additionalProfit,
    required this.profitPercent,
    required this.isWorthTransporting,
  });
}
