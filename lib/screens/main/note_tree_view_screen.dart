import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_treeview/flutter_treeview.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

import 'package:note_sphere/data/firestore_datastore.dart';
import 'package:note_sphere/data/note_tree_view.dart';
import 'package:note_sphere/screens/main/profile_page.dart';
import 'package:note_sphere/utils/colors.dart';

class NoteApp extends StatefulWidget {
  @override
  _NoteAppState createState() => _NoteAppState();
}

class _NoteAppState extends State<NoteApp> {
  final NoteTreeView noteTreeView = NoteTreeView();
  final FirestoreDatastore datastore = FirestoreDatastore();
  List<Node> treeNodes = [];
  TreeViewController _treeViewController = TreeViewController(children: []);
  quill.QuillController _quillController = quill.QuillController.basic();
  String? selectedNodeKey;
  String? selectedNoteTitle;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    List<Node> nodes = await noteTreeView.getTreeNodes();
    setState(() {
      treeNodes = nodes;
      _treeViewController = TreeViewController(children: treeNodes);
    });
  }

  void _addFolder() async {
    TextEditingController folderNameController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Folder'),
          content: TextField(
            controller: folderNameController,
            decoration: InputDecoration(hintText: 'Folder Name'),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (folderNameController.text.isNotEmpty) {
                  await datastore.AddFolder(folderNameController.text);
                  loadData();
                }
                Navigator.of(context).pop();
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _addNote() async {
    TextEditingController noteTitleController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Tambah Note'),
          content: TextField(
            controller: noteTitleController,
            decoration: InputDecoration(hintText: 'Judul Catatan'),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (noteTitleController.text.isNotEmpty) {
                  await datastore.AddNote(
                    'Hi silahkan isi note anda', // subtitle
                    noteTitleController.text,
                    0, // image placeholder
                  );
                  loadData();
                }
                Navigator.of(context).pop();
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _addNoteToFolder(String folderId) async {
    TextEditingController noteTitleController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Tambah Note'),
          content: TextField(
            controller: noteTitleController,
            decoration: InputDecoration(hintText: 'Judul Catatan'),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (noteTitleController.text.isNotEmpty) {
                  await datastore.AddNoteToFolder(
                    folderId,
                    'Hi silahkan isi note anda', // subtitle
                    noteTitleController.text,
                    0, // image placeholder
                  );
                  loadData();
                }
                Navigator.of(context).pop();
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _loadNoteContent(String noteId, bool isFolderNote) async {
    try {
      DocumentSnapshot noteDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection(isFolderNote ? 'notesFolder' : 'notes')
          .doc(noteId)
          .get();
      if (noteDoc.exists) {
        final noteData = noteDoc.data() as Map<String, dynamic>;
        final dynamic subtitle = noteData['subtitle'];
        final dynamic title = noteData['title'];

        setState(() {
          selectedNoteTitle = title as String?;
          // Initialize with an empty document
          _quillController = quill.QuillController(
            document: quill.Document.fromJson([
              {"insert": "\n"}
            ]), // Default to a new line to avoid empty document error
            selection: const TextSelection.collapsed(offset: 0),
          );

          if (subtitle is String) {
            _quillController = quill.QuillController(
              document: quill.Document.fromJson(jsonDecode(subtitle)),
              selection: const TextSelection.collapsed(offset: 0),
            );
          } else {
            print('Error: subtitle is not a string.');
          }
        });
      }
    } catch (e) {
      print('Error loading note content: $e');
    }
  }

  void _saveNoteContent(String noteId, bool isFolderNote) async {
    try {
      final json = jsonEncode(_quillController.document.toDelta().toJson());
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection(isFolderNote ? 'notesFolder' : 'notes')
          .doc(noteId)
          .update({'subtitle': json});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Note saved successfully')),
      );
    } catch (e) {
      print('Error saving note content: $e');
    }
  }

  void _toggleFolderExpansion(String nodeKey) {
    setState(() {
      treeNodes = treeNodes.map((node) {
        if (node.key == nodeKey) {
          return node.copyWith(expanded: !node.expanded);
        } else if (node.children != null) {
          return node.copyWith(
            children: node.children!.map((child) {
              if (child.key == nodeKey) {
                return child.copyWith(expanded: !child.expanded);
              }
              return child;
            }).toList(),
          );
        }
        return node;
      }).toList();
      _treeViewController = _treeViewController.copyWith(children: treeNodes);
    });
  }

  void _deleteFolder(String folderId) async {
    await datastore.deleteFolder(folderId);
    loadData();
    setState(() {
      selectedNoteTitle == null;
    });
  }

  void _deleteNote(String noteId, bool isFolderNote, [String? folderId]) async {
    if (isFolderNote && folderId != null) {
      await datastore.deleteNoteFromFolder(folderId, noteId);
    } else {
      await datastore.deleteNote(noteId);
    }
    loadData();
    setState(() {
      selectedNoteTitle == null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: secondaryColor,
        title: Text(
          'Note App',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.create_new_folder),
            onPressed: _addFolder,
            color: Colors.white,
          ),
          IconButton(
            icon: Icon(Icons.note_add),
            onPressed: _addNote,
            color: Colors.white,
          ),
          IconButton(
            icon: Icon(Icons.person),
            color: Colors.white,
            onPressed: () {
              if (user != null) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ProfilePage(user: user),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('No user is currently signed in')),
                );
              }
            },
          ),
        ],
      ),
      body: Row(
        children: [
          Expanded(
            flex: 2,
            child: TreeView(
              controller: _treeViewController,
              allowParentSelect: true,
              supportParentDoubleTap: true,
              onNodeTap: (key) {
                setState(() {
                  selectedNodeKey = key;
                });
                bool isFolderNote = treeNodes.any((node) =>
                    node.children != null &&
                    node.children!.any((child) => child.key == key));
                _loadNoteContent(key, isFolderNote);
              },
              nodeBuilder: (context, node) {
                return Row(
                  children: [
                    Icon(node.icon),
                    SizedBox(width: 8),
                    Expanded(child: Text(node.label)),
                    if (node.data == true) ...[
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          _addNoteToFolder(node.key);
                        },
                      ),
                    ],
                    if (node.isParent) ...[
                      IconButton(
                        icon: Icon(
                          node.expanded
                              ? Icons.arrow_drop_up
                              : Icons.arrow_drop_down,
                        ),
                        onPressed: () {
                          _toggleFolderExpansion(node.key);
                        },
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
          VerticalDivider(width: 1),
          Expanded(
            flex: 5,
            child: selectedNoteTitle == null
                ? Center(
                    child: Text(
                      'Please select a note',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  )
                : Column(
                    children: [
                      if (selectedNoteTitle != null)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            selectedNoteTitle!,
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                      Divider(),
                      quill.QuillToolbar.simple(
                        configurations: quill.QuillSimpleToolbarConfigurations(
                          controller: _quillController,
                          sharedConfigurations:
                              const quill.QuillSharedConfigurations(
                            locale: Locale('en'),
                          ),
                        ),
                      ),
                      Expanded(
                        child: quill.QuillEditor.basic(
                          configurations: quill.QuillEditorConfigurations(
                            controller: _quillController,
                            // readOnly: false, // Make the editor editable
                            autoFocus: false,
                            expands: false,
                            // focusNode: FocusNode(),
                            // scrollController: ScrollController(),
                            padding: EdgeInsets.all(10),
                            scrollable: true,
                            showCursor: true,
                            // readOnly: false,
                            sharedConfigurations:
                                const quill.QuillSharedConfigurations(
                                    // locale: Locale('de'),
                                    ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: ElevatedButton(
                            onPressed: () {
                              if (selectedNodeKey != null) {
                                bool isFolderNote = treeNodes.any((node) =>
                                    node.children != null &&
                                    node.children!.any((child) =>
                                        child.key == selectedNodeKey));
                                _saveNoteContent(
                                    selectedNodeKey!, isFolderNote);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: secondaryColor,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text('Save Note'),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
