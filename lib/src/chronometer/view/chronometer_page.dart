import 'package:chronometer_bloc_example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/chronometer_bloc.dart';
import '../../../ticker.dart';
import '../chronometer.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class TimerPage extends StatelessWidget {
  const TimerPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TimerBloc(ticker: Ticker()),
      child: const TimerView(),
    );
  }
}

class TimerView extends StatelessWidget {
  const TimerView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chronometer Bloc Example')),
      body: Stack(
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const <Widget>[
              Padding(
                  padding: EdgeInsets.symmetric(vertical: 100.0),
                  child: Center(
                    child: TimerText(),
                  )),
              Actions(),
            ],
          )
        ],
      ),
    );
  }
}

class TimerText extends StatelessWidget {
  const TimerText({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(_chronometerString(context));
  }
}

String _chronometerString(BuildContext context) {
  final timerBloc = BlocProvider.of<TimerBloc>(context);
  final duration = context.select((TimerBloc bloc) => bloc.state.duration);
  final hoursStr =
      (((duration / 1000) / 3600) % 60).floor().toString().padLeft(2, '0');
  final minutesStr =
      (((duration / 1000) / 60) % 60).floor().toString().padLeft(2, '0');
  final secondsStr =
      ((duration / 1000) % 60).floor().toString().padLeft(2, '0');
  final millisecondsStr =
      ((duration % 1000) / 10).floor().toString().padLeft(2, '0');
  return '$hoursStr:$minutesStr:$secondsStr:$millisecondsStr';
}

class Actions extends StatelessWidget {
  const Actions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TimerBloc, TimerState>(
        buildWhen: (prev, state) => prev.runtimeType != state.runtimeType,
        builder: (context, state) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              if (state is TimerInitial) ...[
                FloatingActionButton(
                    child: Icon(Icons.play_arrow),
                    onPressed: () async {
                      context
                          .read<TimerBloc>()
                          .add(TimerStarted(duration: state.duration));
                      await _showMessaginNotification(context);
                    }),
              ],
              if (state is TimerRunInProgress) ...[
                FloatingActionButton(
                    child: Icon(Icons.pause),
                    onPressed: () =>
                        context.read<TimerBloc>().add(TimerPaused())),
                FloatingActionButton(
                    child: Icon(Icons.replay),
                    onPressed: () =>
                        context.read<TimerBloc>().add(TimerReset()))
              ],
              if (state is TimerRunPause) ...[
                FloatingActionButton(
                    child: Icon(Icons.play_arrow),
                    onPressed: () =>
                        context.read<TimerBloc>().add(TimerResumed())),
                FloatingActionButton(
                    child: Icon(Icons.replay),
                    onPressed: () =>
                        context.read<TimerBloc>().add(TimerReset()))
              ],
            ],
          );
        });
  }

  Future<void> _showMessaginNotification(BuildContext context) async {
    const Person chronometer = Person(
        name: 'Chrometer',
        key: '1',
        uri: 'tel:584147118058',
        icon: FlutterBitmapAssetAndroidIcon('assets/icons/clock.png'));
    final List<Message> messages = <Message>[
      Message(_chronometerString(context), DateTime.now(), chronometer),
    ];
    final MessagingStyleInformation messagingStyleInformation =
        MessagingStyleInformation(chronometer,
            groupConversation: true,
            conversationTitle: 'Chronometer',
            htmlFormatContent: true,
            htmlFormatTitle: true,
            messages: messages);

    final AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('message channel id', 'message channel name',
            'message channel description',
            category: 'msg', styleInformation: messagingStyleInformation);
    final NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);

    await flutterLocalNotificationsPlugin.show(
        0, 'message title', 'message body', notificationDetails);
  }
}
