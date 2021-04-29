import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore_all/cloud_firestore_all.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:app07_chat_firebase/meus_widgets.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Firestore.instance.collection("teste").document("docteste3").setData({"campoteste" : "testin"});

  runApp(MyApp());
}

final googleSignIn = GoogleSignIn();
final auth = FirebaseAuth.instance;

Future<Null> ensureLoggedIn() async {
  GoogleSignInAccount user = googleSignIn.currentUser;
  if (user == null) user = await googleSignIn.signInSilently();
  if (user == null) user = await googleSignIn.signIn();
  ////
  if (await auth.currentUser() == null) {
    GoogleSignInAuthentication crredentials =
        await googleSignIn.currentUser.authentication;
    await auth.signInWithCredential(GoogleAuthProvider.getCredential(
        idToken: crredentials.idToken, accessToken: crredentials.accessToken));
  }
}

handleSubmitted(String text) async {
  await ensureLoggedIn();
  sendMessage(text: text);
}

void sendMessage({String text, String imgUrl}) {
  if ((text != null && text.isNotEmpty) ||
      (imgUrl != null && imgUrl.isNotEmpty))
    firestoreInstance.collection("messages").add({
      "text": text,
      "imgUrl": imgUrl,
      "senderName": googleSignIn.currentUser.displayName,
      "senderPhotoUrl": googleSignIn.currentUser.photoUrl,
      "senderDate": new DateTime.now().toIso8601String()
    });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: plataformaIOS(context) ? kIOSTheme : kDefaultTheme,
      home: ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: true,
      top: true,
      child: Scaffold(
        appBar: AppBar(
          title: Text('My Chat - IGS'),
          centerTitle: true,
          elevation: plataformaIOS(context) ? 0.0 : 4.0,
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              child: StreamBuilder(
                stream: firestoreInstance
                    .collection("messages")
                    .orderBy("senderDate")
                    .getDocuments().asStream(),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                    case ConnectionState.waiting:
                      return Center(child: CircularProgressIndicator());

                      break;
                    default:
                      return ListView.builder(
                        reverse: true,
                        itemCount: snapshot.data.docs.length,
                        itemBuilder: (context, index) {
                          List r = snapshot.data.docs.reversed.toList();
                          return ChatMessage(r[index].data);
                        },
                      );
                  }
                },
              ),
            ),
            Divider(height: 10.0),
            Container(
              decoration: BoxDecoration(color: Theme.of(context).cardColor),
              child: TextComposer(),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatMessage extends StatelessWidget {
  final Map<String, dynamic> data;

  ChatMessage(this.data);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundImage: NetworkImage(data["senderPhotoUrl"]),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(data["senderName"],
                    style: Theme.of(context).textTheme.subhead),
                Container(
                  margin: const EdgeInsets.only(top: 5.0),
                  child: data["imgUrl"] != null
                      ? Image.network(data["imgUrl"], width: 250.0)
                      : Text(data["text"]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
