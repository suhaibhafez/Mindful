
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mindful/models/flash_card.dart';
import 'package:mindful/models/subject.dart';
import 'package:mindful/models/test.dart';
import 'package:mindful/providors/subject.dart';

class ConfirmDeletion extends ConsumerStatefulWidget {
  const ConfirmDeletion({
    super.key,
    this.subject,
    this.card,
    this.selectedSubjects,
    this.test,
    this.selectedTests,
  });
  final Subject? subject;
  final FlashCard? card;
  final List<Subject>? selectedSubjects;
  final Test? test;
  final List<Test>? selectedTests;

  @override
  ConsumerState<ConfirmDeletion> createState() => _ConfirmDeletionState();
}

class _ConfirmDeletionState extends ConsumerState<ConfirmDeletion> {
  bool isDeleting = false;

  Future<void> delete() async {
    if (widget.card == null &&
        widget.selectedSubjects == null &&
        widget.subject != null) {
      await ref.read(subjectProvider.notifier).deleteSubject(widget.subject!);
    } else if (widget.card != null && widget.subject != null) {
      await ref
          .read(cardProvider.notifier)
          .deleteCard(widget.subject!, widget.card!);
    } else if (widget.selectedSubjects != null) {
      await Future.wait(
        widget.selectedSubjects!.map(
          (e) async=>await ref.read(subjectProvider.notifier).deleteSubject(e),
        ),
      );
    }
    else if (widget.test != null) {
      await ref.read(testsProvider.notifier).deleteTest(widget.test!);
    }
    else if (widget.selectedTests != null) {
      await Future.wait(
        widget.selectedTests!.map(
          (e) async=>await ref.read(testsProvider.notifier).deleteTest(e),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> content = [
      CircularProgressIndicator(
        color: Theme.of(context).colorScheme.onPrimary,
      ),
    ];

    if (!isDeleting) {
      content = [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(149, 244, 67, 54),
            
          ),

          onPressed: () async {
            setState(() {
              isDeleting = true;
            });
            await delete();
            if (!mounted) {}
            // ignore: use_build_context_synchronously
            Navigator.of(context).pop();
          },

          child: const Text('Confirm'),
        ),
      ];
    }
    return AlertDialog(
      actionsAlignment: MainAxisAlignment.center,
      title: const Text(
        'Are you sure',
        textAlign: TextAlign.center,
      ),

      actions: content,
    );
  }
}
