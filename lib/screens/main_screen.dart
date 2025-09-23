import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mindful/providors/subject.dart';

import 'package:mindful/widgets/subjects.dart';
import 'package:mindful/widgets/tests.dart';

class Mainscreen extends ConsumerStatefulWidget {
  const Mainscreen({super.key});
  @override
  ConsumerState<Mainscreen> createState() => _MainscreenState();
}

class _MainscreenState extends ConsumerState<Mainscreen> {
  late Future<void> subjectfuture;
  @override
  void initState() {
    super.initState();
    subjectfuture = ref.read(subjectProvider.notifier).initializeSubjcts();
  }

  int currentPageIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,

        title: const Text("Mindful"),
        leading: Image.asset(
          'assets/images/logo.png',
          height: 30,
        ),
        actionsPadding: const EdgeInsets.all(16),
        actions: [
          TextButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
            child: const Text(
              'Log out',
              style: TextStyle(
                decoration: TextDecoration.underline,
                decorationThickness: 0.5,
              ),
            ),
          ),
          Row(
            children: [
              const Icon(Icons.person),
              Text(
                FirebaseAuth.instance.currentUser!.email!.split('@')[0],
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ],
      ),
      
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentPageIndex,
        onTap: (index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Subjects',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: 'Tests',
          ),
        ],
      ),
      body:currentPageIndex == 0 ? const SubjectsGrid() : const TestsGrid(),
    );
  }
}
