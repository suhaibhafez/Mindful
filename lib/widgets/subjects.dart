import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mindful/models/flash_card.dart';

import 'package:mindful/models/subject.dart';
import 'package:mindful/providors/subject.dart';

import 'package:mindful/screens/flash_cards.dart';

import 'package:mindful/widgets/add_pop_up.dart';
import 'package:mindful/widgets/add_test.dart';

import 'package:mindful/widgets/confirm_deletion.dart';
import 'package:mindful/widgets/gbt.dart';

class SubjectsGrid extends ConsumerStatefulWidget {
  const SubjectsGrid({
    super.key,
  });

  @override
  ConsumerState<SubjectsGrid> createState() => _SubjectsGridState();
}

class _SubjectsGridState extends ConsumerState<SubjectsGrid> {
  bool isSelectingMode = false;
  bool selectAll = false;
  List<Subject> selectedSubjects = [];
  late Future<void> subjectFuture;
  @override
  void initState() {
    super.initState();
    subjectFuture = ref.read(subjectProvider.notifier).initializeSubjcts();
  }

  void toggleMode() {
    setState(() {
      isSelectingMode = !isSelectingMode;
      if (!isSelectingMode) {
        selectedSubjects.clear();
      }
    });
  }

  void handleSelection(bool? isSelected, Subject subject) {
    setState(() {
      if (isSelected == true) {
        selectedSubjects.add(subject);
      } else {
        selectedSubjects.remove(subject);
      }
    });
  }

  void showPopup() async {
    await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return const AddPopUp();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: subjectFuture,
      builder: (context, snapshot) {
        final usersubjects = ref.watch(subjectProvider);
        final screenWidth = MediaQuery.of(context).size.width;
        final count = screenWidth > 500 ? 3 : 2;

        final horizontalPadding = 16 * 2; // Padding from EdgeInsets.all(16.0)
        final totalSpacing = (count - 1) * 5; // 5 is crossAxisSpacing

        final itemWidth =
            (screenWidth - horizontalPadding - totalSpacing) / count;
        final itemHeight =
            150.0; // You can adjust based on aspect ratio or content

        final aspectRatio = itemWidth / itemHeight;
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          );
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Failed to fetch your subjects'));
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            spacing: 20,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    spacing: 20,
                    children: [
                      ElevatedButton(
                        onPressed: toggleMode,
                        child: Text(isSelectingMode ? 'Cancel' : 'Select'),
                      ),
                      if (isSelectingMode)
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              selectAll = !selectAll;
                              selectedSubjects = List.from(usersubjects);
                              if (!selectAll) {
                                selectedSubjects.clear();
                              }
                            });
                          },
                          child: const Text('Select all'),
                        ),
                    ],
                  ),
                  if (!isSelectingMode)
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: showPopup,
                          label: const Text('Subject'),
                          icon: const Icon(Icons.add),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            await showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (context) => const Gbt(),
                            );
                          },
                          child: const Text('Create subjects with ai'),
                        ),
                      ],
                    ),

                  if (isSelectingMode)
                    Row(
                      spacing: 20,
                      children: [
                        ElevatedButton(
                          onPressed: selectedSubjects.isNotEmpty
                              ? () async {
                                  final List<FlashCard> cards = [];
                                  for (var subject in selectedSubjects) {
                                    cards.addAll(subject.subjectCards);
                                  }
                                  if (cards.isEmpty) {
                                    await showDialog(
                                      barrierDismissible: false,
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text(
                                          'Can\'t Start Test',
                                        ),
                                        content: const Text(
                                          'Try adding some cards',
                                        ),
                                        actionsAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        actions: [
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.of(
                                                context,
                                              ).pop();
                                            },
                                            child: const Text(
                                              'Okay',
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  } else {
                                    await showDialog(
                                      barrierDismissible: false,
                                      context: context,
                                      builder: (ctx) {
                                        return AddTestPopUp(
                                          cards: cards,
                                        );
                                      },
                                    );
                                  }
                                  toggleMode();
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(
                              255,
                              2,
                              57,
                              30,
                            ),
                          ),
                          child: const Text('Create Test'),
                        ),

                        ElevatedButton(
                          onPressed: selectedSubjects.isNotEmpty
                              ? () async {
                                  await showDialog(
                                    barrierDismissible: false,
                                    context: context,
                                    builder: (ctx) => ConfirmDeletion(
                                      selectedSubjects: selectedSubjects,
                                    ),
                                  );

                                  toggleMode();
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(
                              255,
                              84,
                              15,
                              10,
                            ),
                          ),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                ],
              ),
              usersubjects.isEmpty
                  ? const Expanded(
                      child: Center(
                        child: Text('You have no subjects'),
                      ),
                    )
                  : Expanded(
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: count,
                          crossAxisSpacing: 5,
                          mainAxisSpacing: 5,
                          childAspectRatio: aspectRatio,
                        ),
                        itemCount: usersubjects.length,
                        itemBuilder: (context, index) {
                          final isSelected = selectedSubjects.contains(
                            usersubjects[index],
                          );

                          return Tooltip(
                            message: !isSelectingMode ? 'View cards' : '',

                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                hoverColor: Colors.transparent,
                                onTap: isSelectingMode
                                    ? () {
                                        handleSelection(
                                          !isSelected,
                                          usersubjects[index],
                                        );
                                      }
                                    : () async {
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) {
                                              return FlashCardsScreen(
                                                subject: usersubjects[index],
                                              );
                                            },
                                          ),
                                        );
                                      },

                                splashColor: Theme.of(context).cardColor,
                                child: Stack(
                                  children: [
                                    Card(
                                      child: Stack(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(12),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,

                                              children: [
                                                SizedBox(
                                                  height: 75,
                                                  width: double.infinity,

                                                  child: SingleChildScrollView(
                                                    scrollDirection:
                                                        Axis.vertical,
                                                    child: Text(
                                                      usersubjects[index].name,
                                                      softWrap: true,
                                                      overflow:
                                                          TextOverflow.clip,
                                                      style: Theme.of(
                                                        context,
                                                      ).textTheme.titleLarge,
                                                    ),
                                                  ),
                                                ),

                                                Visibility(
                                                  visible: !isSelectingMode,
                                                  maintainSize: true,
                                                  maintainAnimation: true,
                                                  maintainState: true,
                                                  child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      IconButton(
                                                        style: IconButton.styleFrom(
                                                          backgroundColor:
                                                              const Color.fromARGB(
                                                                255,
                                                                2,
                                                                57,
                                                                30,
                                                              ),
                                                        ),
                                                        tooltip: 'Create Test',
                                                        onPressed: () async {
                                                          if (!context
                                                              .mounted) {
                                                            return;
                                                          }
                                                          if (usersubjects[index]
                                                              .subjectCards
                                                              .isEmpty) {
                                                            await showDialog(
                                                              barrierDismissible:
                                                                  false,
                                                              context: context,
                                                              builder: (context) => AlertDialog(
                                                                title: const Text(
                                                                  'Can\'t Start Test',
                                                                ),
                                                                content: const Text(
                                                                  'Try adding some cards',
                                                                ),
                                                                actionsAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                actions: [
                                                                  ElevatedButton(
                                                                    onPressed: () {
                                                                      Navigator.of(
                                                                        context,
                                                                      ).pop();
                                                                    },
                                                                    child:
                                                                        const Text(
                                                                          'Close',
                                                                        ),
                                                                  ),
                                                                  ElevatedButton(
                                                                    onPressed: () async {
                                                                      Navigator.of(
                                                                        context,
                                                                      ).pop();
                                                                      await Navigator.push(
                                                                        context,
                                                                        MaterialPageRoute(
                                                                          builder:
                                                                              (
                                                                                context,
                                                                              ) {
                                                                                return FlashCardsScreen(
                                                                                  subject: usersubjects[index],
                                                                                );
                                                                              },
                                                                        ),
                                                                      );
                                                                    },
                                                                    child: const Text(
                                                                      'Add Cards',
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            );
                                                          } else {
                                                            await showDialog(
                                                              barrierDismissible:
                                                                  false,
                                                              context: context,
                                                              builder: (ctx) {
                                                                return AddTestPopUp(
                                                                  cards: usersubjects[index]
                                                                      .subjectCards,
                                                                );
                                                              },
                                                            );
                                                          }
                                                        },
                                                        icon: const Icon(
                                                          Icons.play_arrow,
                                                        ),
                                                      ),
                                                      IconButton(
                                                        tooltip: 'Edit',
                                                        icon: const Icon(
                                                          Icons.edit,
                                                          color: Colors.grey,
                                                        ),
                                                        onPressed: () async {
                                                          await showDialog(
                                                            barrierDismissible:
                                                                false,
                                                            context: context,
                                                            builder: (context) {
                                                              return AddPopUp(
                                                                toEdit:
                                                                    usersubjects[index],
                                                              );
                                                            },
                                                          );
                                                        },
                                                      ),
                                                      IconButton(
                                                        tooltip: 'Delete',
                                                        icon: const Icon(
                                                          Icons.delete,
                                                          color: Colors.red,
                                                        ),
                                                        onPressed: () async {
                                                          await showDialog(
                                                            barrierDismissible:
                                                                false,
                                                            context: context,
                                                            builder: (context) {
                                                              return ConfirmDeletion(
                                                                subject:
                                                                    usersubjects[index],
                                                              );
                                                            },
                                                          );
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Positioned(
                                            left: 12,
                                            bottom: 12,
                                            child: Text(
                                              'Total Cards: ${usersubjects[index].subjectCards.length}',
                                              style: TextStyle(
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.secondary,
                                                fontSize: 10,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    if (isSelectingMode)
                                      Positioned(
                                        top: 4,
                                        right: 4,
                                        child: IgnorePointer(
                                          child: Checkbox(
                                            value: isSelected,
                                            onChanged: (_) {},
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ],
          ),
        );
      },
    );
  }
}
