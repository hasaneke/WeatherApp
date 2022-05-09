import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weather_app/data/models/weather_exception.dart';
import 'package:weather_app/data/models/weather_model.dart';
import 'package:weather_app/logic/weather_notifier.dart';

import '../../utilities/image_paths.dart';

class WeatherApp extends StatelessWidget {
  const WeatherApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WeatherAppBody(),
    );
  }
}

class WeatherAppBody extends HookConsumerWidget {
  WeatherAppBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AppException?>(exceptionProvider, (previous, next) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Something Happened'),
        duration: Duration(seconds: 1),
      ));
    });

    final _controller = useTextEditingController();
    return Stack(
      children: [_backGroundWidget(), _body(_controller, context)],
    );
  }

  SingleChildScrollView _body(
      TextEditingController controller, BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: SafeArea(child: Center(
        child: SizedBox(
          child: Consumer(
            builder: (context, ref, child) {
              final weatherState = ref.watch(weatherNotifier);
              return weatherState.when(data: (state) {
                return onDataWidget(state, controller, ref);
              }, error: (e, st) {
                return onErrorWidget(context, ref.read);
              }, loading: () {
                return onLoadingWidget(size);
              });
            },
          ),
        ),
      )),
    );
  }

  Center onLoadingWidget(Size size) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Column onDataWidget(
      WeatherModel state, TextEditingController controller, WidgetRef ref) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        const SizedBox(
          height: 80,
        ),
        Text(
          state.name!,
          style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w300),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 15),
          child: Text(
            '${(state.main!.temp! - 273).toInt()}°',
            style: const TextStyle(fontSize: 80, fontWeight: FontWeight.w200),
          ),
        ),
        Text(
          state.weather!.first.description!.toUpperCase(),
          style: const TextStyle(
            fontSize: 20,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 25, right: 25, top: 80),
          child: TextFormField(
            controller: controller,
            decoration: const InputDecoration(
                border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 5)),
                hintText: 'Enter a city'),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 50),
          child: ElevatedButton(
            onPressed: () {
              ref
                  .read(weatherNotifier.notifier)
                  .fetchCityWeather(city: controller.text);
            },
            child: const Text(
              'Search',
              style: TextStyle(color: Colors.black),
            ),
            style: ElevatedButton.styleFrom(primary: Colors.lime[200]),
          ),
        )
      ],
    );
  }

  SizedBox onErrorWidget(BuildContext context, Reader read) {
    return SizedBox(
      height: MediaQuery.of(context).size.height -
          MediaQuery.of(context).padding.top,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
                onPressed: () {
                  read(weatherNotifier.notifier).fetchCurrentWeather();
                },
                icon: const Icon(
                  Icons.refresh,
                  size: 45,
                )),
            const SizedBox(
              height: 25,
            ),
            const Text('Something Happened')
          ],
        ),
      ),
    );
  }

  Container _backGroundWidget() {
    return Container(
      decoration: const BoxDecoration(
          image: DecorationImage(
              opacity: 0.7,
              image: AssetImage(kBackgroundImage),
              fit: BoxFit.cover)),
    );
  }
}
