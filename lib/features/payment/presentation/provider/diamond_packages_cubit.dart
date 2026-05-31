import 'package:eefood/features/payment/data/model/diamond_package_response.dart';
import 'package:eefood/features/payment/domain/repository/payment_repository.dart';
import 'package:eefood/features/payment/presentation/provider/diamond_packages_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DiamondPackagesCubit extends Cubit<DiamondPackagesState> {
  final PaymentRepository repository;

  DiamondPackagesCubit({required this.repository})
    : super(DiamondPackagesState());

  Future<void> fetchPackages() async {
    if (state.packages.isNotEmpty) return; // Already loaded

    emit(state.copyWith(isLoading: true, error: null));
    try {
      final responses = await repository.getListDiamondPackages();
      final packages = responses
          .map((response) => _responseToPackage(response))
          .toList();
      emit(state.copyWith(packages: packages, isLoading: false));
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          error: 'Không thể tải danh sách gói nạp. Vui lòng thử lại.',
        ),
      );
    }
  }

  DiamondPackage _responseToPackage(DiamondPackageResponse response) {
    return DiamondPackage(
      id: response.id ?? 0,
      diamondAmount: response.diamondAmount ?? 0,
      bonusDiamond: response.bonusDiamond ?? 0,
      price: response.price ?? 0,
      currency: response.currency ?? 'VND',
      isActive: response.isActive ?? true,
    );
  }

  void clear() {
    emit(DiamondPackagesState());
  }
}
