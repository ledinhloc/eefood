import 'package:eefood/features/profile/data/models/user_height_response.dart';
import 'package:eefood/features/profile/data/models/user_weight_response.dart';
import 'package:eefood/features/profile/presentation/provider/body_metrics_cubit.dart';
import 'package:eefood/features/profile/presentation/provider/body_metrics_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class BodyMetricFormSheet extends StatefulWidget {
  final bool isHeight;
  final UserHeightResponse? heightItem;
  final UserWeightResponse? weightItem;

  const BodyMetricFormSheet.height({super.key, UserHeightResponse? item})
    : isHeight = true,
      heightItem = item,
      weightItem = null;

  const BodyMetricFormSheet.weight({super.key, UserWeightResponse? item})
    : isHeight = false,
      heightItem = null,
      weightItem = item;

  @override
  State<BodyMetricFormSheet> createState() => _BodyMetricFormSheetState();
}

class _BodyMetricFormSheetState extends State<BodyMetricFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _valueController;
  late DateTime _recordedDate;

  bool get _isEditing => widget.heightItem != null || widget.weightItem != null;

  @override
  void initState() {
    super.initState();
    final initialValue = widget.isHeight
        ? widget.heightItem?.heightCm
        : widget.weightItem?.weightKg;
    _valueController = TextEditingController(
      text: initialValue == null ? '' : initialValue.toStringAsFixed(1),
    );
    final initialDate =
        widget.heightItem?.recordedDate ??
        widget.weightItem?.recordedDate ??
        DateTime.now();
    _recordedDate = DateTime(
      initialDate.year,
      initialDate.month,
      initialDate.day,
    );
  }

  @override
  void dispose() {
    _valueController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _recordedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (date == null || !mounted) return;

    setState(() {
      _recordedDate = DateTime(date.year, date.month, date.day);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final cubit = context.read<BodyMetricsCubit>();
    final value = double.parse(_valueController.text.trim());
    final recordedDate = DateTime(
      _recordedDate.year,
      _recordedDate.month,
      _recordedDate.day,
    );
    final bool success;

    if (widget.isHeight) {
      final id = widget.heightItem?.id;
      success = id == null
          ? await cubit.createHeight(
              heightCm: value,
              recordedDate: recordedDate,
            )
          : await cubit.updateHeight(
              id: id,
              heightCm: value,
              recordedDate: recordedDate,
            );
    } else {
      final id = widget.weightItem?.id;
      success = id == null
          ? await cubit.createWeight(
              weightKg: value,
              recordedDate: recordedDate,
            )
          : await cubit.updateWeight(
              id: id,
              weightKg: value,
              recordedDate: recordedDate,
            );
    }

    if (!mounted || !success) return;
    Navigator.pop(context);
  }

  Future<void> _delete() async {
    if (!_isEditing) return;

    final title = widget.isHeight
        ? 'Xóa bản ghi chiều cao?'
        : 'Xóa bản ghi cân nặng?';
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(title),
            content: const Text('Thao tác này không thể hoàn tác.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Hủy'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Xóa'),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed || !mounted) return;

    final cubit = context.read<BodyMetricsCubit>();
    final success = widget.isHeight
        ? await cubit.deleteHeight(widget.heightItem!.id)
        : await cubit.deleteWeight(widget.weightItem!.id);

    if (!mounted || !success) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final title = widget.isHeight ? 'chiều cao' : 'cân nặng';
    final unit = widget.isHeight ? 'cm' : 'kg';

    return BlocBuilder<BodyMetricsCubit, BodyMetricsState>(
      builder: (context, state) {
        return Padding(
          padding: EdgeInsets.fromLTRB(20, 18, 20, bottomInset + 20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _isEditing ? 'Sửa $title' : 'Thêm $title',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _valueController,
                  autofocus: true,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  decoration: InputDecoration(
                    labelText: widget.isHeight ? 'Chiều cao' : 'Cân nặng',
                    suffixText: unit,
                    prefixIcon: Icon(
                      widget.isHeight
                          ? Icons.height
                          : Icons.monitor_weight_outlined,
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    final parsed = double.tryParse(value?.trim() ?? '');
                    if (parsed == null || parsed <= 0) {
                      return 'Nhập giá trị lớn hơn 0';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                Material(
                  color: colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.6,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 4,
                    ),
                    leading: const Icon(Icons.event_outlined),
                    title: const Text('Ngày ghi nhận'),
                    subtitle: Text(
                      DateFormat('dd/MM/yyyy').format(_recordedDate),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: _pickDate,
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: state.isSubmitting ? null : _submit,
                    icon: state.isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.check_rounded),
                    label: Text(_isEditing ? 'Cập nhật' : 'Thêm'),
                  ),
                ),
                if (_isEditing) ...[
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                      onPressed: state.isSubmitting ? null : _delete,
                      icon: const Icon(Icons.delete_outline_rounded),
                      label: const Text('Xóa'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
