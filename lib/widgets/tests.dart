import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mindful/models/test.dart';
import 'package:mindful/providors/subject.dart';
import 'package:mindful/widgets/add_test.dart';
import 'package:mindful/widgets/confirm_deletion.dart';
import 'package:mindful/widgets/test_popup.dart';

class TestsGrid extends ConsumerStatefulWidget {
  const TestsGrid({super.key});

  @override
  ConsumerState<TestsGrid> createState() => _TestsGridState();
}

class _TestsGridState extends ConsumerState<TestsGrid> {
  late Future<void> testsFuture;
  bool isSelectingMode = false;
  List<Test> selectedTests = [];
  bool selectAll = false;
  void toggleMode() {
    setState(() {
      isSelectingMode = !isSelectingMode;
      if (!isSelectingMode) {
        selectedTests.clear();
      }
    });
  }

  void handleSelection(bool? isSelected, Test test) {
    setState(() {
      if (isSelected == true) {
        selectedTests.add(test);
      } else {
        selectedTests.remove(test);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    testsFuture = ref.read(testsProvider.notifier).fetchTests();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: testsFuture,
      builder: (context, snapshot) {
        final userTests = ref.watch(testsProvider);
        final screenWidth = MediaQuery.of(context).size.width;
        final count = screenWidth > 500 ? 3 : 2;

        final horizontalPadding = 16 * 2; // Padding from EdgeInsets.all(16.0)
        final totalSpacing = (count - 1) * 5; // 5 is crossAxisSpacing

        final itemWidth =
            (screenWidth - horizontalPadding - totalSpacing) / count;
        final itemHeight = 180.0; // Adjusted height for better appearance

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
          return const Center(child: Text('Failed to fetch your tests'));
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
                              selectedTests = List.from(userTests);
                              if (!selectAll) {
                                selectedTests.clear();
                              }
                            });
                          },
                          child: const Text('Select All'),
                        ),
                    ],
                  ),

                  if (isSelectingMode)
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: selectedTests.isEmpty
                              ? null
                              : () async {
                                  await showDialog(
                                    barrierDismissible: false,
                                    context: context,
                                    builder: (context) => ConfirmDeletion(
                                      selectedTests: selectedTests,
                                    ),
                                  );
                                  toggleMode();
                                },
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
              userTests.isEmpty
                  ? const Expanded(
                      child: Center(
                        child: Text('You have no Tests'),
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
                        itemCount: userTests.length,
                        itemBuilder: (context, index) {
                          final isSelected = selectedTests.contains(
                            userTests[index],
                          );
                          return InkWell(
                            borderRadius: BorderRadius.circular(16),
                            hoverColor: Colors.transparent,
                            onTap: isSelectingMode
                                ? () {
                                    handleSelection(
                                      !isSelected,
                                      userTests[index],
                                    );
                                  }
                                : null,
                            splashColor: Theme.of(context).cardColor,
                            child: Stack(
                              children: [
                                Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      spacing: 20,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                userTests[index].name,
                                                textAlign: TextAlign.left,
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,

                                                style: Theme.of(
                                                  context,
                                                ).textTheme.titleLarge,
                                              ),
                                            ),
                                            if (!isSelectingMode)
                                              PopupMenuButton<String>(
                                                onSelected: (value) async {
                                                  if (value == 'Delete') {
                                                    await showDialog(
                                                      barrierDismissible: false,
                                                      context: context,
                                                      builder: (context) =>
                                                          ConfirmDeletion(
                                                            test:
                                                                userTests[index],
                                                          ),
                                                    );
                                                  } else if (value == 'Edit') {
                                                    await showDialog(
                                                      barrierDismissible: false,
                                                      context: context,
                                                      builder: (context) =>
                                                          AddTestPopUp(
                                                            testToEdit:
                                                                userTests[index],
                                                          ),
                                                    );
                                                  }
                                                },
                                                itemBuilder: (context) => [
                                                  const PopupMenuItem(
                                                    value: 'Delete',
                                                    child: Text('Delete'),
                                                  ),
                                                  const PopupMenuItem(
                                                    value: 'Edit',
                                                    child: Text('Edit'),
                                                  ),
                                                ],
                                              ),
                                          ],
                                        ),
                                        Visibility(
                                          maintainAnimation: true,
                                          maintainSize: true,
                                          maintainState: true,
                                          visible: !isSelectingMode,
                                          child: ElevatedButton(
                                            child: Text(
                                              userTests[index].finished
                                                  ? 'Restart'
                                                  : 'Continue',
                                            ),
                                            onPressed: () async {
                                              if (!mounted) return;
                                              if (userTests[index].finished) {
                                                await ref
                                                    .read(
                                                      testsProvider.notifier,
                                                    )
                                                    .editTest(
                                                      Test(
                                                        id: userTests[index].id,
                                                        name: userTests[index]
                                                            .name,
                                                        createdAt:
                                                            userTests[index]
                                                                .createdAt,
                                                        progressIndex: -1,
                                                        correct: 0,
                                                        cards: userTests[index]
                                                            .cards,
                                                      ),
                                                    );
                                              } else {
                                                await showDialog(
                                                  barrierDismissible: false,
                                                  // ignore: use_build_context_synchronously
                                                  context: context,
                                                  builder: (context) =>
                                                      TestPopup(
                                                        test: userTests[index],
                                                      ),
                                                );
                                              }
                                            },
                                          ),
                                        ),
                                        Visibility(
                                          visible: !isSelectingMode,
                                          maintainAnimation: true,
                                          maintainSize: true,
                                          maintainState: true,
                                          child: Column(
                                            children: [
                                              SizedBox(
                                                width: double.infinity,
                                                child: TweenAnimationBuilder<double>(
                                                  tween: Tween<double>(
                                                    begin: 0.0,
                                                    end:
                                                        (userTests[index]
                                                                .progressIndex +
                                                            1) /
                                                        userTests[index]
                                                            .cards
                                                            .length,
                                                  ),
                                                  duration: const Duration(
                                                    milliseconds: 500,
                                                  ), // animation time
                                                  curve: Curves
                                                      .easeInOut, // smooth curve
                                                  builder: (context, value, _) {
                                                    return LinearProgressIndicator(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                      valueColor:
                                                          const AlwaysStoppedAnimation<
                                                            Color
                                                          >(Colors.white),
                                                      value: value,
                                                    );
                                                  },
                                                ),
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    'Correct : ${userTests[index].correct}',
                                                  ),
                                                  
                                                  Text(
                                                    '${((userTests[index].progressIndex + 1) / userTests[index].cards.length * 100).toStringAsFixed(1)}% ',
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
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
