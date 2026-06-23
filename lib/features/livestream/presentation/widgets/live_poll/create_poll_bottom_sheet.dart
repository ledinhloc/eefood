import 'package:eefood/core/widgets/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/model/create_live_poll_request.dart';
import '../../../domain/enum/poll_option_add_mode.dart';
import '../../../domain/enum/poll_result_visibility.dart';
import '../../../domain/enum/poll_voter_visibility.dart';
import '../../provider/live_poll_cubit.dart';
import '../../provider/live_poll_state.dart';

class CreatePollBottomSheet extends StatefulWidget {
  const CreatePollBottomSheet({super.key});

  @override
  State<CreatePollBottomSheet> createState() => _CreatePollBottomSheetState();
}

class _CreatePollBottomSheetState extends State<CreatePollBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _questionController = TextEditingController();

  final List<TextEditingController> _optionControllers = [
    TextEditingController(),
    TextEditingController(),
  ];

  bool _allowChangeVote = false;
  bool _multipleChoice = false;
  int _maxChoices = 1;
  PollResultVisibility _resultVisibility = PollResultVisibility.afterClose;
  PollVoterVisibility _voterVisibility = PollVoterVisibility.anonymous;
  PollOptionAddMode _optionAddMode = PollOptionAddMode.hostOnly;

  @override
  void dispose() {
    _questionController.dispose();
    for (final controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addOption() {
    if (_optionControllers.length >= 6) return;

    setState(() {
      _optionControllers.add(TextEditingController());
    });
  }

  void _removeOption(int index) {
    if (_optionControllers.length <= 2) return;

    setState(() {
      _optionControllers[index].dispose();
      _optionControllers.removeAt(index);

      if (_maxChoices > _optionControllers.length) {
        _maxChoices = _optionControllers.length;
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final options = _optionControllers
        .map((e) => e.text.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    if (options.length < 2) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Cần ít nhất 2 đáp án')));
      return;
    }

    if (_multipleChoice && _maxChoices < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nếu chọn nhiều thì số lựa chọn tối đa phải từ 2'),
        ),
      );
      return;
    }

    final request = CreateLivePollRequest(
      question: _questionController.text.trim(),
      options: options,
      allowChangeVote: _allowChangeVote,
      multipleChoice: _multipleChoice,
      maxChoices: _multipleChoice ? _maxChoices : 1,
      resultVisibility: _resultVisibility,
      voterVisibility: _voterVisibility,
      optionAddMode: _optionAddMode,
    );

    await context.read<LivePollCubit>().createPoll(request: request);

    if (!mounted) return;

    final pollState = context.read<LivePollCubit>().state;
    if (pollState.error == null) {
      Navigator.pop(context);
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text('Tạo poll thành công')),
      // );
      showCustomSnackBar(context, 'Tạo poll thành công');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return BlocBuilder<LivePollCubit, LivePollState>(
      builder: (context, state) {
        return Container(
          padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + bottomInset),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF3A251E), Color(0xFF2A1E1A), Color(0xFF1C1715)],
            ),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 42,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Color(0xFFA98C7D),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Tạo poll',
                      style: TextStyle(
                        color: Color(0xFFFFF7EF),
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),

                    _buildLabel('Câu hỏi'),
                    _buildTextField(
                      controller: _questionController,
                      hint: 'Live này nên nấu nguyên liệu gì?',
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vui lòng nhập câu hỏi';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 12),
                    _buildLabel('Đáp án'),

                    ...List.generate(_optionControllers.length, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                controller: _optionControllers[index],
                                hint: switch (index) {
                                  0 => 'Cá',
                                  1 => 'Tôm',
                                  _ => 'Đáp án ${index + 1}',
                                },
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Không được để trống';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (_optionControllers.length > 2)
                              IconButton(
                                onPressed: () => _removeOption(index),
                                icon: const Icon(
                                  Icons.close,
                                  color: Color(0xFFC7B1A6),
                                ),
                              ),
                          ],
                        ),
                      );
                    }),

                    TextButton.icon(
                      onPressed: _addOption,
                      icon: const Icon(Icons.add, color: Color(0xFFF2BC78)),
                      label: const Text(
                        'Thêm đáp án',
                        style: TextStyle(
                          color: Color(0xFFF2BC78),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    const SizedBox(height: 4),

                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      activeColor: const Color(0xFFF8C98D),
                      activeTrackColor: const Color(0xFFC9783C),
                      inactiveThumbColor: const Color(0xFFD8C5BA),
                      inactiveTrackColor: const Color(0xFF625049),
                      value: _multipleChoice,
                      onChanged: (value) {
                        setState(() {
                          _multipleChoice = value;
                          if (!_multipleChoice) {
                            _maxChoices = 1;
                          } else if (_maxChoices < 2) {
                            _maxChoices = 2;
                          }
                        });
                      },
                      title: const Text(
                        'Cho phép chọn nhiều đáp án',
                        style: TextStyle(color: Color(0xFFFFF7EF)),
                      ),
                    ),

                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      activeColor: const Color(0xFFF8C98D),
                      activeTrackColor: const Color(0xFFC9783C),
                      inactiveThumbColor: const Color(0xFFD8C5BA),
                      inactiveTrackColor: const Color(0xFF625049),
                      value: _allowChangeVote,
                      onChanged: (value) {
                        setState(() {
                          _allowChangeVote = value;
                        });
                      },
                      title: const Text(
                        'Cho phép đổi lựa chọn',
                        style: TextStyle(color: Color(0xFFFFF7EF)),
                      ),
                    ),

                    if (_multipleChoice) ...[
                      const SizedBox(height: 8),
                      _buildLabel('Số lựa chọn tối đa'),
                      DropdownButtonFormField<int>(
                        value: _maxChoices.clamp(2, _optionControllers.length),
                        dropdownColor: const Color(0xFF352723),
                        style: const TextStyle(color: Color(0xFFFFF7EF)),
                        decoration: _dropdownDecoration(),
                        items:
                            List.generate(
                                  _optionControllers.length - 1,
                                  (index) => index + 2,
                                )
                                .map(
                                  (e) => DropdownMenuItem<int>(
                                    value: e,
                                    child: Text('$e đáp án'),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() {
                            _maxChoices = value;
                          });
                        },
                      ),
                    ],

                    const SizedBox(height: 8),
                    _buildLabel('Hiển thị kết quả'),
                    DropdownButtonFormField<PollResultVisibility>(
                      value: _resultVisibility,
                      dropdownColor: const Color(0xFF352723),
                      style: const TextStyle(color: Color(0xFFFFF7EF)),
                      decoration: _dropdownDecoration(),
                      items: PollResultVisibility.values
                          .map(
                            (visibility) => DropdownMenuItem(
                              value: visibility,
                              child: Text(visibility.text),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          _resultVisibility = value;
                        });
                      },
                    ),

                    const SizedBox(height: 8),
                    _buildLabel('Hiển thị người vote'),
                    DropdownButtonFormField<PollVoterVisibility>(
                      value: _voterVisibility,
                      dropdownColor: const Color(0xFF352723),
                      style: const TextStyle(color: Color(0xFFFFF7EF)),
                      decoration: _dropdownDecoration(),
                      items: PollVoterVisibility.values
                          .map(
                            (visibility) => DropdownMenuItem(
                              value: visibility,
                              child: Text(visibility.text),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          _voterVisibility = value;
                        });
                      },
                    ),

                    const SizedBox(height: 8),
                    _buildLabel('Quyền thêm đáp án'),
                    DropdownButtonFormField<PollOptionAddMode>(
                      value: _optionAddMode,
                      dropdownColor: const Color(0xFF352723),
                      style: const TextStyle(color: Color(0xFFFFF7EF)),
                      decoration: _dropdownDecoration(),
                      items: PollOptionAddMode.values
                          .map(
                            (mode) => DropdownMenuItem(
                              value: mode,
                              child: Text(mode.text),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          _optionAddMode = value;
                        });
                      },
                    ),

                    if (state.error != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        state.error!,
                        style: const TextStyle(color: Color(0xFFFF8178)),
                      ),
                    ],

                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: state.actionLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD98645),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: const Color(0xFF76513D),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        child: state.actionLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Tạo poll'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFFE1CEC3),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      cursorColor: const Color(0xFFF2BC78),
      style: const TextStyle(color: Color(0xFFFFF7EF)),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFB5A097)),
        filled: true,
        fillColor: const Color(0xFF352723),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF60483D)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF60483D)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFF2BC78), width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFF8178)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFF8178), width: 1.4),
        ),
        errorStyle: const TextStyle(color: Color(0xFFFF8178)),
      ),
    );
  }

  InputDecoration _dropdownDecoration() {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      filled: true,
      fillColor: const Color(0xFF352723),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF60483D)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF60483D)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFF2BC78), width: 1.4),
      ),
    );
  }
}
