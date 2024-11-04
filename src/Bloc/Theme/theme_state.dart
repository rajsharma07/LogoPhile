
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class ThemeState extends Equatable{
  final ThemeMode mode;
  const ThemeState({this.mode = ThemeMode.system});
  ThemeState copyWith({ThemeMode? m}){
    return ThemeState(
      mode: m ?? ThemeMode.system
    );
  }
  @override
  List<Object> get props=>[mode];
}