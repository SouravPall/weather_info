import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_info/provider/weather_provider.dart';
import 'package:weather_info/utils/constants.dart';
import 'package:weather_info/utils/helper_function.dart';
import 'package:weather_info/utils/location_utils.dart';
import 'package:weather_info/utils/text_styles.dart';

class WeatherPage extends StatefulWidget {
  static const String routeName = '/';
  const WeatherPage({Key? key}) : super(key: key);

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {

  late WeatherProvider provider;
  bool isFirst = true;
  @override
  void didChangeDependencies() {
    if(isFirst){
      provider = Provider.of<WeatherProvider>(context);
      _getData();
      isFirst = false;
    }
    super.didChangeDependencies();
  }

  _getData() {
    determinePosition().then((position){
      provider.setNewLocation(position.latitude, position.longitude);
      provider.getWeatherData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.blueGrey.shade900,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(''),
        leading: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search)
        ),
        actions: [
          IconButton(
              onPressed: () {},
              icon: const Icon(Icons.location_searching)
          ),
          IconButton(
              onPressed: () {},
              icon: const Icon(Icons.settings)
          )
        ],
      ),
      body: Center(
            child: provider.hasDataLoaded ? Stack(
              children: [
                Image.asset(
                  'images/img.png',
                  fit: BoxFit.cover,
                  height: double.infinity,
                  width: double.infinity,
                ),
                Container(decoration: const BoxDecoration(color: Colors.black54),),
                ListView(
                  padding: const EdgeInsets.all(8),
                  children: [
                    _currentWeatherSection(),
                    _forecastWeatherSection(),
                  ],
                )
              ],
            ) :
               const Text('Please Wait...',style: textNormal16,),
          ),
    );
  }

  Widget _currentWeatherSection() {
    final response = provider.currentResponseModel;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children:[
        const SizedBox(height: 100,),
        Text(getFormattedDateTime(response!.dt!, 'MMM  dd, yyyy'), style: textDateHeader18,),
        const SizedBox(height: 10,),
        Text('${response.name},${response.sys!.country}', style: textAddress24,),
        Padding(
          padding: const EdgeInsets.all(7),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.network('$iconPrefix${response.weather![0].icon}$iconSuffix', fit: BoxFit.cover,color: Colors.white,),
              Text('${response.main!.temp!.round()}$degree$celsius', style: textTempBig80,),
            ],
          ),
        ),
        Column(
          children: [
            Text('Feels Like ${response.main!.feelsLike!.round()}$degree$celsius', style: textNormal16,),
            const SizedBox(height: 8,),
            Text('${response.weather![0].main}, ${response.weather![0].description}', style: textNormal16,),
          ],
        ),
        const SizedBox(height: 10,),
        Wrap(
          children: [
            Text('Humidity: ${response.main!.humidity}%', style: textNormal16White54,),
            const SizedBox(width: 10,),
            Text('Pressure: ${response.main!.pressure}hPa', style: textNormal16White54,),
          ],
        ),
      ],
    );
  }

  Widget _forecastWeatherSection() {
    return const Center();
  }
}
