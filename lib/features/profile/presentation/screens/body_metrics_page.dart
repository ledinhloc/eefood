import 'package:eefood/core/di/injection.dart';
import 'package:eefood/core/widgets/snack_bar.dart';
import 'package:eefood/features/profile/data/models/user_height_response.dart';
import 'package:eefood/features/profile/data/models/user_weight_response.dart';
import 'package:eefood/features/profile/domain/repositories/body_metrics_repository.dart';
import 'package:eefood/features/profile/presentation/provider/body_metrics_cubit.dart';
import 'package:eefood/features/profile/presentation/provider/body_metrics_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

enum _BodyMetricTab { weight, height }

class BodyMetricsPage extends StatelessWidget {
  const BodyMetricsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          BodyMetricsCubit(repository: getIt<BodyMetricsRepository>())
            ..loadAll(),
      child: const _BodyMetricsView(),
    );
  }
}

class _BodyMetricsView extends StatefulWidget {
  const _BodyMetricsView();

  @override
  State<_BodyMetricsView> createState() => _BodyMetricsViewState();
}

class _BodyMetricsViewState extends State<_BodyMetricsView> {
  _BodyMetricTab _selectedTab = _BodyMetricTab.weight;

  String _formatMetric(double? value, String suffix) {
    if (value == null) return '--';
    final formatted = value % 1 == 0
        ? value.toInt().toString()
        : value.toStringAsFixed(1);
    return '$formatted $suffix';
  }

  String _formatDate(DateTime? value) {
    if (value == null) return 'Chưa có ngày';
    return DateFormat('dd/MM/yyyy HH:mm').format(value);
  }

  String _bmiLabel(double? bmi) {
    if (bmi == null) return '--';
    if (bmi < 18.5) return 'Thiếu cân';
    if (bmi < 25) return 'Bình thường';
    if (bmi < 30) return 'Thừa cân';
    return 'Béo phì';
  }

  Future<void> _refresh() => context.read<BodyMetricsCubit>().loadAll();

  Future<void> _openHeightSheet([UserHeightResponse? item]) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => BlocProvider.value(
        value: context.read<BodyMetricsCubit>(),
        child: _MetricFormSheet.height(item: item),
      ),
    );
  }

  Future<void> _openWeightSheet([UserWeightResponse? item]) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => BlocProvider.value(
        value: context.read<BodyMetricsCubit>(),
        child: _MetricFormSheet.weight(item: item),
      ),
    );
  }

  Future<void> _confirmDeleteHeight(UserHeightResponse item) async {
    final confirmed = await _confirmDelete('Xóa bản ghi chiều cao?');
    if (!confirmed || !mounted) return;

    final deleted = await context.read<BodyMetricsCubit>().deleteHeight(
      item.id,
    );
    if (deleted && mounted) {
      showCustomSnackBar(context, 'Đã xóa chiều cao');
    }
  }

  Future<void> _confirmDeleteWeight(UserWeightResponse item) async {
    final confirmed = await _confirmDelete('Xóa bản ghi cân nặng?');
    if (!confirmed || !mounted) return;

    final deleted = await context.read<BodyMetricsCubit>().deleteWeight(
      item.id,
    );
    if (deleted && mounted) {
      showCustomSnackBar(context, 'Đã xóa cân nặng');
    }
  }

  Future<bool> _confirmDelete(String title) async {
    return await showDialog<bool>(
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
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final pageBackground = isDark
        ? colorScheme.surface
        : const Color(0xFFF7FAF8);
    final actionColor = isDark
        ? const Color(0xFF8FD6C4)
        : const Color(0xFF2F7D6D);

    return BlocListener<BodyMetricsCubit, BodyMetricsState>(
      listenWhen: (previous, current) =>
          previous.error != current.error && current.error != null,
      listener: (context, state) {
        showCustomSnackBar(context, state.error!, isError: true);
      },
      child: BlocBuilder<BodyMetricsCubit, BodyMetricsState>(
        builder: (context, state) {
          final latestHeight = state.latestHeight;
          final latestWeight = state.latestWeight;
          final bmi = state.bmi;

          return Scaffold(
            backgroundColor: pageBackground,
            appBar: AppBar(
              backgroundColor: pageBackground,
              surfaceTintColor: Colors.transparent,
              title: const Text('Chỉ số cơ thể'),
            ),
            floatingActionButton: FloatingActionButton.extended(
              backgroundColor: actionColor,
              foregroundColor: isDark ? Colors.black : Colors.white,
              onPressed: state.isSubmitting
                  ? null
                  : () {
                      if (_selectedTab == _BodyMetricTab.weight) {
                        _openWeightSheet();
                      } else {
                        _openHeightSheet();
                      }
                    },
              icon: const Icon(Icons.add_rounded),
              label: Text(
                _selectedTab == _BodyMetricTab.weight
                    ? 'Thêm cân nặng'
                    : 'Thêm chiều cao',
              ),
            ),
            body: Stack(
              children: [
                RefreshIndicator(
                  color: actionColor,
                  onRefresh: _refresh,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                    children: [
                      _OverviewCard(
                        heightText: _formatMetric(latestHeight?.heightCm, 'cm'),
                        weightText: _formatMetric(latestWeight?.weightKg, 'kg'),
                        bmiText: bmi == null ? '--' : bmi.toStringAsFixed(1),
                        bmiLabel: _bmiLabel(bmi),
                        heightDate: _formatDate(latestHeight?.recordedAt),
                        weightDate: _formatDate(latestWeight?.recordedAt),
                      ),
                      const SizedBox(height: 16),
                      SegmentedButton<_BodyMetricTab>(
                        style: SegmentedButton.styleFrom(
                          backgroundColor: colorScheme.surface,
                          foregroundColor: colorScheme.onSurfaceVariant,
                          selectedBackgroundColor: isDark
                              ? const Color(0xFF23443E)
                              : const Color(0xFFE5F3EF),
                          selectedForegroundColor: isDark
                              ? const Color(0xFFC6F2E6)
                              : const Color(0xFF1F6C5E),
                          side: BorderSide(
                            color: colorScheme.outlineVariant.withValues(
                              alpha: 0.42,
                            ),
                          ),
                        ),
                        segments: const [
                          ButtonSegment(
                            value: _BodyMetricTab.weight,
                            icon: Icon(Icons.monitor_weight_outlined),
                            label: Text('Cân nặng'),
                          ),
                          ButtonSegment(
                            value: _BodyMetricTab.height,
                            icon: Icon(Icons.height),
                            label: Text('Chiều cao'),
                          ),
                        ],
                        selected: {_selectedTab},
                        onSelectionChanged: (values) {
                          setState(() => _selectedTab = values.first);
                        },
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _selectedTab == _BodyMetricTab.weight
                            ? 'Lịch sử cân nặng'
                            : 'Lịch sử chiều cao',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (state.isLoading &&
                          state.heights.isEmpty &&
                          state.weights.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 80),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (_selectedTab == _BodyMetricTab.weight)
                        _WeightHistory(
                          items: state.weights,
                          formatDate: _formatDate,
                          onEdit: _openWeightSheet,
                          onDelete: _confirmDeleteWeight,
                        )
                      else
                        _HeightHistory(
                          items: state.heights,
                          formatDate: _formatDate,
                          onEdit: _openHeightSheet,
                          onDelete: _confirmDeleteHeight,
                        ),
                    ],
                  ),
                ),
                if (state.isSubmitting)
                  Positioned.fill(
                    child: ColoredBox(
                      color: Colors.black.withValues(alpha: 0.12),
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  final String heightText;
  final String weightText;
  final String bmiText;
  final String bmiLabel;
  final String heightDate;
  final String weightDate;

  const _OverviewCard({
    required this.heightText,
    required this.weightText,
    required this.bmiText,
    required this.bmiLabel,
    required this.heightDate,
    required this.weightDate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final heightColor = isDark
        ? const Color(0xFF8FD6C4)
        : const Color(0xFF2F7D6D);
    final weightColor = isDark
        ? const Color(0xFFFFC27A)
        : const Color(0xFFC86F28);
    final cardColor = isDark
        ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.26)
        : Colors.white;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : const Color(0xFFE6EEE9);
    final shadowColor = Colors.black.withValues(alpha: isDark ? 0.10 : 0.045);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _SummaryTile(
                  icon: Icons.height,
                  accentColor: heightColor,
                  label: 'Chiều cao',
                  value: heightText,
                  footer: heightDate,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SummaryTile(
                  icon: Icons.monitor_weight_outlined,
                  accentColor: weightColor,
                  label: 'Cân nặng',
                  value: weightText,
                  footer: weightDate,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(
                alpha: isDark ? 0.18 : 0.0,
              ),
              gradient: isDark
                  ? null
                  : const LinearGradient(
                      colors: [Color(0xFFEAF7F2), Color(0xFFFFF2E4)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(Icons.insights_rounded, color: heightColor),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'BMI hiện tại',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  '$bmiText  $bmiLabel',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final IconData icon;
  final Color accentColor;
  final String label;
  final String value;
  final String footer;

  const _SummaryTile({
    required this.icon,
    required this.accentColor,
    required this.label,
    required this.value,
    required this.footer,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? colorScheme.surface.withValues(alpha: 0.48)
            : const Color(0xFFFAFCFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.brightness == Brightness.dark
              ? Colors.white.withValues(alpha: 0.06)
              : const Color(0xFFE7EFEA),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 21, color: accentColor),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleLarge?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            footer,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _WeightHistory extends StatelessWidget {
  final List<UserWeightResponse> items;
  final String Function(DateTime?) formatDate;
  final ValueChanged<UserWeightResponse> onEdit;
  final ValueChanged<UserWeightResponse> onDelete;

  const _WeightHistory({
    required this.items,
    required this.formatDate,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const _EmptyHistory(message: 'Chưa có bản ghi cân nặng');
    }

    return Column(
      children: items.map((item) {
        return _HistoryTile(
          icon: Icons.monitor_weight_outlined,
          value: '${item.weightKg.toStringAsFixed(1)} kg',
          date: formatDate(item.recordedAt),
          onEdit: () => onEdit(item),
          onDelete: () => onDelete(item),
        );
      }).toList(),
    );
  }
}

class _HeightHistory extends StatelessWidget {
  final List<UserHeightResponse> items;
  final String Function(DateTime?) formatDate;
  final ValueChanged<UserHeightResponse> onEdit;
  final ValueChanged<UserHeightResponse> onDelete;

  const _HeightHistory({
    required this.items,
    required this.formatDate,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const _EmptyHistory(message: 'Chưa có bản ghi chiều cao');
    }

    return Column(
      children: items.map((item) {
        return _HistoryTile(
          icon: Icons.height,
          value: '${item.heightCm.toStringAsFixed(1)} cm',
          date: formatDate(item.recordedAt),
          onEdit: () => onEdit(item),
          onDelete: () => onDelete(item),
        );
      }).toList(),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String date;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _HistoryTile({
    required this.icon,
    required this.value,
    required this.date,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = icon == Icons.height
        ? (isDark ? const Color(0xFF8FD6C4) : const Color(0xFF2F7D6D))
        : (isDark ? const Color(0xFFFFC27A) : const Color(0xFFC86F28));

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.07)
              : const Color(0xFFE6EEE9),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.08 : 0.025),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(14, 8, 8, 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: isDark ? 0.16 : 0.11),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: accentColor),
        ),
        title: Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        subtitle: Text(date),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') onEdit();
            if (value == 'delete') onDelete();
          },
          itemBuilder: (context) => const [
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit_outlined),
                  SizedBox(width: 10),
                  Text('Sửa'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete_outline, color: Colors.red),
                  SizedBox(width: 10),
                  Text('Xóa'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  final String message;

  const _EmptyHistory({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 32),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.brightness == Brightness.dark
              ? Colors.white.withValues(alpha: 0.07)
              : const Color(0xFFE6EEE9),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.timeline_rounded,
            size: 42,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 10),
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricFormSheet extends StatefulWidget {
  final bool isHeight;
  final UserHeightResponse? heightItem;
  final UserWeightResponse? weightItem;

  const _MetricFormSheet.height({UserHeightResponse? item})
    : isHeight = true,
      heightItem = item,
      weightItem = null;

  const _MetricFormSheet.weight({UserWeightResponse? item})
    : isHeight = false,
      heightItem = null,
      weightItem = item;

  @override
  State<_MetricFormSheet> createState() => _MetricFormSheetState();
}

class _MetricFormSheetState extends State<_MetricFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _valueController;
  late DateTime _recordedAt;

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
    _recordedAt =
        widget.heightItem?.recordedAt ??
        widget.weightItem?.recordedAt ??
        DateTime.now();
  }

  @override
  void dispose() {
    _valueController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _recordedAt,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_recordedAt),
    );
    if (time == null || !mounted) return;

    setState(() {
      _recordedAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final cubit = context.read<BodyMetricsCubit>();
    final value = double.parse(_valueController.text.trim());
    final bool success;

    if (widget.isHeight) {
      final id = widget.heightItem?.id;
      success = id == null
          ? await cubit.createHeight(heightCm: value, recordedAt: _recordedAt)
          : await cubit.updateHeight(
              id: id,
              heightCm: value,
              recordedAt: _recordedAt,
            );
    } else {
      final id = widget.weightItem?.id;
      success = id == null
          ? await cubit.createWeight(weightKg: value, recordedAt: _recordedAt)
          : await cubit.updateWeight(
              id: id,
              weightKg: value,
              recordedAt: _recordedAt,
            );
    }

    if (!mounted || !success) return;
    showCustomSnackBar(
      context,
      _isEditing ? 'Đã cập nhật bản ghi' : 'Đã thêm bản ghi',
    );
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
                    title: const Text('Thời điểm ghi nhận'),
                    subtitle: Text(
                      DateFormat('dd/MM/yyyy HH:mm').format(_recordedAt),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: _pickDateTime,
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
              ],
            ),
          ),
        );
      },
    );
  }
}
