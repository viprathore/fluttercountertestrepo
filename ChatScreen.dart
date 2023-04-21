import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rentors/bloc/ConversationBloc.dart';
import 'package:rentors/config/app_config.dart' as config;
import 'package:rentors/event/ChatEvent.dart';
import 'package:rentors/event/SendMessageEvent.dart';
import 'package:rentors/generated/l10n.dart';
import 'package:rentors/main.dart';
import 'package:rentors/model/UserModel.dart';
import 'package:rentors/model/chat/ChatModel.dart';
import 'package:rentors/state/BaseState.dart';
import 'package:rentors/state/ChatState.dart';
import 'package:rentors/state/OtpState.dart';
import 'package:rentors/util/Utils.dart';
import 'package:rentors/widget/ProgressIndicatorWidget.dart';
import 'package:rentors/widget/RentorGradient.dart';
import 'package:timeago/timeago.dart';

class ChatScreen extends StatefulWidget {
  final String recieverId;

  ChatScreen(this.recieverId);

  @override
  State createState() => new ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  double pixelRatio;
  double px;
  ConversationBloc mBloc;
  List<Chat> chat;
  String threadId;
  UserModel model;
  final TextEditingController textEditingController =
      new TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    mBloc = ConversationBloc();
    chat = List();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      model = await Utils.getUser();
      mBloc.add(ChatEvent(model.data.id, widget.recieverId, threadId));
      mBloc.listen((state) {
        if (state is ChatState) {
          chat.clear();
          chat.addAll(state.chat.data.reversed);
          threadId = state.threadId;
        }
      });
    });
    didReceiveLocalNotificationSubject.stream.listen((event) async {
      model = await Utils.getUser();
      mBloc.add(ChatEvent(model.data.id, widget.recieverId, threadId));
    });
  }

  Widget myChat(Chat chat) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
                bottomLeft: Radius.circular(10)),
            gradient: RentorGradient(),
          ),
          margin: EdgeInsets.all(10),
          padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
          child: Text(
            chat.message,
            style: TextStyle(color: config.Colors().white, fontSize: 15),
          ),
        ),
        Container(
          margin: EdgeInsets.only(left: 10, right: 10),
          child: Text(
              format(DateTime.fromMillisecondsSinceEpoch(
                  int.parse(chat.date) * 1000)),
              style: TextStyle(
                  color: config.Colors().statusGrayColor, fontSize: 12)),
        )
      ],
    );
  }

  Widget recievedChat(Chat chat) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
                bottomRight: Radius.circular(10)),
            gradient:
                LinearGradient(colors: [Color(0xFF3475F5), Color(0xFF0BC5F4)]),
          ),
          margin: EdgeInsets.all(10),
          padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
          child: Text(
            chat.message,
            style: TextStyle(color: config.Colors().white, fontSize: 15),
          ),
        ),
        Container(
          margin: EdgeInsets.only(left: 10, right: 10),
          child: Text(
              format(DateTime.fromMillisecondsSinceEpoch(
                  int.parse(chat.date) * 1000)),
              style: TextStyle(
                  color: config.Colors().statusGrayColor, fontSize: 12)),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.white,
      ),
      child: Scaffold(
          appBar: AppBar(
            elevation: 0,
            title: Text(S.of(context).owner),
          ),
          body: Column(children: <Widget>[
            Flexible(
                child: BlocProvider(
                    create: (BuildContext context) => ConversationBloc(),
                    child: BlocBuilder<ConversationBloc, BaseState>(
                        bloc: mBloc,
                        builder: (BuildContext context, BaseState state) {
                          if (state is LoadingState && chat.isEmpty) {
                            return ProgressIndicatorWidget();
                          } else {
                            return Container(
                              margin: EdgeInsets.only(top: 10, bottom: 10),
                              child: ListView.builder(
                                  reverse: true,
                                  itemBuilder: (context, index) {
                                    var item = chat[index];
                                    if (item.userId == model.data.id) {
                                      return myChat(chat[index]);
                                    } else
                                      return recievedChat(chat[index]);
                                  },
                                  itemCount: chat.length),
                            );
                          }
                        }))),
            new Divider(
              height: 1.0,
            ),
            new Container(
              decoration: new BoxDecoration(
                color: Theme.of(context).cardColor,
              ),
              child: _textComposerWidget(),
            )
          ])),
    );
  }

  void _handleSubmit(String text) async {
    if (text.trim().isNotEmpty) {
      var user = await Utils.getUser();
      mBloc.add(SendMessageEvent(
          user.data.id, widget.recieverId, threadId, 2, text, model.data.name));
      textEditingController.clear();
    } else {}
  }

  Widget _textComposerWidget() {
    return new IconTheme(
      data: new IconThemeData(color: Theme.of(context).primaryColor),
      child: new Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: new Row(
          children: <Widget>[
            new Flexible(
              child: new TextField(
                decoration: new InputDecoration.collapsed(
                    hintText: S.of(context).enterYourMessage),
                controller: textEditingController,
                onSubmitted: _handleSubmit,
              ),
            ),
            Hero(
              transitionOnUserGestures: true,
              tag: "chat_with_owner",
              child: new Container(
                margin: const EdgeInsets.symmetric(horizontal: 8.0),
                child: new IconButton(
                  color: config.Colors().orangeColor,
                  icon: new Icon(Icons.send),
                  onPressed: () => _handleSubmit(textEditingController.text),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
