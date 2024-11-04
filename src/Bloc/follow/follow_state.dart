import 'package:equatable/equatable.dart';

class FollowState extends Equatable {
  const FollowState({this.uid = "", this.following = false});
  final bool following;
  final String uid;

  FollowState copyWith({String? uid, bool? following}) {
    return FollowState(
        uid: uid ?? this.uid, following: following ?? this.following);
  }

  @override
  List<Object> get props => [following];
}
