import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mindful/models/subject.dart';
import 'package:mindful/providors/subject.dart';

class AddPopUp extends ConsumerStatefulWidget {
  const AddPopUp({super.key, this.toEdit});
  final Subject? toEdit;
  @override
  ConsumerState<AddPopUp> createState() {
    return _AddPopUpstate();
  }
}

class _AddPopUpstate extends ConsumerState<AddPopUp> {
  final _formKey = GlobalKey<FormState>();
  bool isSubmitting = false;
  String subjectName = '';
  void submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        isSubmitting = true;
      });
      if (widget.toEdit == null) {
        await ref
            .read(subjectProvider.notifier)
            .addSubject(
              Subject(name: subjectName),
            );
      } else {
        await ref
            .read(subjectProvider.notifier)
            .editSubject(widget.toEdit!, subjectName);
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
    final subjects = ref.watch(subjectProvider);

    return AlertDialog(
      actionsAlignment: MainAxisAlignment.center,
      title:  Text(widget.toEdit!=null?'Edit name':'Add Subject'),
      content: Container(
        constraints:const BoxConstraints(maxWidth: 300,maxHeight: 150),
        child: Form(
          
          key: _formKey,
          child: TextFormField(
            
            style: const TextStyle(
              overflow: TextOverflow.visible,
            ),
            maxLines: null,
            keyboardType: TextInputType.multiline,
            initialValue: widget.toEdit?.name,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Subject Name',
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a subject name';
              }
              final alreadyExist = subjects.any((s) => s.name == value.trim());
              if (alreadyExist) {
                return 'Subject name already exist';
              }
              return null;
            },
            onSaved: (value) {
              subjectName = value!.trim();
            },
            onFieldSubmitted: (_) => submit(),
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
