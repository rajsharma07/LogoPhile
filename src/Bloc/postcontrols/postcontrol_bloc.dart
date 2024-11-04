import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logophile/data/currentuserdata.dart';
import 'package:logophile/src/Bloc/postcontrols/postcontrol_events.dart';
import 'package:logophile/src/Bloc/postcontrols/postcontrol_state.dart';

class PostcontrolBloc extends Bloc<PostcontrolEvents, PostState> {
  PostcontrolBloc() : super(const PostState()) {
    on<LikePost>(likepost);
    on<AddPostId>(
      (event, emit) {
        emit(state.copyWith(
          postid: event.postId,
          liked: event.isliked,
          saved: event.issaved,
        ));
      },
    );
    on<Save>(savepost);
  }

  void likepost(LikePost event, emit) async {
    emit(state.copyWith(isloading: true));
    final dbref = FirebaseDatabase.instance
        .ref("content")
        .child(state.postid)
        .child("likes");
    int i = await dbref.get().then(
      (value) {
        if (value.value == null) {
          return 0;
        }
        return value.value as int;
      },
    );
    i = state.liked ? i - 1 : i + 1;
    await dbref.set(i);
    final likes = FirebaseDatabase.instance
        .ref("user")
        .child(event.ownerId)
        .child("metadata")
        .child("likes");
    int l = await likes.get().then((value) {
      if (value.value == null) {
        return 0;
      }
      return value.value as int;
    });
    l = state.liked ? l - 1 : l + 1;
    await likes.set(l);
    if (state.liked) {
      await FirebaseDatabase.instance
          .ref("user")
          .child(currentuser.id)
          .child("private")
          .child("liked")
          .equalTo(state.postid)
          .ref
          .remove();
      currentuser.liked.remove(state.postid);
    } else {
      await FirebaseDatabase.instance
          .ref("user")
          .child(currentuser.id)
          .child("private")
          .child("liked")
          .push()
          .set(state.postid);
      currentuser.liked.add(state.postid);
    }
    emit(state.copyWith(
        postid: state.postid, liked: !state.liked, isloading: false));
  }

  void savepost(PostcontrolEvents event, emit) async {
    emit(state.copyWith(isloading: true));
    final dbref = FirebaseDatabase.instance
        .ref("user")
        .child(currentuser.id)
        .child("private")
        .child("saved");
    if (state.saved) {
      await dbref.equalTo(state.postid).ref.remove();
      emit(state.copyWith(saved: false, isloading: false));
      currentuser.saved.remove(state.postid);
    } else {
      await dbref.push().set(state.postid);
      emit(state.copyWith(saved: true, isloading: false));
      currentuser.saved.add(state.postid);
    }
  }
}
