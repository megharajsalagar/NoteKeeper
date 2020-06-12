import 'package:flutter/material.dart';
import './note_details.dart';
import 'package:NoteKeeper/models/note.dart';
import 'package:NoteKeeper/utils/database_helper.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';


class NoteList extends StatefulWidget{

  @override
  State<StatefulWidget> createState() {
    return NoteListState();
  }
}
class NoteListState extends State<NoteList>{
   DatabaseHelper databaseHelper=DatabaseHelper();
  List<Note> notelist;
  int count=0;

  @override
  Widget build(BuildContext context) {
    if(notelist==null){
      notelist=List<Note>();
      updateListView();
    }
      return Scaffold(
        appBar:AppBar(title:Text("NoteKeeper")),
        body: getNoteListView(),
        floatingActionButton: FloatingActionButton(
          onPressed: (){
            debugPrint('FAB Clicked');
            navigate(Note('','',2),'Add Note');
          },
          tooltip: 'Add Note',

          child: Icon(Icons.add),
        ),
      ); 
  }

  ListView getNoteListView(){
    TextStyle textStyle=Theme.of(context).textTheme.subtitle1;
    return ListView.builder(
      itemCount: count,
      itemBuilder: (BuildContext context,int position){
        return Card(
          color: Colors.white,
          elevation: 2.0,
          child: ListTile(
           leading:CircleAvatar(
             backgroundColor: getPriorityColor(this.notelist[position].priority),
             child: getPriorityIcon(this.notelist[position].priority),
           ) ,  
           title: Text(this.notelist[position].title,style: textStyle,),
           subtitle: Text(this.notelist[position].date,),
           trailing: GestureDetector(
             child:Icon(Icons.delete,color:Colors.grey),
             onTap: (){
               _delete(context, notelist[position]);
             } ,
             ),
           onTap: (){
             debugPrint('tile is tapped');
              navigate(this.notelist[position],'Edit Note');
           },
          ),
        );
      },
    );
  }


  //Return the priority color
    Color getPriorityColor(int priority){
      switch(priority){
        case 1:
          return Colors.red;
          break;
        case 2:
          return Colors.yellow;
          break;
        default:
          return Colors.yellow;
      }
    }

  //Return the priority icon
  Icon getPriorityIcon(int priority){
    switch(priority){
      case 1:
          return Icon(Icons.play_arrow);
          break; 
      case 2:
          return Icon(Icons.keyboard_arrow_right);
          break;
      default:
          return Icon(Icons.keyboard_arrow_right);
    }
 }
  
  void _delete(BuildContext context,Note note) async{
    int result= await databaseHelper.deleteNote(note.id);
    if(result!=0) {
      _showSnackBar(context,'Note Deleted Successfully');
      updateListView();
    }
  }

  void _showSnackBar(BuildContext context,String msg){
    final snackBar=SnackBar(content: Text(msg),);
    Scaffold.of(context).showSnackBar(snackBar);
  }

  void navigate(Note note,String title) async{
     bool result=await Navigator.push(context, MaterialPageRoute(builder: (context){
              return NoteDetail(note,title); 
            },));
      if(result==true){
        updateListView();
      }
  }

  void updateListView(){
    final Future<Database> db=databaseHelper.intializeDatabase();
    db.then((database) {
      Future<List<Note>> notelistFuture=databaseHelper.getNoteList();
      notelistFuture.then((notelist){
        setState(() {
          this.notelist=notelist;
          this.count=notelist.length; 
        });
      });
    });
  }
}