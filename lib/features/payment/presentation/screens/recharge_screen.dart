import 'package:eefood/app_routes.dart';
import 'package:eefood/core/di/injection.dart';
import 'package:eefood/core/widgets/snack_bar.dart';
import 'package:eefood/features/payment/presentation/provider/diamond_packages_cubit.dart';
import 'package:eefood/features/payment/presentation/provider/diamond_packages_state.dart';
import 'package:eefood/features/payment/presentation/provider/payment_cubit.dart';
import 'package:eefood/features/payment/presentation/provider/payment_state.dart';
import 'package:eefood/features/payment/presentation/widgets/diamond_package_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RechargeScreen extends StatefulWidget {
  const RechargeScreen({super.key});

  @override
  State<RechargeScreen> createState() => _RechargeScreenState();
}

class _RechargeScreenState extends State<RechargeScreen> {
  late PaymentCubit _paymentCubit;
  late DiamondPackagesCubit _packagesCubit;
  int? _selectedPackageId;
  bool _isLoadingDialogOpen = false;

  @override
  void initState() {
    super.initState();
    _packagesCubit = getIt<DiamondPackagesCubit>();
    _paymentCubit = getIt<PaymentCubit>();
    _packagesCubit.fetchPackages();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocListener<PaymentCubit, PaymentState>(
      bloc: _paymentCubit,
      listener: (context, state) {
        if (state is PaymentLoading) {
          _isLoadingDialogOpen = true;
          _showPaymentProcessing(context);
        } else if (state is PaymentSuccess) {
          if (_isLoadingDialogOpen) {
            _isLoadingDialogOpen = false;
            Navigator.of(context).pop();
          }
          Navigator.of(context).pushNamed(
            AppRoutes.vnpayWebviewScreen,
            arguments: {
              'paymentUrl': state.paymentUrl,
              'transactionId': state.transactionId,
            },
          ).then((_) {
            _paymentCubit.reset();
          });
        } else if (state is PaymentFailure) {
          if (_isLoadingDialogOpen) {
            _isLoadingDialogOpen = false;
            Navigator.of(context).pop();
          }
          showCustomSnackBar(context, state.message);
        }
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: theme.appBarTheme.backgroundColor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Nạp Kim Cương',
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: BlocBuilder<DiamondPackagesCubit, DiamondPackagesState>(
          bloc: _packagesCubit,
          builder: (context, state) {
            if (state.isLoading && state.packages.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7C6AFF)),
                ),
              );
            }

            if (state.error != null && state.packages.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('❌', style: TextStyle(fontSize: 48)),
                    const SizedBox(height: 16),
                    Text(
                      state.error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => _packagesCubit.fetchPackages(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7C6AFF),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Thử lại',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.orange.shade400.withValues(alpha: 0.15),
                            Colors.deepOrange.shade500.withValues(alpha: 0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF7C6AFF).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        children: [
                          const Text('💎', style: TextStyle(fontSize: 40)),
                          const SizedBox(height: 12),
                          const Text(
                            'Nạp kim cương để ủng hộ streamer têu thích của bạn',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF7C6AFF),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    // Packages title
                    const Text(
                      'Chọn gói nạp',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Package grid
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.85,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                      itemCount: state.packages.length,
                      itemBuilder: (context, index) {
                        final package = state.packages[index];
                        return DiamondPackageCard(
                          package: package,
                          isSelected: _selectedPackageId == package.id,
                          onTap: () {
                            setState(() {
                              _selectedPackageId = package.id;
                            });
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    // Purchase button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _selectedPackageId != null
                            ? () {
                                _showPurchaseDialog(context);
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _selectedPackageId != null
                              ? const Color(0xFF7C6AFF)
                              : const Color(0xFF3A3A4E),
                          disabledBackgroundColor: const Color(0xFF3A3A4E),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          _selectedPackageId != null
                              ? 'Tiến hành thanh toán'
                              : 'Chọn gói nạp',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Info text
                    Center(
                      child: Text(
                        'Nhấp để chọn gói nạp',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showPurchaseDialog(BuildContext context) {
    final selectedPackage = _packagesCubit.state.packages.firstWhere(
      (p) => p.id == _selectedPackageId,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Text('💎', style: TextStyle(fontSize: 24)),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Xác nhận nạp kim cương',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF7C6AFF).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF7C6AFF).withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'Kim cương: ${selectedPackage.diamondAmount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (selectedPackage.bonusDiamond > 0) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Thưởng: +${selectedPackage.bonusDiamond}',
                        style: const TextStyle(
                          color: Color(0xFFFF6B6B),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Divider(color: Color(0xFF3A3A4E)),
                      const SizedBox(height: 8),
                      Text(
                        'Tổng: ${selectedPackage.totalDiamond}',
                        style: const TextStyle(
                          color: Color(0xFF7C6AFF),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Giá: ${selectedPackage.displayPrice}',
                style: const TextStyle(
                  color: Color(0xFF7C6AFF),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Hủy',
              style: TextStyle(color: Color(0xFF7C6AFF)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _paymentCubit.createPayment(
                diamondPackageId: _selectedPackageId!,
                provider: 'VNPAY',
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7C6AFF),
            ),
            child: const Text(
              'Thanh toán',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPaymentProcessing(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7C6AFF)),
              ),
              const SizedBox(height: 20),
              const Text(
                'Đang xử lý thanh toán...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
