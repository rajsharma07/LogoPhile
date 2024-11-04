import 'package:equatable/equatable.dart';

class DraftState extends Equatable {
  final bool isSaving;
  const DraftState({this.isSaving = false});
  DraftState copywith({bool? saving}) {
    return DraftState(isSaving: saving ?? isSaving);
  }

  @override
  List<Object> get props => [isSaving];
}
