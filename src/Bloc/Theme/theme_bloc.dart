
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logophile/src/Bloc/Theme/theme_event.dart';
import 'package:logophile/src/Bloc/Theme/theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState>{
  ThemeBloc():super(const ThemeState()){
    on<DarkThemeEvent>((event, emit) {
      emit(state.copyWith(m : event.mode));
    },);
    on<LightThemeEvent>((event, emit) {
      emit(state.copyWith(m : event.mode));
    },);
  }
}