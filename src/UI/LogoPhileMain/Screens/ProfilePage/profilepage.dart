import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logophile/Models/user.dart' as user_model;
import 'package:logophile/src/Bloc/follow/follow_bloc.dart';
import 'package:logophile/src/Bloc/follow/follow_event.dart';
import 'package:logophile/src/Bloc/follow/follow_state.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage(
      {super.key, required this.person, this.uid, required this.iscurrentuser});
  final user_model.User person;
  final bool iscurrentuser;
  final String? uid;
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: Center(
        child: BlocProvider(
            create: (context) {
              return FollowBloc();
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(widget.person.imageId),
                    radius: 90,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Center(child: Text(widget.person.name)),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("likes: ${widget.person.likes}"),
                      const SizedBox(
                        width: 50,
                      ),
                      Text("Followers : ${widget.person.followers}")
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                BlocBuilder<FollowBloc, FollowState>(builder: (context, state) {
                  context
                      .read<FollowBloc>()
                      .add(SetUser(uid: widget.person.id));
                  return Center(
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<FollowBloc>().add(Follow());
                      },
                      child: state.following
                          ? Text(
                              "Following",
                              style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary),
                            )
                          : Text("Follow",
                              style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary)),
                    ),
                  );
                }),
                const Divider(),
                Row(
                  children: [
                    const Text(
                      "About:",
                    ),
                    const Spacer(),
                    if (widget.iscurrentuser)
                      IconButton(onPressed: () {}, icon: const Icon(Icons.edit))
                  ],
                ),
                Text(widget.person.about),
                const Divider(),
                if (widget.iscurrentuser) const Text("Liked"),
                if (widget.iscurrentuser)
                  Expanded(
                    child: ListView.builder(
                      itemCount: widget.person.liked.length,
                      itemBuilder: (context, index) {
                        return const Text("Liked");
                      },
                    ),
                  ),
                const Divider(),
                const Text("Posts:"),
                widget.person.posts.isEmpty
                    ? const Text("No Post uploaded")
                    : Expanded(
                        child: ListView.builder(
                          itemCount: widget.person.posts.length,
                          itemBuilder: (context, index) {
                            return const Text("data");
                          },
                        ),
                      )
              ],
            )),
      ),
    );
  }
}
