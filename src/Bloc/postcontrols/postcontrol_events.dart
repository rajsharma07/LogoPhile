import 'package:equatable/equatable.dart';
import 'package:logophile/data/currentuserdata.dart';

abstract class PostcontrolEvents extends Equatable {
  @override
  List<Object> get props => [];
}

class LikePost extends PostcontrolEvents {
  final String ownerId;
  LikePost({required this.ownerId});
}

class AddPostId extends PostcontrolEvents {
  final String postId;
  final bool isliked;
  final bool issaved;
  AddPostId({required this.postId})
      : isliked = currentuser.liked.contains(postId),
        issaved = currentuser.saved.contains(postId);
}

class Save extends PostcontrolEvents {}
