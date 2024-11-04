import 'package:equatable/equatable.dart';

class PostState extends Equatable {
  final String postid;
  final bool liked;
  final bool saved;
  final bool isloading;
  const PostState(
      {this.postid = "",
      this.liked = false,
      this.saved = false,
      this.isloading = false});
  PostState copyWith({postid, liked, saved, isloading}) {
    return PostState(
        postid: postid ?? this.postid,
        liked: liked ?? this.liked,
        saved: saved ?? this.saved,
        isloading: isloading ?? this.isloading);
  }

  @override
  List<Object> get props => [liked, saved, isloading];
}
