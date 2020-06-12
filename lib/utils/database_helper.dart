import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:NoteKeeper/models/note.dart';

class DatabaseHelper{

  static DatabaseHelper _databaseHelper;
  static Database _database;


  String noteTable='note_table';
  String colId='id';
  String colTitle='title';
  String colDescription='description';
  String colPriority='priority';
  String colDate='date';



  DatabaseHelper._createInstance();
  factory DatabaseHelper(){
    if(_databaseHelper==null){
      _databaseHelper=DatabaseHelper._createInstance();
    }
    return _databaseHelper;
  }


    Future<Database> get database async{
      if(_database==null){
        _database=await intializeDatabase();
      }
      return _database;
    }

    Future<Database> intializeDatabase() async{

      Directory directory=await getApplicationDocumentsDirectory();
      String path=directory.path + 'notes.db';

      //open/create database at a given path
      var notesDatabase =await openDatabase(path,version:1,onCreate:_createDb);
      return notesDatabase;
    }


  void _createDb(Database db,int newVersion) async{
    await db.execute('CREATE TABLE $noteTable ($colId INTEGER PRIMARY KEY AUTOINCREMENT,$colTitle TEXT,$colDescription TEXT,$colPriority TEXT,$colDate TEXT)');
  }

  //Fetch Operarion:fetch all the values from the table
    Future<List<Map<String,dynamic>>> getNoteMapList() async{
      Database db=await this.database;
      var result=await db.rawQuery('SELECT * FROM $noteTable order by $colPriority ASC');
      return result;
    }

  //Insert Operation:Insert values into table
    Future<int>insertNote(Note note) async{
      Database db=await this.database;
      var result = await db.insert(noteTable, note.toMap());
      return result;
    }

  //Update Operation:Update a Note object and save it to database
    Future<int>updateNote(Note note) async{
      Database db=await this.database;
      var result=await db.update(noteTable, note.toMap(),where:'$colId=?',whereArgs:[note.id]);
      return result;
    }
  //Delete Operation:Delete a Note object from database
    Future<int>deleteNote(int id) async{
      Database db=await this.database;
      var result=await db.delete(noteTable,where: '$colId=$id');
      return result;
    }
    Future<int>getCount() async{
      Database db=await this.database;
      List<Map<String,dynamic>> x=await db.rawQuery('SELECT COUNT(*) FROM $noteTable');
      int result =Sqflite.firstIntValue(x);
      return result;

    }

    Future<List<Note>> getNoteList() async{
      var noteMapList=await getNoteMapList();
      int count =noteMapList.length;

      List<Note> notelist=List<Note>();
      for(int i=0;i<count;i++){
        notelist.add(Note.fromMapObject(noteMapList[i]));
      }
      return notelist;
    }



}