part of 'post_bloc.dart';

class Post extends Equatable {
  final int likes;
  final String content;
  final String username;
  final bool isLiked;
  final int id;
  Post copy({int? likes, String? content, String? username, bool? isLiked}) {
    return Post(
        likes ?? this.likes, content ?? this.content, username ?? this.username,
        isLiked: isLiked ?? this.isLiked, id: id);
  }

  const Post(this.likes, this.content, this.username,
      {this.isLiked = false, required this.id});
  @override
  List<Object?> get props => [likes, content, username, id];
}

abstract class PostState extends Equatable {
  const PostState();

  @override
  List<Object> get props => [];
}

abstract class PostStateWithData extends PostState {
  final List<Post> posts;
  const PostStateWithData(this.posts);
  @override
  List<Object> get props => [posts];
}

class PostInitial extends PostState {}

class PostLoading extends PostStateWithData {
  const PostLoading(List<Post> posts) : super(posts);
}

class PostFinished extends PostStateWithData {
  const PostFinished(List<Post> posts) : super(posts);
}

class PostLoaded extends PostStateWithData {
  const PostLoaded(List<Post> posts) : super(posts);
}

enum LoadingState { loading, loaded, fail }

class PostChanging extends PostStateWithData {
  final LoadingState state;
  final Post changingPost;
  const PostChanging(List<Post> posts, this.changingPost, this.state)
      : super(posts);
}

class PostChanged extends PostStateWithData {
  final LoadingState state;
  const PostChanged(List<Post> posts, this.state) : super(posts);
}
