
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mindful/models/subject.dart';
import 'package:mindful/providors/subject.dart';
import 'package:mindful/widgets/add_card.dart';
import 'package:mindful/widgets/cards_grid.dart';

class FlashCardsScreen extends ConsumerStatefulWidget {
  const FlashCardsScreen({super.key, required this.subject});
  final Subject subject;

  @override
  ConsumerState<FlashCardsScreen> createState() => _FlashCardsScreenState();
}

class _FlashCardsScreenState extends ConsumerState<FlashCardsScreen> {
  late Future<void> _cardsfuture;
  @override
  void initState() {
    super.initState();
    _cardsfuture = ref.read(cardProvider.notifier).fetchCards(widget.subject);
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final cards = ref.watch(cardProvider);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,

        title: Text(
          widget.subject.name,
          overflow: TextOverflow.ellipsis,
        ),
        leading: IconButton(
          onPressed: () async {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),

       
      ),
      floatingActionButton: ElevatedButton.icon(
        onPressed: () async {
          await showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) => AddCard(subject: widget.subject),
          );
        },
        label: const Text('FlashCard'),
        icon: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: FutureBuilder(
        future: _cardsfuture,
        builder: (context, snapshot) {
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
          final Widget content = cards.isEmpty
              ? const Center(child: Text('No cards added'))
              : CardsGrid(
                  subject: widget.subject,
                  cards: cards,
                );
          return content;
        },
      ),
    );
  }
}
