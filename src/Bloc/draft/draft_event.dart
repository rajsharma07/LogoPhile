import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:logophile/Models/book.dart';

abstract class DraftEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class SaveArticle extends DraftEvent {
  final String title;
  final String description;
  final String contentId;
  final String imageUrl;
  final String content;
  final int type = 0;
  final List<String> tags;
  final BuildContext ctx;
  SaveArticle(
      {required this.ctx,
      required this.title,
      required this.description,
      required this.contentId,
      required this.content,
      required this.imageUrl,
      required this.tags});
}

class SaveBook extends DraftEvent {
  final String title;
  final int type = 1;
  final String contentId;
  final String description;
  final String imageUrl;
  final List<String> tags;
  final List<Chapter> chapters;
  final BuildContext ctx;
  SaveBook(
      {required this.ctx,
      required this.title,
      required this.description,
      required this.contentId,
      required this.imageUrl,
      required this.tags,
      required this.chapters});
}
