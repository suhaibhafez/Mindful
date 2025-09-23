import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mindful/models/flash_card.dart';
import 'package:mindful/models/subject.dart';
import 'package:mindful/providors/subject.dart';

class AddCard extends ConsumerStatefulWidget {
  const AddCard({super.key, this.toEdit,required this.subject});
  final FlashCard? toEdit;
  final Subject subject;
  @override
  ConsumerState<AddCard> createState() {
    return _AddCard();
  }
}

class _AddCard extends ConsumerState<AddCard> {
  final _formKey = GlobalKey<FormState>();
  bool isSubmitting = false;
  String cardQuestion = '';
  String cardAnswer = '';

  void submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        isSubmitting = true;
      });
      if (widget.toEdit == null) {
        await ref
            .read(cardProvider.notifier)
            .addCard(widget.subject,FlashCard(question: cardQuestion, answer: cardAnswer)
             
            );
      } else {
        await ref
            .read(cardProvider.notifier)
            .editCard(widget.subject, widget.toEdit!,cardQuestion,cardAnswer);
      }

      if (!mounted) return;
      setState(() {
        isSubmitting = false;
      });
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop(); // Close dialog
    }
  }

  @override
  Widget build(BuildContext context) {
   

    return AlertDialog(
      actionsAlignment: MainAxisAlignment.center,
      title: Text(widget.toEdit != null ? 'Edit Card' : 'Add Card'),
      content: Container(
        constraints: const BoxConstraints(maxWidth: 300, maxHeight: 200),
        child: Form(
          key: _formKey,
          child: Column(
            spacing: 10,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Flexible(
                child: TextFormField(
                  style: const TextStyle(
                    overflow: TextOverflow.visible,
                  ),
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  initialValue: widget.toEdit?.question,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Question',
                    
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a Question';
                    }
                    
                    return null;
                  },
                  onSaved: (value) {
                    cardQuestion = value!.trim();
                  },
                  onFieldSubmitted: (_) => submit(),
                ),
              ),
               Flexible(
                 child: TextFormField(
                  style: const TextStyle(
                    overflow: TextOverflow.visible,
                  ),
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  initialValue: widget.toEdit?.answer,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Answer',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter an Answer';
                    }
                 
                    return null;
                  },
                  onSaved: (value) {
                    cardAnswer = value!.trim();
                  },
                  onFieldSubmitted: (_) => submit(),
                               ),
               ),
            ],
          ),
        ),
      ),
      actions: isSubmitting
          ? [
              CircularProgressIndicator(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ]
          : [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: submit,
                child: const Text('Save'),
              ),
            ],
    );
  }
}
