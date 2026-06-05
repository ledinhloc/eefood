import 'package:intl/intl.dart';

class DiamondPackagesState {
  final List<DiamondPackage> packages;
  final bool isLoading;
  final String? error;

  DiamondPackagesState({
    this.packages = const [],
    this.isLoading = false,
    this.error,
  });

  DiamondPackagesState copyWith({
    List<DiamondPackage>? packages,
    bool? isLoading,
    String? error,
  }) {
    return DiamondPackagesState(
      packages: packages ?? this.packages,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class DiamondPackage {
  final int id;
  final int diamondAmount;
  final int bonusDiamond;
  final num price;
  final String currency;
  final bool isActive;

  DiamondPackage({
    required this.id,
    required this.diamondAmount,
    required this.bonusDiamond,
    required this.price,
    required this.currency,
    required this.isActive,
  });

  int get totalDiamond => diamondAmount + bonusDiamond;

  String get displayPrice {
    if (currency == 'VND') {
      return '${formatMoney(price)}đ';
    }
    return '$price $currency';
  }

  String formatMoney(num amount) {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return formatter.format(amount).replaceAll(',', '.');
  }
}
