import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math';

import 'package:learning/postBloc/bloc/post_bloc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
            primarySwatch: Colors.blue,
            scaffoldBackgroundColor: Colors.deepPurpleAccent.shade400),
        home:
            const SafeArea(child: Scaffold(body: Center(child: PostLoader()))));
  }
}

class PostLoader extends StatelessWidget {
  const PostLoader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PostBloc>(
      create: (_) => PostBloc(),
      child: const PostBuilder(),
    );
  }
}

class PostBuilder extends StatelessWidget {
  const PostBuilder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PostBloc, PostState>(buildWhen: (previous, next) {
      final initialLoad = previous is PostInitial && next is PostLoading;
      //final changing = next is! PostChanging && next is! PostChanged;
      return !initialLoad;
    }, builder: (context, state) {
      if (state is PostInitial) {
        context.read<PostBloc>().add(const PostLoad([]));
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      final List<Post> posts = state is PostStateWithData ? state.posts : [];
      late final int count;
      late final Widget? endWidget;
      late final Post? changingPost;
      if (state is PostLoading) {
        count = posts.length + 1;
        endWidget = const Center(child: CircularProgressIndicator());
        changingPost = null;
      } else if (state is PostChanging) {
        count = posts.length;
        endWidget = state.state == LoadingState.loading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : null;
        changingPost = state.changingPost;
      } else if (state is PostFinished) {
        count = posts.length + 1;
        endWidget = Center(
            child: Text(
          "no more posts",
          style: Theme.of(context).textTheme.headline2,
        ));
        changingPost = null;
      } else {
        changingPost = null;
        count = posts.length;
        endWidget = null;
      }
      return PostListBuilder(
          count: count,
          endWidget: endWidget,
          posts: posts,
          changingPost: changingPost);
    });
  }
}

class PostListBuilder extends StatefulWidget {
  const PostListBuilder({
    Key? key,
    required this.count,
    required this.endWidget,
    required this.posts,
    required this.changingPost,
  }) : super(key: key);

  final int count;
  final Widget? endWidget;
  final List<Post> posts;
  final Post? changingPost;

  @override
  State<PostListBuilder> createState() => _PostListBuilderState();
}

class _PostListBuilderState extends State<PostListBuilder> {
  void _listenForLoading(ScrollController controller, PostBloc bloc) {
    if (bloc.state is PostFinished) {
      controller.removeListener(() => _listenForLoading(controller, bloc));
      return;
    }
    if (controller.position.atEdge &&
        controller.position.pixels != controller.position.minScrollExtent &&
        bloc.state is! PostLoading) {
      bloc.add(PostLoad(bloc.state is PostStateWithData
          ? (bloc.state as PostStateWithData).posts
          : []));
    }
  }

  final controller = ScrollController();
  @override
  void initState() {
    super.initState();
    final bloc = context.read<PostBloc>();
    controller.addListener(() => _listenForLoading(controller, bloc));
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      controller: controller,
      separatorBuilder: (context, index) {
        return Container(
          height: 20,
        );
      },
      itemCount: widget.count,
      itemBuilder: (context, index) {
        if (widget.endWidget != null && index == widget.count - 1) {
          return widget.endWidget!;
        }
        final post = widget.posts[index];
        final isChanging = post == widget.changingPost;
        return PostWidget(post: post, isChanging: isChanging);
      },
    );
  }
}

class PostWidget extends StatelessWidget {
  const PostWidget({
    Key? key,
    required this.post,
    required this.isChanging,
  }) : super(key: key);

  final Post post;
  final bool isChanging;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: () {
        context.read<PostBloc>().add(PostDeleted(post));
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: const [
            BoxShadow(
                color: Colors.black54,
                offset: Offset(0, 2),
                blurRadius: 1.0,
                spreadRadius: 2.0),
            BoxShadow(
                color: Colors.black54,
                offset: Offset(0, -2),
                blurRadius: 1.0,
                spreadRadius: 2.0)
          ],
          border: Border.all(color: Colors.black87, width: 1.8),
        ),
        child: Column(
          children: [
            Text(post.username),
            Row(
              children: [
                Expanded(child: Text(post.content)),
                TextButton.icon(
                    onPressed: () {
                      if (!isChanging) {
                        context.read<PostBloc>().add(post.isLiked
                            ? PostDisliked(post)
                            : PostLiked(post));
                      }
                    },
                    icon: post.isLiked
                        ? const Icon(Icons.work_outlined)
                        : const Icon(Icons.work_outline),
                    label: Text('changing:$isChanging,Likes:${post.likes}'))
              ],
            )
          ],
        ),
      ),
    );
  }
}
