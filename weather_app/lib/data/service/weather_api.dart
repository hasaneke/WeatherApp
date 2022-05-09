import 'dart:convert';
import 'dart:developer';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:weather_app/data/models/weather_model.dart';

class WeatherApi {
  Uri _generateUrlForLatLong(
      {required double latitude, required double longitude}) {
    String url =
        "https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&appid=0adeb73794be5ed776d30c079c98f7e7";
    return Uri.parse(url);
  }

  Uri _generateURLforCityName({required String city}) {
    String url = "https://api.openweathermap.org/data/2.5/weather?q=" +
        city +
        "&appid=0adeb73794be5ed776d30c079c98f7e7";
    return Uri.parse(url);
  }

  Future<WeatherModel> getCurrentLocationWeather() async {
    if (await Permission.location.isGranted) {
      //log('granted');
    } else {
      await Permission.location.request();
      await Permission.locationWhenInUse.request();
    }

    Position position = await Geolocator.getCurrentPosition(
        forceAndroidLocationManager: true,
        desiredAccuracy: LocationAccuracy.best);
    // final pos = await Geolocator.getLastKnownPosition();
    var response = await http.get(_generateUrlForLatLong(
        latitude: position.latitude, longitude: position.longitude));
    final weather = WeatherModel.fromJson(jsonDecode(response.body));
    return weather;
  }

  Future<WeatherModel> fetchCityWeather({required String city}) async {
    var response = await http.get(_generateURLforCityName(city: city));
    log(response.body);
    final weather = WeatherModel.fromJson(jsonDecode(response.body));
    return weather;
  }
}
