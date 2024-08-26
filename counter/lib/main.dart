import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:counter/variables.dart';
import 'package:counter/pages/counter_app.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  doWhenWindowReady(() {
    const initialSize = defaultWindowSize;
    appWindow.minSize = initialSize;
    appWindow.size = initialSize;
    appWindow.title = "Simple Counter";
    // appWindow.alignment = Alignment.center;
    appWindow.show();
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Counter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: appColorScheme,
        useMaterial3: false,
      ),
      home: const Scaffold(
        body: CounterApp(),
      ),
    );
  }
}

final buttonColors = WindowButtonColors(
  iconNormal: const Color.fromARGB(255, 116, 116, 116),
  mouseOver: const Color.fromARGB(255, 240, 240, 240),
  mouseDown: const Color.fromARGB(255, 116, 116, 116),
  iconMouseOver: const Color.fromARGB(255, 116, 116, 116),
  iconMouseDown: const Color.fromARGB(255, 233, 233, 233),
);

final closeButtonColors = WindowButtonColors(
  mouseOver: const Color(0xFFD32F2F),
  mouseDown: const Color(0xFFB71C1C),
  iconNormal: Colors.black,
  iconMouseOver: Colors.white,
);

class WindowButtons extends StatelessWidget {
  const WindowButtons({super.key});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        MinimizeWindowButton(colors: buttonColors),
        MaximizeWindowButton(colors: buttonColors),
        CloseWindowButton(colors: closeButtonColors),
      ],
    );
  }
}
