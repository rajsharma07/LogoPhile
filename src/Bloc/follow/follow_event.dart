import 'package:equatable/equatable.dart';
import 'package:logophile/data/currentuserdata.dart';

abstract class FollowEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class Follow extends FollowEvent {}

class SetUser extends FollowEvent {
  final String uid;
  final bool isfollowing;
  SetUser({required this.uid})
      : isfollowing = currentuser.following.contains(uid);
}
