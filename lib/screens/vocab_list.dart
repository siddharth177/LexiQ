import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vocab_list/widgets/popup_menu_widget.dart';

import '../models/word_meaning.dart';
import '../widgets/add_word_widget.dart';
import '../widgets/loading.dart';
import '../widgets/word_display_widget.dart';

class WordsListScreen extends StatefulWidget {
  const WordsListScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _WordsListScreenState();
  }
}

class _WordsListScreenState extends State<WordsListScreen> {
  List<WordMeaning> _vocabList = [];
  List<WordMeaning> _filteredVocabList = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }


  String _query = '';
  final SearchController _searchController = SearchController();

  @override
  Widget build(BuildContext context) {
    void openAddExpenseOverlay() {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (ctx) {
          return AddWordWidget(
            word: '',
            root: '',
            phonetic: '',
            wordClass: WordClass.none,
            examples: [],
            usages: [],
            definition: '',
            isEdit: false,
          );
        },
        isScrollControlled: true,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Expanded(
                  child: Text(
                    'My Vocab List',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 30,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 8,
                ),
                PopMenuWidget(),
              ],
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(64),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12,0,12,12),
                child: SearchBar(
                  controller: _searchController,
                  hintText: 'search your word',
                  shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
                  onChanged: (query) {
                    setState(() {
                      _query = query;
                    });
                  },
                  trailing: [
                    IconButton(
                        onPressed: () {
                          setState(() {
                            _query = '';
                            _searchController.clear();
                          });
                        },
                        icon: Icon(Icons.clear,
                        color: Theme.of(context).colorScheme.onSurface,)),
                  ],
              ),
            ),
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser?.uid)
            .collection('vocabList')
            .snapshots(),
        builder: (context, vocabSnapshots) {
          if (vocabSnapshots.connectionState == ConnectionState.waiting) {
            return const LoadingWidget();
          }

          if (!vocabSnapshots.hasData || vocabSnapshots.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.menu_book_outlined,
                    size: 72,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.25),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Your vocab list is empty',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.45),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Tap + to add your first word',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.45),
                    ),
                  )
                ]
              ),
            );
          }

          if (vocabSnapshots.hasError) {
            return const Center(
              child: Text('Error'),
            );
          }

          _vocabList.clear();
          for (var doc in vocabSnapshots.data!.docs) {
            _vocabList.add(WordMeaning.fromFirestore(doc, null));
          }

          _filteredVocabList = _vocabList
              .where((element) => element.word.contains(_query))
              .toList();

          return ListView.builder(
              padding: const EdgeInsets.only(bottom: 20),
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: _filteredVocabList.length,
              itemBuilder: (context, index) {
                return WordDisplayWidget(
                    wordMeaning: _filteredVocabList[index]);
              });
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(4.0),
        child: FloatingActionButton(
          elevation: 10,
          onPressed: openAddExpenseOverlay,
          tooltip: "Add A Word",
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
