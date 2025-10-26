import 'package:eefood/core/utils/reaction_helper.dart';
import 'package:eefood/features/post/data/models/comment_reaction_model.dart';
import 'package:eefood/features/post/data/models/reaction_type.dart';
import 'package:eefood/features/post/presentation/provider/comment_reaction_cubit.dart';
import 'package:eefood/features/post/presentation/widgets/comment/comment_reaction/comment_react_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class CommentReactListPage extends StatefulWidget {
  final int commentId;
  final Map<ReactionType, int> reactionCounts;
  const CommentReactListPage({
    super.key,
    required this.commentId,
    required this.reactionCounts,
  });

  @override
  State<CommentReactListPage> createState() => _CommentReactListPageState();
}

class _CommentReactListPageState extends State<CommentReactListPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late List<ReactionType?> _tabTypes;
  final _scrollController = ScrollController();

  bool _isInitialLoad = true;

  @override
  void initState() {
    super.initState();
    _initializeTabs();
    _scrollController.addListener(_onScroll);

    // Delay initial fetch to ensure cubit is properly initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchInitialData();
    });
  }

  void _initializeTabs() {
    final activeReactions = widget.reactionCounts.entries
        .where((e) => e.value > 0)
        .map((e) => e.key)
        .toList();

    _tabTypes = [null, ...activeReactions];
    _tabController = TabController(length: _tabTypes.length, vsync: this);
  }

  void _fetchInitialData() {
    final cubit = context.read<CommentReactionCubit>();
    print('Fetching initial data for comment: ${widget.commentId}');
    cubit.fetchReactions(widget.commentId);
    _isInitialLoad = false;
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      final cubit = context.read<CommentReactionCubit>();
      if (!cubit.state.isLoading && cubit.state.hasMore) {
        cubit.fetchReactions(widget.commentId, loadMore: true);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100), // tăng nhẹ tổng chiều cao
        child: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back),
          ),
          automaticallyImplyLeading: false,
          elevation: 0,
          backgroundColor: Colors.white,
          flexibleSpace: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text(
                    'Người đã bày tỏ cảm xúc',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildTabBar(),
                ],
              ),
            ),
          ),
        ),
      ),
      body: BlocConsumer<CommentReactionCubit, CommentReactionState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Lỗi: ${state.errorMessage}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          print(
            'CommentReactListPage state: ${state.reactions.length} reactions, loading: ${state.isLoading}, error: ${state.errorMessage}',
          );

          if (_isInitialLoad && state.reactions.isEmpty) {
            return const Center(child: SpinKitCircle(color: Colors.orange));
          }

          if (state.errorMessage != null && state.reactions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Lỗi: ${state.errorMessage}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _fetchInitialData(),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          final allReactions = state.reactions;

          return TabBarView(
            controller: _tabController,
            children: _tabTypes.map((type) {
              final filtered = type == null
                  ? allReactions
                  : allReactions.where((r) => r.reactionType == type).toList();

              return _buildReactionList(filtered, state);
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _buildReactionList(
    List<CommentReactionModel> reactions,
    CommentReactionState state,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        final cubit = context.read<CommentReactionCubit>();
        await cubit.fetchReactions(widget.commentId);
      },
      child: ListView.builder(
        controller: _scrollController,
        itemCount:
            reactions.length +
            (state.isLoading && reactions.isNotEmpty ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= reactions.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return CommentReactItem(commentReactionModel: reactions[index]);
        },
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicatorColor: Colors.blue,
        labelColor: Colors.blue,
        unselectedLabelColor: Colors.grey.shade600,
        tabs: _tabTypes.map((type) {
          if (type == null) {
            final totalCount = widget.reactionCounts.values.fold<int>(
              0,
              (sum, v) => sum + v,
            );
            return Tab(
              child: Row(
                children: [
                  const Text('Tất cả'),
                  const SizedBox(width: 4),
                  Text(
                    totalCount.toString(),
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            );
          } else {
            return Tab(
              child: Row(
                children: [
                  Text(
                    ReactionHelper.emoji(type),
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    widget.reactionCounts[type].toString(),
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            );
          }
        }).toList(),
      ),
    );
  }
}
