import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:mindful/models/flash_card.dart';

class Test {
  Test({
    required this.name,
    required this.cards,
    this.id,
    Timestamp? createdAt,
    this.progressIndex = -1,
    this.correct = 0,
    this.finished = false
  }) : createdAt = createdAt ?? Timestamp.now();
  final String? id;
  final String name;
  final Timestamp createdAt;
  final List<FlashCard> cards;
  final int progressIndex;
  final int correct;
  final bool finished ;
}
