import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mindful/models/flash_card.dart';
import 'package:mindful/models/subject.dart';
import 'package:mindful/models/test.dart';

final user = FirebaseAuth.instance.currentUser;
final store = FirebaseFirestore.instance;

class SubjectsNotifier extends StateNotifier<List<Subject>> {
  SubjectsNotifier() : super([]);
  Future<void> initializeSubjcts() async {
    final userDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid);
    final subjectsSnapshot = await userDoc.collection('subjects').get();
    final subjects = await Future.wait(
      subjectsSnapshot.docs.map(
        (e) async {
          final subjectName = e.id;
          final Timestamp subjectCreatedAt = e['created at'];
          final cardsSnap = await userDoc
              .collection('subjects')
              .doc(e.id)
              .collection('flashcards')
              .get();
          final cards = cardsSnap.docs.map(
            (e) {
              final data = e.data();
              return FlashCard(
                question: data['question'],
                answer: data['answer'],
                id: e.id,
              );
            },
          ).toList();
          return Subject(
            name: subjectName,
            createdAt: subjectCreatedAt,
            subjectCards: cards,
          );
        },
      ).toList(),
    );
    state = subjects;
  }

  void addCardsWhenNeeded(String subjectName, List<FlashCard> cards) {
    state = state.map((subject) {
      if (subject.name == subjectName) {
        return Subject(
          name: subject.name,
          createdAt: subject.createdAt,
          subjectCards: cards,
        );
      }
      return subject;
    }).toList();
  }

  Future<void> addSubject(Subject subject) async {
    final userDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid);
    final subjectDoc = userDoc.collection('subjects').doc(subject.name);

    // Save subject metadata
    await subjectDoc.set({'created at': subject.createdAt});

    final cardsCollection = subjectDoc.collection('flashcards');

    // Save all cards properly and wait for them

    await Future.wait(
      subject.subjectCards.map((e) {
        return cardsCollection.add({
          'question': e.question,
          'answer': e.answer,
        });
      }),
    );

    state = [...state, subject];
  }

  Future<void> deleteSubject(Subject subject) async {
    final userDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid);
    final subjectDoc = userDoc.collection('subjects').doc(subject.name);
    final cardsRef = subjectDoc.collection('flashcards');

    // Get all flashcard documents
    final cardsSnapshot = await cardsRef.get();

    await Future.wait(
      cardsSnapshot.docs.map((doc) => cardsRef.doc(doc.id).delete()),
    );

    // Delete the subject document itself
    await subjectDoc.delete();

    // Update local state by removing the deleted subject
    state = state.where((s) => s.name != subject.name).toList();
  }

  void addCardToSubject(String subjectName, FlashCard card) {
    state = state.map((subject) {
      if (subject.name == subjectName) {
        return Subject(
          name: subject.name,
          createdAt: subject.createdAt,
          subjectCards: [...subject.subjectCards, card],
        );
      }
      return subject;
    }).toList();
  }

  void deleteCardFromSubject(String subjectName, String cardId) {
    state = state.map((subject) {
      if (subject.name == subjectName) {
        final updatedCards = subject.subjectCards
            .where((card) => card.id != cardId)
            .toList();

        return Subject(
          name: subject.name,
          createdAt: subject.createdAt,
          subjectCards: updatedCards,
        );
      }
      return subject;
    }).toList();
  }

  void editCardInSubject(String subjectName, FlashCard updatedCard) {
    state = state.map((subject) {
      if (subject.name == subjectName) {
        final updatedCards = subject.subjectCards.map((card) {
          if (card.id == updatedCard.id) {
            return updatedCard; // replace with new card
          }
          return card;
        }).toList();

        return Subject(
          name: subject.name,
          createdAt: subject.createdAt,
          subjectCards: updatedCards,
        );
      }
      return subject;
    }).toList();
  }

  Future<void> editSubject(Subject subject, String newName) async {
    final newSubject = Subject(
      name: newName,
      createdAt: subject.createdAt,
      subjectCards: subject.subjectCards,
    );

    await deleteSubject(subject);
    await addSubject(newSubject);
  }
}

final subjectProvider = StateNotifierProvider<SubjectsNotifier, List<Subject>>(
  (ref) {
    return SubjectsNotifier();
  },
);

class CardsNotifier extends StateNotifier<List<FlashCard>> {
  final Ref _ref;
  CardsNotifier(this._ref) : super([]);
  Future<void> fetchCards(Subject subject) async {
    final userDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid);
    final subjectDoc = userDoc.collection('subjects').doc(subject.name);
    final cardsSnapshot = await subjectDoc.collection('flashcards').get();

    final cards = cardsSnapshot.docs.map((doc) {
      final data = doc.data();
      return FlashCard(
        id: doc.id,
        question: data['question'],
        answer: data['answer'],
      );
    }).toList();

    state = cards;
    _ref.read(subjectProvider.notifier).addCardsWhenNeeded(subject.name, state);
  }

  Future<void> addCard(Subject subject, FlashCard card) async {
    final userDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid);
    final subjectDoc = userDoc.collection('subjects').doc(subject.name);
    final cardCollectionRef = subjectDoc.collection('flashcards');

    final cardDoc = await cardCollectionRef.add({
      'question': card.question,
      'answer': card.answer,
    });
    final newCard = FlashCard(
      question: card.question,
      answer: card.answer,
      id: cardDoc.id,
    );
    state = [
      ...state,
      newCard,
    ];
    _ref.read(subjectProvider.notifier).addCardToSubject(subject.name, newCard);
  }

  Future<void> deleteCard(Subject subject, FlashCard card) async {
    final userDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid);
    final subjectDoc = userDoc.collection('subjects').doc(subject.name);
    final cardCollectionRef = subjectDoc.collection('flashcards');
    await cardCollectionRef.doc(card.id).delete();
    state = state
        .where(
          (element) => element.id != card.id,
        )
        .toList();
    _ref
        .read(subjectProvider.notifier)
        .deleteCardFromSubject(subject.name, card.id!);
  }

  Future<void> editCard(
    Subject subject,
    FlashCard card,
    String newQuestion,
    String newAnswer,
  ) async {
    final userDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid);
    final subjectDoc = userDoc.collection('subjects').doc(subject.name);

    await subjectDoc.collection('flashcards').doc(card.id).update({
      'question': newQuestion,
      'answer': newAnswer,
    });
    final updatedCard = FlashCard(
      id: card.id,
      question: newQuestion,
      answer: newAnswer,
    );

    state = state.map((c) {
      if (c.id == card.id) {
        return updatedCard;
      }
      return c;
    }).toList();
    _ref
        .read(subjectProvider.notifier)
        .editCardInSubject(subject.name, updatedCard);
  }
}

final cardProvider = StateNotifierProvider<CardsNotifier, List<FlashCard>>(
  (ref) => CardsNotifier(ref),
);

class TestsNotifier extends StateNotifier<List<Test>> {
  TestsNotifier() : super([]);
  Future<void> fetchTests() async {
    final userDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid);
    final testsCollectionRef = userDoc.collection('Tests');

    final testsSnapShot = await testsCollectionRef.get();
    final tests = await Future.wait(
      testsSnapShot.docs.map(
        (doc) async {
          final testData = doc.data();
          final cardsSnapshot = await testsCollectionRef
              .doc(doc.id)
              .collection('flashcards')
              .get();
          final cards = cardsSnapshot.docs.map(
            (doc) {
              final cardData = doc.data();
              return FlashCard(
                question: cardData['question'],
                answer: cardData['answer'],
                id: doc.id,
              );
            },
          ).toList();
          return Test(
            name: testData['name'],
            createdAt: testData['created at'],
            progressIndex: testData['progress index'],
            id: doc.id,
            cards: cards,
            correct: testData['correct'],
          );
        },
      ).toList(),
    );
    state = tests;
  }

  Future<void> addTest(Test test) async {
    final userDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid);
    final testsCollectionRef = userDoc.collection('Tests');

    final testDoc = await testsCollectionRef.add({
      'name': test.name,
      'created at': test.createdAt,
      'progress index': test.progressIndex,
      'correct': test.correct,
      'finished': test.finished,
    });
    final cardsSnapshot = testsCollectionRef
        .doc(testDoc.id)
        .collection('flashcards');
    await Future.wait(
      test.cards.map((card) async {
        cardsSnapshot.add({'question': card.question, 'answer': card.answer});
      }),
    );
    state = [...state, test];
  }

  Future<void> editTest(Test test) async {
    final userDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid);
    final testsCollectionRef = userDoc.collection('Tests');
    await testsCollectionRef.doc(test.id).update({
      'progress index': test.progressIndex,
      'correct': test.correct,
      'name': test.name,
      'finished': test.finished
    });
    final updatedTest = Test(
      id: test.id,
      name: test.name,
      createdAt: test.createdAt,
      progressIndex: test.progressIndex,
      correct: test.correct,
      cards: test.cards,
      finished: test.finished,
    );
    state = state.map((t) {
      if (t.id == test.id) {
        return updatedTest;
      }
      return t;
    }).toList();
  }

  Future<void> deleteTest(Test test) async {
    final userDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid);
    final testsCollectionRef = userDoc.collection('Tests');
    final cardsSnapshot = testsCollectionRef
        .doc(test.id)
        .collection('flashcards');
    await Future.wait(
      test.cards.map((card) async {
        await cardsSnapshot.doc(card.id).delete();
      }),
    );
    await testsCollectionRef.doc(test.id).delete();
    state = state.where((t) {
      return t.id != test.id;
    }).toList();
  }
}

final testsProvider = StateNotifierProvider<TestsNotifier, List<Test>>(
  (ref) => TestsNotifier(),
);
