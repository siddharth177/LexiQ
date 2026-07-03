import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vocab_list/providers/secrets_provider.dart';
import 'package:vocab_list/services/word_details.dart';
import 'package:vocab_list/services/speak_aloud.dart';
import 'package:vocab_list/utils/colors_and_theme.dart';
import 'package:vocab_list/utils/snackbar_messaging.dart';
import 'package:vocab_list/widgets/positioned_loading_widget.dart';

import '../models/word_meaning.dart';
import '../utils/firebase.dart';

class AddWordWidget extends ConsumerStatefulWidget {
  AddWordWidget(
      {super.key,
      required this.word,
      required this.root,
      required this.phonetic,
      required this.wordClass,
      required this.examples,
      required this.usages,
      required this.definition,
      required this.isEdit});

  String word = '';
  String phonetic = '';
  String root = '';
  WordClass wordClass = WordClass.none;
  String definition = '';
  List<String> usages = [];
  List<String> examples = [];
  bool isEdit = false;

  @override
  ConsumerState<AddWordWidget> createState() {
    return _AddWordWidgetState();
  }
}

class _AddWordWidgetState extends ConsumerState<AddWordWidget> {
  final _formKey = GlobalKey<FormState>();
  String _word = '';
  String _phonetic = '';
  String _root = '';
  WordClass _wordClass = WordClass.none;
  String _definition = '';
  List<String> _usages = [];
  List<String> _examples = [];
  String _popupTitle = "Add New Word";
  String _saveButton = 'Add Word';
  String _clearButton = 'Clear';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _word = widget.word;
    _phonetic = widget.phonetic;
    _root = widget.root;
    _wordClass = widget.wordClass;
    _definition = widget.definition;
    _usages = widget.usages;
    _examples = widget.examples;
    _popupTitle = widget.isEdit ? 'Edit Word' : 'Add New Word';
    _saveButton = widget.isEdit ? 'Save' : 'Add';
    _clearButton = widget.isEdit ? 'Delete' : 'Clear';

    _definitionController.text = _definition;
    _wordController.text = _word;
    // _phoneticController.text = _phonetic;
    _rootController.text = _root;
  }

  final TextEditingController _wordController = TextEditingController();
  final TextEditingController _rootController = TextEditingController();

  // final TextEditingController _phoneticController = TextEditingController();
  final TextEditingController _definitionController = TextEditingController();
  final TextEditingController _usageController = TextEditingController();
  final TextEditingController _exampleController = TextEditingController();

  Future<void> _onFormSubmit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      var newWord = WordMeaning(
        word: _word,
        definition: _definition,
        usages: _usages,
        examples: _examples,
        wordClass: _wordClass,
        root: _root,
        phonetic: _phonetic,
      );

      var uid = firebaseAuthInstance.currentUser?.uid;
      final res = await firestoreInstance
          .collection('users')
          .doc(uid)
          .collection('vocabList')
          .withConverter(
              fromFirestore: WordMeaning.fromFirestore,
              toFirestore: (WordMeaning word, options) => word.toFirestore())
          .doc(_word)
          .set(newWord);

      Navigator.of(context).pop();
    }
  }

  void _clearEntries() {
    _wordController.clear();
    // _phoneticController.clear();
    _rootController.clear();
    _definitionController.clear();
    _exampleController.clear();
    _usageController.clear();

    setState(() {
      _word = '';
      _phonetic = '';
      _root = '';
      _wordClass = WordClass.none;
      _definition = '';
      _usages = [];
      _examples = [];
    });
  }

  Future<void> _fetchWordData(inputWord) async {
    if (inputWord.isEmpty) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final apiKey = await ref.read(groqApiKeyProvider.future);
      final wordData = await getWordData(inputWord, apiKey);
      clearAndDisplaySnackbar(context,
          'Details for $inputWord fetched from llama model successfully',
          duration: 2);
      _word = inputWord ?? '';
      // _phonetic = wordData['phonetic'] ?? '';
      _root = wordData['root'] ?? '';
      _wordClass = _getWordClassFromString(wordData['wordType']);
      _definition = wordData['definition'] ?? '';
      _usages = (_getStringListFromApiData(wordData['usages']));
      _examples = (_getStringListFromApiData(wordData['examples']));

      _wordController.text = _word;
      // _phoneticController.text = _phonetic;
      _rootController.text = _root;
      _definitionController.text = _definition;
    } catch (e) {
      debugPrint('Error fetching word data: $e');
      clearAndDisplaySnackbar(
          context, 'failed to load details for $inputWord from llama model.',
          duration: 2);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Helper function to convert string to WordClass enum
  WordClass _getWordClassFromString(String? wordClassString) {
    if (wordClassString != null) {
      try {
        return WordClass.values.byName(wordClassString);
      } catch (e) {}
    }
    return WordClass.none;
  }

  // Helper function to extract string list from API data
  List<String> _getStringListFromApiData(dynamic apiData) {
    if (apiData is String) {
      return apiData.split(';').map((s) => s.trim()).toList();
    } else if (apiData is List) {
      return apiData.cast<String>();
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    TextStyle labelStyle = const TextStyle().copyWith(
      color: Theme.of(context).brightness == Brightness.dark
          ? kDarkWhiteShade2
          : null,
    );

    TextStyle floatingLabelStyle = const TextStyle().copyWith(
        color: Theme.of(context).brightness == Brightness.dark
            ? Theme.of(context).colorScheme.primary
            : null);

    TextStyle inputTextStyle = const TextStyle().copyWith(
        color: Theme.of(context).brightness == Brightness.dark
            ? kDarkWhiteShade1
            : null);

    return Container(
      padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top),
      child: Scaffold(
        appBar: AppBar(
          title: Text(_popupTitle),
        ),
        body: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 4,
                      child: TextFormField(
                        style: inputTextStyle,
                        controller: _wordController,
                        decoration: InputDecoration(
                          labelStyle: labelStyle,
                          floatingLabelStyle: floatingLabelStyle,
                          label: const Text(
                            "Word",
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().length <= 1) {
                            return 'Word cannot be empty';
                          }

                          return null;
                        },
                        onFieldSubmitted: (v) {
                          _fetchWordData(v);
                        },
                        onSaved: (value) {
                          _word = value!;
                        },
                      ),
                    ),
                    // const SizedBox(
                    //   width: 20,
                    // ),
                    Expanded(
                      child: IconButton(
                        onPressed: () {
                          _fetchWordData(_wordController.text);
                        },
                        icon: Icon(
                          Icons.search_rounded,
                          color: Theme.of(context).colorScheme.primary
                        ),
                      ),
                    ),
                    Expanded(
                      child: IconButton(
                        onPressed: () {
                          speakAloud(_wordController.text);
                        },
                        icon: Icon(
                          Icons.record_voice_over,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Stack(
                        children: [
                          DropdownMenu<WordClass>(
                            initialSelection: _wordClass != WordClass.none
                                ? _wordClass
                                : WordClass.none,
                            requestFocusOnTap: true,
                            label: Text(
                              'Word Class',
                              style: floatingLabelStyle,
                            ),
                            dropdownMenuEntries: WordClass.values
                                .map<DropdownMenuEntry<WordClass>>(
                                  (e) => DropdownMenuEntry<WordClass>(
                                    value: e,
                                    label: e.name,
                                    style: ButtonStyle(
                                      foregroundColor:
                                          Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? WidgetStateProperty.all(
                                                  kDarkWhiteShade2)
                                              : null,
                                    ),
                                  ),
                                )
                                .toList(),
                            onSelected: (value) {
                              _wordClass = value!;
                            },
                          ),
                          if (_isLoading) // Only show the loading indicator when isLoading is true
                            const PositionedLoadingWidget(),
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    Expanded(
                      child: Stack(
                        children: [
                          TextFormField(
                            controller: _rootController,
                            style: inputTextStyle,
                            decoration: InputDecoration(
                              labelStyle: labelStyle,
                              floatingLabelStyle: floatingLabelStyle,
                              label: const Text("Root"),
                            ),
                            onSaved: (value) {
                              _root = value!;
                            },
                          ),
                          if (_isLoading) // Only show the loading indicator when isLoading is true
                            const PositionedLoadingWidget(),
                        ],
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        TextFormField(
                          controller: _definitionController,
                          style: inputTextStyle,
                          decoration: InputDecoration(
                            labelStyle: labelStyle,
                            floatingLabelStyle: floatingLabelStyle,
                            label: Text(
                              'Definition',
                            ),
                          ),
                          onFieldSubmitted: (value) {
                            _definition = value;
                            // if (_definition.isEmpty && widget.definition.isNotEmpty) {
                            //   _definition = widget.definition;
                            // }
                            // _definition.add(_meaningController.text);
                            // _meaningController.clear();
                          },
                            onSaved: (value) {
                              _definition = value ?? '';
                            }
                        ),
                        if (_isLoading) // Only show the loading indicator when isLoading is true
                          const PositionedLoadingWidget(),
                      ],
                    ),
                    // Column(
                    //   mainAxisAlignment: MainAxisAlignment.start,
                    //   crossAxisAlignment: CrossAxisAlignment.start,
                    //   children:
                    //       _definition.map((meaning) => Text(meaning)).toList(),
                    // ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        TextFormField(
                          controller: _usageController,
                          style: inputTextStyle,
                          decoration: InputDecoration(
                            labelStyle: labelStyle,
                            floatingLabelStyle: floatingLabelStyle,
                            label: Text(
                              'Usages',
                            ),
                          ),
                          onFieldSubmitted: (value) {
                            if (_usages.isEmpty && widget.usages.isNotEmpty) {
                              _usages = widget.usages;
                            }
                            setState(() {
                              _usages.add(_usageController.text);
                              _usageController.clear();
                            });
                          },
                        ),
                        if (_isLoading) // Only show the loading indicator when isLoading is true
                          const PositionedLoadingWidget(),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _usages.map((meaning) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _usageController.text = meaning;
                              _usages.remove(meaning);
                            });
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(
                                  child: Text(
                                meaning,
                                style: inputTextStyle,
                              )),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    _usages.remove(meaning);
                                  });
                                },
                                icon: Icon(
                                  Icons.delete,
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? kDarkWhiteShade2
                                      : null,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        TextFormField(
                          controller: _exampleController,
                          style: inputTextStyle,
                          decoration: InputDecoration(
                              labelStyle: labelStyle,
                              floatingLabelStyle: floatingLabelStyle,
                              label: const Text(
                                'Examples',
                              )),
                          onFieldSubmitted: (value) {
                            if (_examples.isEmpty &&
                                widget.examples.isNotEmpty) {
                              _examples = widget.examples;
                            }
                            setState(() {
                              _examples.add(_exampleController.text);
                              _exampleController.clear();
                            });
                          },
                        ),
                        if (_isLoading) // Only show the loading indicator when isLoading is true
                          const PositionedLoadingWidget(),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _examples.map((meaning) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _exampleController.text = meaning;
                              _examples.remove(meaning);
                            });
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(
                                  child: Text(
                                meaning,
                                style: inputTextStyle,
                              )),
                              IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _examples.remove(meaning);
                                    });
                                  },
                                  icon: Icon(
                                    Icons.delete,
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? kDarkWhiteShade2
                                        : null,
                                  )),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (widget.isEdit)
                      ElevatedButton(
                        onPressed: _onFormSubmit,
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all<Color>(
                              Theme.of(context).colorScheme.primaryContainer),
                          minimumSize:
                              WidgetStateProperty.all<Size>(Size(20, 30)),
                        ),
                        child: Text(_saveButton),
                      )
                    else ...[
                      ElevatedButton(
                        onPressed: _clearEntries,
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all<Color>(
                              Theme.of(context).colorScheme.errorContainer),
                          foregroundColor: WidgetStateProperty.all<Color>(
                            Theme.of(context).colorScheme.onErrorContainer
                          )
                          // minimumSize: WidgetStateProperty.all<Size>(Size(50,40)),
                        ),
                        child: Text(_clearButton),
                      ),
                      ElevatedButton(
                        onPressed: _onFormSubmit,
                        style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all<Color>(
                                Theme.of(context)
                                    .colorScheme
                                    .primaryContainer)),
                        child: Text(_saveButton),
                      ),
                    ]
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
