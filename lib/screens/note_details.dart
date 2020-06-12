import 'package:NoteKeeper/screens/note_list.dart';
import 'package:flutter/material.dart';
import 'package:NoteKeeper/models/note.dart';
import 'package:NoteKeeper/utils/database_helper.dart';
import 'package:intl/intl.dart';

class NoteDetail extends StatefulWidget{
  
  final String appTitle; 
  Note note;
  NoteDetail(this.note,this.appTitle);
  @override
  State<StatefulWidget> createState() {
    return NoteDetailState(this.note,this.appTitle);
  }
}

class NoteDetailState extends State<NoteDetail>{
  static var priorities=['High','Low']; 
  TextEditingController titlecontroller=TextEditingController();
  TextEditingController descriptioncontroller=TextEditingController();
  var appTitle;
  Note note;
  DatabaseHelper databaseHelper=DatabaseHelper();
  NoteDetailState(this.note,this.appTitle);
  @override
  Widget build(BuildContext context) {
    TextStyle textStyle=Theme.of(context).textTheme.headline6;
    titlecontroller.text=note.title;
    descriptioncontroller.text=note.description;

      return Scaffold(
        appBar:AppBar(title: Text(appTitle),),
        body: Padding(
          padding:EdgeInsets.only(top:15.0,left: 10.0,right:10.0),
          child: ListView(
            children: <Widget>[
              ListTile(
                title:DropdownButton(
                  items: priorities.map((String dropDownStringItem){
                    return DropdownMenuItem<String>(
                      value: dropDownStringItem,
                      child:Text(dropDownStringItem) ,
                      );
                  }).toList(),
                    style: textStyle,
                    value: getPriorityAsString(note.priority),

                  onChanged:(valueSelectedByUser){
                    setState(() {
                      debugPrint('User Selected $valueSelectedByUser');
                      updatePriorityAsInt(valueSelectedByUser);
                    });
                  }
                  ) ,
              ),

              Padding(
                padding: EdgeInsets.only(top:15.0,left:10.0,right:10.0),
                child: TextField(
                  controller: titlecontroller,
                  style: textStyle,
                  onChanged: (value){
                    //debugPrint('title textField taped');
                    updateTitle();
                  },
                  decoration: InputDecoration(
                    labelText: 'Title',
                    labelStyle: textStyle,
                    hintText: 'Enter the title of your note',
                    border:OutlineInputBorder(
                      borderRadius:BorderRadius.circular(5.0),
                    ),
                  ),
                ),
                ),


                 Padding(
                padding: EdgeInsets.only(top:15.0,left:10.0,right:10.0),
                child: TextField(
                  
                  controller: descriptioncontroller,
                  style: textStyle,
                  
                  onChanged: (value){
                    //debugPrint('description textField taped');
                    updateDescription();
                  },
                  decoration: InputDecoration(
                    labelText: 'Description',
                    labelStyle: textStyle,
                    hintText: 'Enter the description of your note',
                    //contentPadding: const EdgeInsets.only(bottom: 40.0),
                    border:OutlineInputBorder(
                      borderRadius:BorderRadius.circular(5.0),
                      
                    ),
                  ),
                ),
                ),

                Padding(
                  padding: EdgeInsets.only(top:15.0,left:10.0,right:10.0),
                  child: Row(
                    children:<Widget> [
                      Expanded(
                        child:RaisedButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          ),
                        color: Theme.of(context).primaryColorDark,
                        textColor: Theme.of(context).primaryColorLight,
                        child: Text(
                          'Save',
                          textScaleFactor: 1.5,

                        ),
                        onPressed:(){
                          //debugPrint:('Saved button Clicked');
                          _savetoDatabase();
                        }
                        ),),

                        Container(width:10.0),
                       Expanded(
                        child:RaisedButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          ),
                        color: Theme.of(context).primaryColorDark,
                        textColor: Theme.of(context).primaryColorLight,
                        child: Text(
                          'Delete',
                          textScaleFactor: 1.5,

                        ),
                        onPressed:(){
                          //debugPrint:('Delete button Clicked');
                          _deleteFromDatabase();
                        }
                        ),),
                    ],),
                  )
            ], 
          ),
        ),
      );
  }
  void moveToLastScreen() {
		Navigator.pop(context, true);
  }

  //convert String priority in the form of integer before saving it to database
    void updatePriorityAsInt(String value){
      switch(value){
        case 'High':
          note.priority=1;
          break;
        case 'Low':
          note.priority=2;
          break;
      }
    }

    //convert int value of priority to String value
    String getPriorityAsString(int value){
      String priority;
      switch(value){
        case 1:
          priority=priorities[0]; //high
          break;
        case 2:
          priority=priorities[1]; //low
          break;
      }
      return priority;
    }

    //update the title of the project
    void updateTitle(){
      note.title=titlecontroller.text;
    }
    //update description of the project
    void updateDescription(){
      note.description=descriptioncontroller.text;
    }

    //save to Database

    void _savetoDatabase() async{
      moveToLastScreen();
      int result;
      note.date=DateFormat.yMMMd().format(DateTime.now());
      if(note.id!=null){
        result=await databaseHelper.updateNote(note); //case 1:update Operation
      }else{
        result=await databaseHelper.insertNote(note);//case 2 Insert Opeartion
      }
      if(result!=0){
        _showAlertDialog('Status','Note Saved Successfully');
      }else{
        _showAlertDialog('Status','Problem in saving Data');
      }
    }

    void _showAlertDialog(String title,String msg){
        AlertDialog alertDialog=AlertDialog(
          title: Text(title),
          content: Text(msg),
        );

        showDialog(
          context: context,
          builder: (_)=>alertDialog,
          );
    }

    //Delete From Database

    void _deleteFromDatabase() async{
      moveToLastScreen();
      int result;
      if(note.id!=null){
        result=await databaseHelper.deleteNote(note.id);
      }else{
        _showAlertDialog('Status', 'No Note was Deleted');
      }
      if(result!=0){
        _showAlertDialog('Status','Note Deleted Successfully');
      }else{
        _showAlertDialog('Status','Problem Occurred in Deleting Data');
      }
    }
}