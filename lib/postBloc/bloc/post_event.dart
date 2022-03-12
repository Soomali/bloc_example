part of 'post_bloc.dart';

abstract class PostEvent extends Equatable {
  const PostEvent();
  @override
  List<Object> get props => [];
}

abstract class PostEventWithData extends PostEvent {
  final Post post;
  const PostEventWithData(this.post);
  @override
  List<Object> get props => [post];
}

class PostLiked extends PostEventWithData {
  const PostLiked(Post post) : super(post);
}

class PostDisliked extends PostEventWithData {
  const PostDisliked(Post post) : super(post);
}

class PostDeleted extends PostEventWithData {
  const PostDeleted(Post post) : super(post);
}

class PostLoad extends PostEvent {
  final List<Post> posts;
  const PostLoad(this.posts) : super();
}
