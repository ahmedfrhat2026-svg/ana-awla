String fmtMoney(num n, {String suffix = ' ج'}) {
  final isNeg = n < 0;
  final v = n.abs();
  String s;
  if (v >= 1000) {
    s = v.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
  } else if (v == v.roundToDouble()) {
    s = v.toStringAsFixed(0);
  } else {
    s = v.toStringAsFixed(2);
  }
  return '${isNeg ? '-' : ''}$s$suffix';
}
