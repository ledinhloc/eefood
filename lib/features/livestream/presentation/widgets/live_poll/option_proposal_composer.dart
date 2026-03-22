import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/widgets/snack_bar.dart';
import '../../provider/live_poll_cubit.dart';
import '../../provider/live_poll_option_proposal_cubit.dart';
import '../../provider/live_poll_option_proposal_state.dart';

class OptionProposalComposer extends StatefulWidget {
  final int pollId;

  const OptionProposalComposer({super.key, required this.pollId});

  @override
  State<OptionProposalComposer> createState() => _OptionProposalComposerState();
}

class _OptionProposalComposerState extends State<OptionProposalComposer> {
  final TextEditingController _controller = TextEditingController();
  bool _isExpanded = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submitProposal(BuildContext context) async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final liveStreamId = context.read<LivePollCubit>().state.liveStreamId;
    if (liveStreamId == null) return;

    await context.read<LivePollOptionProposalCubit>().createOptionProposal(
      liveStreamId: liveStreamId,
      pollId: widget.pollId,
      req: text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<
      LivePollOptionProposalCubit,
      LivePollOptionProposalState
    >(
      listenWhen: (previous, current) =>
          previous.latestProposal != current.latestProposal ||
          previous.error != current.error,
      listener: (context, state) {
        if (state.latestProposal != null) {
          _controller.clear();
          setState(() {
            _isExpanded = false;
          });
          showCustomSnackBar(context, 'Đã gửi thành công');
          context.read<LivePollOptionProposalCubit>().clearLatestProposal();
          return;
        }

        if (state.error != null && state.error!.isNotEmpty) {
          final message = state.error!.contains('409')
              ? 'Gợi ý đã tồn tại'
              : state.error!;
          showCustomSnackBar(context, message, isError: true);
          context.read<LivePollOptionProposalCubit>().clearError();
        }
      },
      builder: (context, state) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF2C2C2E),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Đề xuất món ăn',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    AnimatedRotation(
                      turns: _isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: const Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _isExpanded
                    ? 'Gửi gợi ý cho Streamer'
                    : 'Nhấn vào để gửi đề xuất',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
              ),
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 200),
                crossFadeState: _isExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                firstChild: const SizedBox.shrink(),
                secondChild: Column(
                  children: [
                    const SizedBox(height: 12),
                    TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 3,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Nhập đề xuất',
                        hintStyle: const TextStyle(color: Colors.white54),
                        filled: true,
                        fillColor: const Color(0xFF1C1C1E),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.white12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.white12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.orange),
                        ),
                      ),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _submitProposal(context),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: state.actionLoading
                            ? null
                            : () => _submitProposal(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: state.actionLoading
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Gửi'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
