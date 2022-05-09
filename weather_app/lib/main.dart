import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weather_app/pages/main_screen/weather_app.dart';

void main() {
  runApp(const ProviderScope(
      child: MaterialApp(
    title: 'Weather App',
    debugShowCheckedModeBanner: false,
    home: WeatherApp(),
  )));
}
