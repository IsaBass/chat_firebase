import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:app07_chat_firebase/main.dart';
import 'package:image_picker/image_picker.dart';

//// SEÇÃO DE ACESSORIOS
///
final ThemeData kIOSTheme = ThemeData(
  primarySwatch: Colors.orange,
  primaryColor: Colors.red[100],
  primaryColorBrightness: Brightness.light,
);

final ThemeData kDefaultTheme = ThemeData(
  primarySwatch: Colors.orange,
  accentColor: Colors.orangeAccent[400],
);


bool plataformaIOS(BuildContext context) {
  return (Theme.of(context).platform == TargetPlatform.iOS);
}

BoxDecoration boxDecorationTema(BuildContext context) {
  return Theme.of(context).platform == TargetPlatform.iOS
      ? BoxDecoration(border: Border(top: BorderSide(color: Colors.grey[200])))
      : BoxDecoration(
          border: Border(top: BorderSide(color: Colors.green[200])));
}

///fim seção acessorios



/// seção widget
/// 

class TextComposer  extends StatefulWidget {
  @override
  _TextComposerState createState() => _TextComposerState();
}

class _TextComposerState  extends State<TextComposer>  {

 //final Function funcHandleSubmitted(String text);

 // _TextComposerState(this.funcHandleSubmitted());

  bool _isComposing = false;

  final _textControler = TextEditingController();

  void _reset() {
    _textControler.clear();
    setState(() {
      _isComposing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return IconTheme(
      data: IconThemeData(color: Theme.of(context).accentColor),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        decoration: boxDecorationTema(context),
        child: Row(
          children: <Widget>[
            Container(
              child: IconButton(
                padding: EdgeInsets.all(10.0),
                icon: Icon(Icons.photo_camera),
                onPressed: () async {
                  await ensureLoggedIn();
                  File imgFile =
                      await ImagePicker.pickImage(source: ImageSource.camera);
                  //
                  StorageUploadTask task = FirebaseStorage.instance
                      .ref()
                      .child(googleSignIn.currentUser.id.toString() +
                          DateTime.now().millisecondsSinceEpoch.toString())
                      .putFile(imgFile);
                  StorageTaskSnapshot taskSnapshot = await task.onComplete;
                  String url = await taskSnapshot.ref.getDownloadURL();
                  sendMessage(imgUrl: url);
                },
              ),
            ),
            Expanded(
              child: TextField(
                controller: _textControler,
                decoration: InputDecoration.collapsed(hintText: "Enviar uma mensagem"),
                onChanged: (text) {
                  setState(() {
                    _isComposing = text.length > 0;
                  });
                },
                onSubmitted: (text) {
                  if(text != null && text.isNotEmpty) {
                  handleSubmitted(text);
                  _reset();
                  } 
                },
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              child: plataformaIOS(context)
                  ? CupertinoButton(
                      child: Text("enviar"),
                      onPressed: _isComposing
                          ? () {
                              handleSubmitted(_textControler.text);
                              _reset();
                            }
                          : null,
                    )
                  : IconButton(
                      icon: Icon(Icons.send),
                      onPressed: _isComposing
                          ? () {
                              handleSubmitted(_textControler.text);
                              _reset();
                            }
                          : null),
            ),
          ],
        ),
      ),
    );
  }
}

////