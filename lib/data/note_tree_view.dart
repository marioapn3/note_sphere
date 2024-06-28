import 'package:flutter/material.dart';
import 'package:flutter_treeview/flutter_treeview.dart';
import 'package:note_sphere/data/firestore_datastore.dart';
import 'package:note_sphere/model/folder.dart';
import 'package:note_sphere/model/note.dart';
import 'package:note_sphere/model/note_inside_folder.dart';

class NoteTreeView {
  final FirestoreDatastore datastore = FirestoreDatastore();

  Future<List<Node>> getTreeNodes() async {
    final data = await datastore.getAllNotesAndFolders();

    List<Folder> folders = data['folders'];
    List<Note> notes = data['notes'];
    List<NoteInsideFolder> notesInsideFolders = data['notesInsideFolders'];

    List<Node> treeNodes = [];

    for (var folder in folders) {
      List<Node> folderNotes = notesInsideFolders
          .where((note) => note.folderId == folder.folderId)
          .map((note) => Node(
                key: note.id,
                label: note.title,
                icon: Icons.note,
              ))
          .toList();

      treeNodes.add(Node(
        key: folder.folderId,
        label: folder.folderName,
        children: folderNotes,
        icon: Icons.folder,
        data: true,
      ));
    }

    for (var note in notes) {
      treeNodes.add(Node(
        key: note.id,
        label: note.title,
        icon: Icons.note,
      ));
    }

    return treeNodes;
  }
}
