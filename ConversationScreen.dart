import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rentors/bloc/ConversationBloc.dart';
import 'package:rentors/config/app_config.dart' as config;
import 'package:rentors/event/ConversationEvent.dart';
import 'package:rentors/generated/l10n.dart';
import 'package:rentors/main.dart';
import 'package:rentors/model/chat/ConversationModel.dart';
import 'package:rentors/state/BaseState.dart';
import 'package:rentors/state/ConversationState.dart';
import 'package:rentors/util/Utils.dart';
import 'package:rentors/widget/CircularImageWidget.dart';
import 'package:rentors/widget/ProgressIndicatorWidget.dart';
import 'package:timeago/timeago.dart';

class ConversationScreen extends StatefulWidget {
  @override
  State createState() => new ChatScreenState();
}

class ChatScreenState extends State<ConversationScreen> {
  ConversationBloc mBloc = new ConversationBloc();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    didReceiveLocalNotificationSubject.stream.listen((event) {
      mBloc.add(ConversationEvent());
    });
    mBloc.add(ConversationEvent());
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  void navigate(String recieverId) async {
    await Navigator.of(context)
        .pushNamed("/chat", arguments: recieverId)
        .then((value) {
      mBloc.add(ConversationEvent());
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: config.Colors().color1C1E28,
      ),
      child: Scaffold(
          appBar: AppBar(
            iconTheme: IconThemeData(color: config.Colors().white),
            brightness: Brightness.dark,
            backgroundColor: config.Colors().color1C1E28,
            title: Text(
              S.of(context).chat,
              style: TextStyle(color: config.Colors().white),
            ),
          ),
          body: BlocProvider(
              create: (BuildContext context) => ConversationBloc(),
              child: BlocBuilder<ConversationBloc, BaseState>(
                  bloc: mBloc,
                  builder: (BuildContext context, BaseState state) {
                    if (state is ConversationState) {
                      ConversationModel model = state.home;
                      var item = model.data;
                      return Container(
                        child: ListView.separated(
                            separatorBuilder: (context, index) {
                              return Divider();
                            },
                            itemCount: item.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                onTap: () async {
                                  var user = await Utils.getUser();
                                  String senderId = item[index].senderId;
                                  if (senderId == user.data.id) {
                                    navigate(item[index].receiverId);
                                  } else {
                                    navigate(senderId);
                                  }
                                },
                                title: Text(item[index].firstName),
                                subtitle: Text(item[index].lastMsg),
                                trailing: Text(format(
                                    DateTime.fromMillisecondsSinceEpoch(
                                        item[index].date * 1000))),
                                leading:
                                    CircularImageWidget(50, item[index].image),
                              );
                            }),
                      );
                    } else {
                      return ProgressIndicatorWidget();
                    }
                  }))),
    );
  }
}
