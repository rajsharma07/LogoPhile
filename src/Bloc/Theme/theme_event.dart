
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class ThemeEvent extends Equatable{
  @override
  List<Object> get props=>[];
}

class DarkThemeEvent extends ThemeEvent{
  final mode = ThemeMode.dark;
}

class LightThemeEvent extends ThemeEvent{
  final mode = ThemeMode.light;
}