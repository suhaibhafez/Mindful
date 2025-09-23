import 'package:flutter/material.dart';


import 'package:mindful/models/flash_card.dart';
import 'package:mindful/models/subject.dart';

import 'package:mindful/widgets/add_card.dart';
import 'package:mindful/widgets/confirm_deletion.dart';

class CardsGrid extends StatefulWidget {
  const CardsGrid({super.key, required this.cards, required this.subject});
  final List<FlashCard> cards;
  final Subject subject;

  @override
  State<CardsGrid> createState() => _CardsGridState();
}
//TODO
class _CardsGridState extends State<CardsGrid> {
  @override
  Widget build(BuildContext context, ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final coun = screenWidth > 500 ? 3 : 2;
    final itemWidth =
        (screenWidth - 32 - 10) / coun; // Adjust padding + spacing
    final itemHeight = 300.0; // Set fixed or dynamic height if needed

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: coun,
        crossAxisSpacing: 5,
        mainAxisSpacing: 5,
        childAspectRatio: itemWidth / itemHeight, // width / height
      ),
      itemCount: widget.cards.length,
      itemBuilder: (context, index) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              spacing: 20,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
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
                        color: Theme.of(context).colorScheme.secondaryFixed.withAlpha(255),
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(8)
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Text(
                        'Q: ${widget.cards[index].question}',
                        softWrap: true,

                        textAlign: TextAlign.left,
                        overflow: TextOverflow.clip,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                  ),
                ),
                Flexible(
                  child: Container(
                    width: double.infinity,
                    height: 100,
                    padding:const EdgeInsets.all(8),
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
                        color: Theme.of(context).colorScheme.secondaryFixed.withAlpha(255),
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),


                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Text(
                        'Ans: ${widget.cards[index].answer}',
                        softWrap: true,
                        textAlign: TextAlign.left,
                    
                        overflow: TextOverflow.clip,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      tooltip: 'Edit',
                      icon: const Icon(Icons.edit, color: Colors.grey),
                      onPressed: () async {
                        await showDialog(
                           barrierDismissible: false,
                          context: context,
                          builder: (context) => AddCard(
                            subject: widget.subject,
                            toEdit: widget.cards[index],
                          ),
                        );
                      },
                    ),
                    IconButton(
                      tooltip: 'Delete',
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        await showDialog(
                           barrierDismissible: false,
                          context: context,
                          builder: (context) => ConfirmDeletion(
                            subject: widget.subject,
                            card: widget.cards[index],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
