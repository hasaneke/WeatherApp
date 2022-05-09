import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weather_app/data/models/weather_exception.dart';
import 'package:weather_app/data/models/weather_model.dart';
import 'package:weather_app/data/service/weather_api.dart';

final exceptionProvider = StateProvider<AppException?>((ref) {
  return null;
});
final weatherApiProvider = Provider<WeatherApi>((ref) {
  return WeatherApi();
});
final weatherNotifier =
    StateNotifierProvider<WeatherNotifier, AsyncValue<WeatherModel>>((ref) {
  return WeatherNotifier(null, ref.read);
});

class WeatherNotifier extends StateNotifier<AsyncValue<WeatherModel>> {
  Reader read;
  WeatherNotifier(AsyncValue<WeatherModel>? state, this.read)
      : super(state ?? const AsyncLoading()) {
    //fetchCityWeather(city: 'Ankara');
    fetchCurrentWeather();
  }

  Future<void> fetchCurrentWeather() async {
    state = const AsyncLoading();
    try {
      final currentLocWeather =
          await read(weatherApiProvider).getCurrentLocationWeather();
      state = AsyncData(currentLocWeather);
    } catch (e, st) {
      state = AsyncError(e);
    }
  }

  Future<void> fetchCityWeather({required String city}) async {
    AsyncValue<WeatherModel> cacheState = state;
    state = const AsyncLoading();

    try {
      final cityLocWeather =
          await read(weatherApiProvider).fetchCityWeather(city: city);
      state = AsyncData(cityLocWeather);
    } catch (e) {
      state = cacheState;
    }
  }
}
