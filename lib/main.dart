import 'package:flutter/material.dart';
import './screens/note_list.dart';
//import './screens/note_details.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title:"NoteKeeper",
      home:NoteList(),
      theme: ThemeData(
        primarySwatch:Colors.deepPurple,
      ),
    ),
  ); 
}