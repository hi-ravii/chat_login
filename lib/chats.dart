
import 'package:chat_login/chatservices/chatservce.dart';
import 'package:chat_login/components/chat_bubble.dart';

import 'package:chat_login/components/my_textfield.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatPage extends StatefulWidget {
  final String  receiveruserEmail;
  final String  receiveruserUserId;
  const ChatPage({super.key ,  required this.receiveruserEmail, required this.receiveruserUserId});
  

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageContoller = TextEditingController();
  final ChatServices _chatServices = ChatServices();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  
  void sendMessage( ) async{
    if (_messageContoller.text.isNotEmpty) {
      //is there si a meessgae then only send the messgae
      await _chatServices.SendMessage(widget.receiveruserUserId, _messageContoller.text);
     // clea the message after sendng
     _messageContoller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(title: Text(widget.receiveruserEmail),),
      body: Column(
        children: [
          //messae=ge
          Expanded(
            child: _buildMessageList(),
            ),
          //User input
          _buildMessageinput(),
          const SizedBox(height: 20,)

               
        ],
      ),
    );
    }
    //bld message lst
  Widget _buildMessageList() {
  return StreamBuilder(
    stream: _chatServices.getMessages(
      widget.receiveruserUserId,_firebaseAuth.currentUser!.uid,
    ),
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return Text('Error${snapshot.error}');
      }
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Text('Loading..');
      }
      return ListView(
        children: snapshot.data!.docs.map((document) => _buildMessageItem(document)).toList(),
      );
    },
  );
}


    //build message item
    Widget _buildMessageItem(DocumentSnapshot document){
      Map<String,dynamic> data = document.data() as Map<String,dynamic>;
      var alignment =(data['senderId']== _firebaseAuth.currentUser!.uid)
      ?Alignment.centerRight:Alignment.centerLeft;
      return Container(
        alignment: alignment,

        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment:(data['senderId']== _firebaseAuth.currentUser!.uid)? CrossAxisAlignment.end: CrossAxisAlignment.start ,
           mainAxisAlignment:(data['senderId']== _firebaseAuth.currentUser!.uid)? MainAxisAlignment.end: MainAxisAlignment.start ,
            children: [
            Text(data['senderEmail']),
            const SizedBox(height: 5,),
            ChatBubble(message : data['message']),
          ],),
        )
      );

    }
    //bld message  input
    Widget _buildMessageinput(){
       return Padding(
         padding: const EdgeInsets.all(8.0),
         child: Row(
          children: [
            Expanded(
              child: MyTextField(
                controller: _messageContoller, 
                hintText: 'Enter message', 
                obscureText: false)
                ),
         
                IconButton(onPressed: sendMessage, icon: const Icon(Icons.arrow_upward, size: 40.0 ,),),
            ],),
       );
    }
    
    
    }