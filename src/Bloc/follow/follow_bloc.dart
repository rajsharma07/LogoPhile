import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logophile/data/currentuserdata.dart';
import 'package:logophile/src/Bloc/follow/follow_event.dart';
import 'package:logophile/src/Bloc/follow/follow_state.dart';

class FollowBloc extends Bloc<FollowEvent, FollowState> {
  FollowBloc() : super(const FollowState()) {
    on<Follow>(
      (event, emit) async {
        final userref = FirebaseDatabase.instance
            .ref("user")
            .child(state.uid)
            .child("metadata")
            .child("followers");
        final currentuserref = FirebaseDatabase.instance
            .ref("user")
            .child(currentuser.id)
            .child("private")
            .child("following");

        int i = await userref.get().then((v) {
          if (v.value == null) {
            return 0;
          }
          return v.value as int;
        });
        if (state.following) {
          await currentuserref.equalTo(state.uid).ref.remove();
          currentuser.following.remove(state.uid);
          await userref.set(i - 1);
        } else {
          await currentuserref.push().set(state.uid);
          currentuser.following.add(state.uid);
          await userref.set(i + 1);
        }
        emit(state.copyWith(uid: state.uid, following: !state.following));
      },
    );
    on<SetUser>(
      (event, emit) {
        emit(state.copyWith(uid: event.uid, following: event.isfollowing));
      },
    );
  }
}
