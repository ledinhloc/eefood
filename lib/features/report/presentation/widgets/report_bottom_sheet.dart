import 'package:eefood/core/constants/app_constants.dart';
import 'package:eefood/core/di/injection.dart';
import 'package:eefood/core/widgets/loading_overlay.dart';
import 'package:eefood/core/widgets/snack_bar.dart';
import 'package:eefood/features/auth/domain/entities/user.dart';
import 'package:eefood/features/auth/domain/usecases/auth_usecases.dart';
import 'package:eefood/features/report/domain/repositories/report_repository.dart';
import 'package:flutter/material.dart';
// Import LoadingOverlay

class ReportBottomSheet extends StatefulWidget {
  final int targerId;
  final String type;
  final String? targetTitle;

  const ReportBottomSheet({
    super.key,
    required this.targerId,
    required this.type,
    this.targetTitle,
  });

  @override
  State<ReportBottomSheet> createState() => _ReportBottomSheetState();
}

class _ReportBottomSheetState extends State<ReportBottomSheet> {
  String? selectedReason;
  final TextEditingController _otherReasonController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  final ReportRepository _reportRepository = getIt<ReportRepository>();
  final GetCurrentUser _getCurrentUser = getIt<GetCurrentUser>();
  final LoadingOverlay _loadingOverlay = LoadingOverlay();
  late User? user;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      }
    });

    _getUser();
  }

  Future<void> _getUser() async {
    user = await _getCurrentUser();
  }

  @override
  void dispose() {
    _otherReasonController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  bool get isOtherSelected => selectedReason == "Khác";
  bool get canSubmit =>
      selectedReason != null &&
      (!isOtherSelected || _otherReasonController.text.trim().isNotEmpty);

  Future<void> _submitReport() async {
  try {
    _focusNode.unfocus();

    final reportReason = isOtherSelected
        ? _otherReasonController.text.trim()
        : selectedReason;

    _loadingOverlay.show();

    await _reportRepository.createReport(
      user!.id,
      widget.type,
      reportReason!,
      widget.targerId,
    );

    _loadingOverlay.hide();

    if (!mounted) return;

    Navigator.pop(context);

    if (mounted) {
      showCustomSnackBar(
        context,
        'Đã gửi báo cáo ${widget.targetTitle} với lý do: $reportReason',
      );
    }
  } catch (e) {
    _loadingOverlay.hide();

    if (mounted) {
      showCustomSnackBar(context, 'Không thể báo cáo nhiều lần', isError: true);
    }

    Navigator.pop(context);
  }
}

  @override
  Widget build(BuildContext context) {
    String titile;
    if(widget.type=='POST') {
      titile = "Báo cáo bài viết";
    }
    else if(widget.type == 'COMMENT') {
      titile = "Báo cáo bình luận";
    }
    else {
      titile = "Báo cáo tin";
    }
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.report_outlined,
                      color: Colors.red.shade400,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "$titile ${widget.targetTitle}",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.black54),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                "Vui lòng chọn lý do báo cáo của bạn",
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 20),

              // Reason Chips
              Wrap(
                spacing: 8,
                runSpacing: 10,
                children: AppConstants.reasons.map((reason) {
                  final isSelected = selectedReason == reason;
                  return InkWell(
                    onTap: () {
                      setState(() {
                        selectedReason = reason;
                        if (!isOtherSelected) {
                          _otherReasonController.clear();
                          _focusNode.unfocus();
                        }
                      });
                    },
                    borderRadius: BorderRadius.circular(25),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.red.shade400
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: isSelected
                              ? Colors.red.shade400
                              : Colors.grey.shade300,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isSelected)
                            const Padding(
                              padding: EdgeInsets.only(right: 6),
                              child: Icon(
                                Icons.check_circle,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          Text(
                            reason,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),

              // Other reason input
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: isOtherSelected
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          Text(
                            "Vui lòng mô tả chi tiết",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _otherReasonController,
                            focusNode: _focusNode,
                            maxLines: 3,
                            maxLength: 200,
                            autofocus: true,
                            decoration: InputDecoration(
                              hintText: "Nhập lý do của bạn...",
                              hintStyle: TextStyle(color: Colors.grey.shade400),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade400,
                                  width: 2,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.transparent,
                                ),
                              ),
                              contentPadding: const EdgeInsets.all(12),
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),

              const SizedBox(height: 20),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: canSubmit ? _submitReport : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade400,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade300,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    canSubmit ? "Gửi báo cáo" : "Vui lòng chọn lý do",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
