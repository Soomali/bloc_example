import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'dart:math';
part 'post_event.dart';
part 'post_state.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  PostBloc() : super(PostInitial()) {
    on<PostDeleted>(_onPostDeleted);
    on<PostDisliked>(_onPostDisliked);
    on<PostLiked>(_onPostLiked);
    on<PostLoad>(_onPostLoad);
  }
  var _lastPostId = 0;
  void _onPostLoad(PostLoad event, Emitter<PostState> emit) async {
    final posts = event.posts;
    if (_lastPostId >= 100) {
      emit(PostFinished(posts));
    }
    emit(PostLoading(posts));
    await Future.delayed(const Duration(seconds: 5));
    final modifiablePosts = state is PostStateWithData
        ? (state as PostStateWithData).posts.toList()
        : event.posts;

    modifiablePosts.addAll(List.generate(
        10, (index) => Post(_lastPostId, "Naber", "BEN", id: ++_lastPostId)));

    emit(PostLoaded(modifiablePosts));
  }

  void _onPostLiked(PostLiked event, Emitter<PostState> emit) async {
    final changedPost = event.post;
    final post = changedPost.copy(likes: event.post.likes + 1, isLiked: true);
    final posts = (state as PostStateWithData).posts.toList();
    posts.findReplace(changedPost, post);
    emit(PostChanging(posts, event.post,
        state is PostLoading ? LoadingState.loading : LoadingState.loaded));
    await Future.delayed(const Duration(milliseconds: 500));
    emit(PostChanged((state as PostStateWithData).posts,
        state is PostLoading ? LoadingState.loading : LoadingState.loaded));
  }

  void _onPostDisliked(PostDisliked event, Emitter<PostState> emit) async {
    final changedPost = event.post;
    final post = changedPost.copy(likes: event.post.likes - 1, isLiked: false);
    final posts = (state as PostStateWithData).posts.toList();
    final index = posts.indexOf(changedPost);
    if (index != -1) {
      posts[index] = post;
    }
    emit(PostChanging(posts, event.post,
        state is PostLoading ? LoadingState.loading : LoadingState.loaded));
    await Future.delayed(const Duration(milliseconds: 1000));

    emit(PostChanged((state as PostStateWithData).posts,
        state is PostLoading ? LoadingState.loading : LoadingState.loaded));
  }

  void _onPostDeleted(PostDeleted event, Emitter<PostState> emit) async {
    if (state is! PostStateWithData) return;
    final postData = (state as PostStateWithData).posts.toList();
    emit(PostChanging(postData, event.post,
        state is PostLoading ? LoadingState.loading : LoadingState.loaded));
    postData.remove(event.post);
    await Future.delayed(const Duration(milliseconds: 2000));
    emit(PostChanged(postData,
        state is PostLoading ? LoadingState.loading : LoadingState.loaded));
  }
}

extension ListExtension<T> on List<T> {
  void findReplace(T found, T replace) {
    final index = indexOf(found);
    if (index == -1) return;
    this[index] = replace;
  }
}
