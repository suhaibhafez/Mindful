import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mindful/models/flash_card.dart';
import 'package:mindful/models/subject.dart';

class Gbt extends StatefulWidget {
  const Gbt({super.key});
  @override
  State<Gbt> createState() => _GbtState();
}

class _GbtState extends State<Gbt> {
  final List<Subject> _chunks = [];
  PlatformFile? _file;
  bool _isLoading = false;
  String _error = '';

  void _reset() {
    _chunks.clear();
    _error = '';
    _file = null;
  }

  Future<void> _uploadAndExtract(PlatformFile file) async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final uri = Uri.parse('http://localhost:3000/extract'); // Change in prod
      final req = http.MultipartRequest('POST', uri)
        ..files.add(
          http.MultipartFile.fromBytes(
            'file',
            file.bytes!,
            filename: file.name,
          ),
        );

      final streamed = await req.send();
      final resp = await http.Response.fromStream(streamed);

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        _chunks.clear();
        final flashcards = data['flashcards'];

        if (flashcards != null && flashcards['subjects'] != null) {
          final subjectsList = flashcards['subjects'] as List<dynamic>;
          for (var s in subjectsList) {
            final name = s['name'] as String? ?? 'Unnamed Subject';
            final cardsList = s['cards'] as List<dynamic>? ?? [];
            final cards = cardsList.map((c) {
              return FlashCard(
                question: c['question'] as String? ?? '',
                answer: c['answer'] as String? ?? '',
              );
            }).toList();

            _chunks.add(Subject(name: name, subjectCards: cards));
          }
        } else if (data['error'] != null) {
         setState(() {
            _error = data['error'];
         });
        } else {
         setState(() {
            _error = 'No flashcards returned';
         });
        }

        if (_chunks.isEmpty) {
          setState(() {
            _error = 'No text found in file.';
          });
        }
      } else {
        setState(() {
          _error = 'Server error: ${resp.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to process file: $e';
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _pickFile() async {
    setState(() {
      _isLoading = true;
      _error = '';
      _chunks.clear();
      _file = null;
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        withData: true,
        allowedExtensions: const ['pdf', 'docx', 'txt'],
        type: FileType.custom,
      );

      if (result == null ||
          result.files.isEmpty ||
          result.files.first.bytes == null) {
        setState(() {
          _isLoading = false;
          _error = 'No file selected or file is empty.';
        });
        return;
      }

      final f = result.files.first;
      final ext = (f.extension ?? '').toLowerCase();
      if (!['pdf', 'docx', 'txt'].contains(ext)) {
        setState(() {
          _isLoading = false;
          _error = 'Invalid file type. Allowed: .pdf, .docx, .txt';
        });
        return;
      }

      _file = f;
      await _uploadAndExtract(f);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Failed to read file: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.all(16),
      title: Row(
        children: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.close,
              color: Colors.red,
            ),
          ),
          const Text('Create subjects with AI'),
        ],
      ),
      content: SizedBox(
        width: 360,
        height: 420,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _isLoading ? null : _pickFile,
              child: const Text('Choose file'),
            ),
            const SizedBox(height: 4),
            const Text(
              'Only .pdf, .docx, .txt',
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            if (_file != null && !_isLoading)
              Text(_file!.name, overflow: TextOverflow.ellipsis),
            if (_isLoading) ...[
              const SizedBox(height: 12),
              const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
              const SizedBox(height: 8),
              const Center(child: Text('Reading file, please wait...')),
            ],
            if (_error.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(_error, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 8),
            Expanded(
              child: _chunks.isEmpty
                  ? const Center(child: Text('No content yet'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: _chunks.length,
                      itemBuilder: (context, i) {
                        final subject = _chunks[i];
                        return Card(
                          elevation: 1,
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Subject: ${subject.name}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                ...subject.subjectCards.map(
                                  (card) => Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 2,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Q: ${card.question}',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                        Text(
                                          'A: ${card.answer}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                            height: 1.2,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),

            const SizedBox(height: 8),
            Row(
              children: [
                if (_chunks.isNotEmpty)
                  Text(
                    'Loaded ${(_chunks.join().length).toString()} chars',
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    setState(_reset);
                  },
                  child: const Text('Clear'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
