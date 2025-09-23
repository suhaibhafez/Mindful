import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mindful/models/flash_card.dart';
import 'package:mindful/models/test.dart';
import 'package:mindful/providors/subject.dart';

class AddTestPopUp extends ConsumerStatefulWidget {
  const AddTestPopUp({super.key, this.cards, this.testToEdit});
  final List<FlashCard>? cards;
  final Test? testToEdit;
  @override
  ConsumerState<AddTestPopUp> createState() => _AddTestPopUpState();
}

class _AddTestPopUpState extends ConsumerState<AddTestPopUp> {
  final _formKey = GlobalKey<FormState>();
  bool isSubmitting = false;
  String testName = '';
  void submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        isSubmitting = true;
      });
      if (widget.testToEdit != null) {
        await ref
            .read(testsProvider.notifier)
            .editTest(
              Test(
                name: testName,
                cards: widget.testToEdit!.cards,
                id: widget.testToEdit!.id,
                progressIndex: widget.testToEdit!.progressIndex,
                correct: widget.testToEdit!.correct,
              ),
            );
      } else {
        await ref
            .read(testsProvider.notifier)
            .addTest(Test(name: testName, cards: widget.cards!));
      }
      if (!mounted) return;
      setState(() {
        isSubmitting = false;
      });
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.testToEdit != null ? 'Edit Test' : 'Create Test',
      ),
      content: Container(
        constraints: const BoxConstraints(maxWidth: 300, maxHeight: 200),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: TextFormField(
                  initialValue: widget.testToEdit?.name,
                  style: const TextStyle(
                    overflow: TextOverflow.visible,
                  ),
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  // initialValue: widget.toEdit?.question,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Test Name',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a valid name';
                    }

                    return null;
                  },
                  onSaved: (value) {
                    testName = value!.trim();
                  },
                  onFieldSubmitted: (_) => submit(),
                ),
              ),
              Text(
                'Cards: ${widget.testToEdit != null ? widget.testToEdit!.cards.length : widget.cards!.length}',
              ),
            ],
          ),
        ),
      ),
      actions: isSubmitting
          ? [
              SizedBox(
                width: double.infinity, // full width
                child: Center(
                  child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
            ]
          : [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: submit,
                    child: const Text('Save'),
                  ),
                ],
              ),
            ],
    );
  }
}
