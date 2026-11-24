/// 1500.5 -> ₦1,500.50 (use decimals: 0 for ₦1,501)
String formatNaira(double value, {int decimals = 2}) {
  final fixed = value.toStringAsFixed(decimals);
  final dot = fixed.indexOf('.');
  final wholePart = dot == -1 ? fixed : fixed.substring(0, dot);
  final fraction = dot == -1 ? '' : fixed.substring(dot);

  final grouped = wholePart.replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ',',
  );
  return '₦$grouped$fraction';
}
