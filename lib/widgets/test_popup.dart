import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mindful/models/flash_card.dart';

import 'package:mindful/models/test.dart';
import 'package:mindful/providors/subject.dart';

class TestPopup extends ConsumerStatefulWidget {
  const TestPopup({super.key, required this.test});
  final Test test;
  @override
  ConsumerState<TestPopup> createState() => _TestPopupState();
}

class _TestPopupState extends ConsumerState<TestPopup> {
  late List<FlashCard> cards;
  late int index;
  bool shown = false;
  late int correct;
  @override
  void initState() {
    super.initState();
    cards = widget.test.cards;
    if (widget.test.progressIndex == -1) {
      index = 0;
    } else {
      index = widget.test.progressIndex;
    }
    correct = widget.test.correct;
  }

  void saveTest(Test test) async {
    await ref.read(testsProvider.notifier).editTest(test);
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> conent = shown
        ? [
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () {
                setState(() {
                  shown = false;

                  index += 1;
                });
              },
              child: const Text(
                'Wrong',
              ),
            ),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              onPressed: () {
                setState(() {
                  correct += 1;
                  shown = false;

                  index += 1;
                });
              },
              child: const Text(
                'Correct',
              ),
            ),
          ]
        : [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    shown = true;
                  });
                },
                child: const Text('Show Answer'),
              ),
            ),
          ];

    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          IconButton(
            onPressed: () {
              if (index == cards.length) {
                saveTest(
                  Test(
                    id: widget.test.id,
                    name: widget.test.name,
                    createdAt: widget.test.createdAt,
                    progressIndex: index - 1,
                    correct: correct,
                    cards: widget.test.cards,
                    finished: true,
                  ),
                );
              } else {
                saveTest(
                  Test(
                    id: widget.test.id,
                    name: widget.test.name,
                    createdAt: widget.test.createdAt,
                    progressIndex: index,
                    correct: correct,
                    cards: widget.test.cards,
                  ),
                );
              }

              Navigator.pop(context);
            },
            icon: const Icon(color: Colors.red, Icons.close),
          ),
          const SizedBox(
            width: 20,
          ),
          Expanded(
            child: Text(
              widget.test.name,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),

      content: Container(
        constraints: const BoxConstraints(maxWidth: 300, maxHeight: 400),
        padding: const EdgeInsets.all(16),
        child: index == cards.length
            ? Center(
                child: Text(
                  'Result: $correct out of ${cards.length}',
                  textAlign: TextAlign.center,
                ),
              )
            : Column(
                spacing: 20,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    width: double.infinity,
                    height: 100,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(
                            25,
                          ), // Soft shadow color
                          blurRadius: 12,
                          spreadRadius: 2,
                          offset: const Offset(0, 6), // Slight vertical drop
                        ),
                      ],
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.secondaryFixed.withAlpha(255),
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Q: ${cards[index].question}',
                      softWrap: true,
                      textAlign: TextAlign.left,
                      overflow: TextOverflow.clip,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  Visibility(
                    maintainAnimation: true,
                    maintainState: true,
                    maintainSize: true,
                    visible: shown,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      width: double.infinity,
                      height: 100,
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(
                              25,
                            ), // Soft shadow color
                            blurRadius: 12,
                            spreadRadius: 2,
                            offset: const Offset(0, 6), // Slight vertical drop
                          ),
                        ],
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).colorScheme.secondaryFixed.withAlpha(255),
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Ans: ${cards[index].answer}',
                        softWrap: true,
                        textAlign: TextAlign.left,
                        overflow: TextOverflow.clip,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: conent,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(
                        begin: 0.0,
                        end: (index + 1) / cards.length,
                      ),
                      duration: const Duration(
                        milliseconds: 500,
                      ), // animation speed
                      curve: Curves.easeInOut, // makes it smoother
                      builder: (context, value, _) {
                        return LinearProgressIndicator(
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                          value: value,
                        );
                      },
                    ),
                  ),

                  Text(
                    '${index + 1}/${cards.length}',
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.secondary,
                      fontSize: 10,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
      ),
    );
  }
}
