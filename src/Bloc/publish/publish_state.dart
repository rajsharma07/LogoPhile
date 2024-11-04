import 'package:equatable/equatable.dart';

class PublishState extends Equatable {
  final bool publishing;
  const PublishState({this.publishing = false});
  PublishState copyWith({bool? publishing}) {
    return PublishState(publishing: publishing ?? this.publishing);
  }

  @override
  List<Object> get props => [publishing];
}
