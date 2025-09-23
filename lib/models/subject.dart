import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mindful/models/flash_card.dart';

class Subject {
  Subject({
    required this.name,
    this.subjectCards=const[],
    Timestamp? createdAt,
  }) : createdAt = createdAt ?? Timestamp.now();

  final String name;
  final List<FlashCard> subjectCards;
  final Timestamp createdAt;
}

