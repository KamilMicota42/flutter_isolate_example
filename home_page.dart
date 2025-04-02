import 'dart:isolate';

import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Image.asset('assets/ball.gif'),
            ElevatedButton(
              onPressed: () {
                int data = calculate();
                print(data.toString());
              },
              child: Text("Calculate"),
            ),
            ElevatedButton(
              onPressed: () {
                calculateAsync().then((data) {
                  print("Async data: $data");
                });
                print("Async poszlo dalej");
              },
              child: Text("CalculateAsync"),
            ),
            ElevatedButton(
              onPressed: () async {
                final receivePort = ReceivePort();
                await Isolate.spawn(isolateFunction, {'message': 'Hello', 'sendPort': receivePort.sendPort});
                print("czeka na watek");
                final result = await receivePort.first;
                print('Odebrano w głównym wątku: $result');
              },
              child: Text("CalculateIsolate"),
            ),
            ElevatedButton(
              onPressed: () async {
                final receivePort = ReceivePort();
                await Isolate.spawn(sumNumbersFunction, {'message': 'SumIsolate', 'sendPort': receivePort.sendPort});
                receivePort.listen((message) {
                  print('Odebrano w głównym wątku listener: $message');
                });
                print('Posło dalej');
              },
              child: Text("CalculateIn two isolate"),
            ),
          ],
        ),
      ),
    );
  }

  int calculate() {
    int data = 0;
    for (int i = 0; i < 1000000000; i++) {
      data += i;
    }
    return data;
  }

  Future<int> calculateAsync() async {
    int data = 0;
    for (int i = 0; i < 1000000000; i++) {
      data += i;
    }
    return data;
  }

  void isolateFunction(Map<String, dynamic> params) {
    String message = params['message'];
    SendPort sendPort = params['sendPort'];

    int data = 0;
    for (int i = 0; i < 1000000000; i++) {
      data += i;
    }
    // Wysyłamy wynik z powrotem do głównego izolatu.
    sendPort.send('$message $data');
  }

  void sumNumbersFunction(Map<String, dynamic> params) async {
    String message = params['message'];
    SendPort sendPort = params['sendPort'];
    await Future.delayed(Duration(seconds: 4));

    int sum = 0;
    for (int i = 0; i < 1000000000; i++) {
      sum += i;
    }
    print("$message $sum");

    ReceivePort receivePort = ReceivePort();

    await Isolate.spawn(multipleNumbersFunction, {'sendPort': receivePort.sendPort, "sum": sum});
    receivePort.listen((message) {
      print('Odebrano w sum watku listener: $message');
      receivePort.close();
    });
    print('Posło dalej sum');
    sendPort.send(sum);
  }

  void multipleNumbersFunction(Map<String, dynamic> params) async {
    int sum = params['sum'];
    await Future.delayed(Duration(seconds: 4));
    for (int i = 1; i < 4; i++) {
      sum *= i;
    }
    print("Wynik mnożenia: $sum");
    SendPort sendPort = params['sendPort'];
    sendPort.send(sum);
  }
}
