import 'dart:async';
import 'dart:math';

import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stop_addiction/quotes.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  DateTime? startedDay;
  DateTime timeNow = DateTime.now();
  Timer? timer;
  // Get random quote
  Quote quote = quotes[Random().nextInt(quotes.length)];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      final prefs = await SharedPreferences.getInstance();
      final dayIsoString = prefs.getString('day');
      if (dayIsoString != null) {
        final day = DateTime.parse(dayIsoString);
        setState(() {
          startedDay = day;
        });
      }

      timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          timeNow = DateTime.now();
        });
      });

      initPlatformState();
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    // Configure BackgroundFetch.
    int status = await BackgroundFetch.configure(
        BackgroundFetchConfig(
          minimumFetchInterval: 60,
          stopOnTerminate: false,
          enableHeadless: true,
          requiresBatteryNotLow: false,
          requiresCharging: false,
          requiresStorageNotLow: false,
          requiresDeviceIdle: false,
          requiredNetworkType: NetworkType.NONE,
        ), (String taskId) async {
      // <-- Event handler
      // This is the fetch-event callback.
      debugPrint("[BackgroundFetch] Event received $taskId");

      // IMPORTANT:  You must signal completion of your task or the OS can punish your app
      // for taking too long in the background.
      BackgroundFetch.finish(taskId);
    }, (String taskId) async {
      // <-- Task timeout handler.
      // This task has exceeded its allowed running-time.  You must stop what you're doing and immediately .finish(taskId)
      debugPrint("[BackgroundFetch] TASK TIMEOUT taskId: $taskId");
      BackgroundFetch.finish(taskId);
    });
    debugPrint('[BackgroundFetch] configure success: $status');

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
  }

  int days() {
    if (startedDay == null) return 0;
    return timeNow.difference(startedDay!).inDays;
  }

  int hours() {
    if (startedDay == null) return 0;
    final date = startedDay!.add(Duration(days: days()));
    return timeNow.difference(date).inHours;
  }

  int minutes() {
    if (startedDay == null) return 0;
    final date = startedDay!.subtract(Duration(days: days(), hours: hours()));
    return timeNow.difference(date).inMinutes;
  }

  void setDay() {
    // set the date
    DatePicker.showDateTimePicker(
      context,
      locale: LocaleType.fr,
      showTitleActions: true,
      minTime: DateTime.now().subtract(const Duration(days: 7)),
      maxTime: DateTime.now().add(const Duration(minutes: 1)),
      onConfirm: (DateTime date) async {
        setState(() {
          startedDay = date;
        });
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('day', date.toIso8601String());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/background.png"),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (startedDay != null)
                  Align(
                    alignment: Alignment.center,
                    child: IconButton(
                      icon: const Icon(
                        Icons.timer_outlined,
                        size: 30.0,
                      ),
                      onPressed: () => setDay(),
                    ),
                  ),
                SizedBox(height: MediaQuery.of(context).size.height * .15),
                CustomPaint(
                  painter: ClockPainter(),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFEDCFFF),
                      shape: BoxShape.circle,
                    ),
                    width: MediaQuery.of(context).size.width * .6,
                    height: MediaQuery.of(context).size.width * .6,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (startedDay == null)
                          TextButton(
                            child: const Text(
                              "Cliquez ici\npour\ncommencer",
                              style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            onPressed: () => setDay(),
                          )
                        else ...[
                          Text(
                            "${days()} jours",
                            style: const TextStyle(
                              fontSize: 30.0,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF3198EF),
                            ),
                          ),
                          const SizedBox(height: 10.0),
                          if (hours() > 0)
                            Text(
                              "${hours()} heures",
                              style: const TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF3198EF),
                              ),
                            )
                          else
                            Text(
                              "${minutes()} minutes",
                              style: const TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF3198EF),
                              ),
                            ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                if (startedDay != null) ...[
                  Text(
                    '"${quote.quote}"',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 15.0),
                  Text(
                    quote.author,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                ],
                Expanded(
                  child: Center(
                    child: SvgPicture.asset(
                        "assets/Online Personal Trainer-rafiki.svg"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ClockPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0
      ..color = const Color(0xFFEDE2A8);
    final center = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(
      center,
      size.width / 2 + 15.0,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
