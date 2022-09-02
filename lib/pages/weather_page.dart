import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_info/pages/settings_page.dart';
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
    if (isFirst) {
      provider = Provider.of<WeatherProvider>(context);
      _getData();
      isFirst = false;
    }
    super.didChangeDependencies();
  }

  _getData() async {
    try {
      final position = await determinePosition();
      provider.setNewLocation(position.latitude, position.longitude);
      provider.setTempUnit(await provider.getPreferenceTempUnitValue());
      provider.getWeatherData();
    } catch (error) {
      rethrow;
    }
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
            onPressed: () async {
              final result =
                  await showSearch(context: context, delegate: _CitySearchDelegate());
              if(result != null && result.isNotEmpty) {
                //print(result);
                provider.convertAddressToLatLng(result);
              }
            },
            icon: const Icon(Icons.search)),
        actions: [
          IconButton(
              onPressed: () {}, icon: const Icon(Icons.location_searching)),
          IconButton(
              onPressed: () =>
                  Navigator.pushNamed(context, SettingsPage.routeName),
              icon: const Icon(Icons.settings))
        ],
      ),
      body: Center(
        child: provider.hasDataLoaded
            ? Stack(
                children: [
                  Image.asset(
                    'images/img.png',
                    fit: BoxFit.cover,
                    height: double.infinity,
                    width: double.infinity,
                  ),
                  Container(
                    decoration: const BoxDecoration(color: Colors.black26),
                  ),
                  ListView(
                    padding: const EdgeInsets.all(8),
                    children: [
                      _currentWeatherSection(),
                      _forecastWeatherSection(),
                    ],
                  )
                ],
              )
            : const Text(
                'Please Wait...',
                style: textNormal16,
              ),
      ),
    );
  }

  Widget _currentWeatherSection() {
    final response = provider.currentResponseModel;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          height: 90,
        ),
        Text(
          getFormattedDateTime(response!.dt!, 'MMM  dd, yyyy'),
          style: textDateHeader18,
        ),
        const SizedBox(
          height: 10,
        ),
        Text(
          '${response.name},${response.sys!.country}',
          style: textAddress26,
        ),
        Padding(
          padding: const EdgeInsets.all(7),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.network(
                '$iconPrefix${response.weather![0].icon}$iconSuffix',
                fit: BoxFit.cover,
              ),
              Text(
                '${response.main!.temp!.round()}$degree${provider.unitSymbol}',
                style: textTempBig80,
              ),
            ],
          ),
        ),
        Column(
          children: [
            Text(
              '${response.weather![0].main}',
              style: textCondition20,
            ),
            const SizedBox(
              height: 8,
            ),
            Text('${response.weather![0].description}', style: textNormal16,),
            const SizedBox(
              height: 10,
            ),
            Text(
              'Feels Like ${response.main!.feelsLike!.round()}$degree${provider.unitSymbol}',
              style: textNormal16,
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Wrap(
          children: [
            Text(
              'Humidity: ${response.main!.humidity}%',
              style: textNormal16White54,
            ),
            const SizedBox(
              width: 10,
            ),
            Text(
              'Pressure: ${response.main!.pressure}hPa',
              style: textNormal16White54,
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Wrap(
          children: [
            Text(
              'Visibility: ${response.visibility}meter',
              style: textNormal16White54,
            ),
            const SizedBox(
              width: 10,
            ),
            Text(
              'Wind: ${response.wind!.speed}m/s',
              style: textNormal16White54,
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Wrap(
          children: [
            Text(
              'Degree: ${response.wind!.deg}$degree',
              style: textNormal16White54,
            ),
            const SizedBox(
              width: 10,
            ),
            Text(
              'Clouds: ${response.clouds!.all}%',
              style: textNormal16White54,
            ),
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        Column(
          children: [
            Text(
              'Sun Rise  ${getFormattedDateTime(response.sys!.sunrise!, 'hh:mm a')}',
              style: textNormal16,
            ),
            const SizedBox(
              height: 8,
            ),
            Text(
              'Sun Set  ${getFormattedDateTime(response.sys!.sunset!, 'hh:mm a')}',
              style: textNormal16,
            ),
          ],
        )
      ],
    );
  }

  Widget _forecastWeatherSection() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      height: 160,
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: provider.forecastResponseModel!.list!.length,
          itemBuilder: (context, index) {
            final forecastM = provider.forecastResponseModel!.list![index];
            return Padding(
              padding: const EdgeInsets.only(left: 15),
              child: Container(
                height: 160,
                width: 160,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.13),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        getFormattedDateTime(forecastM.dt!, 'MMM dd,yyyy'),
                        style: textNormal16,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        getFormattedDateTime(forecastM.dt!, 'hh:mm a'),
                        style: textNormal16,
                      ),
                      Image.network(
                        '$iconPrefix${forecastM.weather![0].icon}$iconSuffix',
                        fit: BoxFit.cover,
                        height: 50,
                        width: 50,
                        color: Colors.white,
                      ),
                      Text(
                        '${forecastM.main!.temp!.round()} $degree${provider.unitSymbol}',
                        style: textNormal16,
                      ),
                      Chip(
                        backgroundColor: Colors.cyan[400],
                        label: Text(
                          forecastM.weather![0].description!,
                          style: textNormal16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
    );
  }


}

class _CitySearchDelegate extends SearchDelegate<String>{
  @override
  List<Widget>? buildActions(BuildContext context) {
    return[
      IconButton(
          onPressed: () {
            query = '';
          },
          icon: const Icon(Icons.clear),
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    IconButton(
      onPressed: () {
        close(context, '');
      },
      icon: const Icon(Icons.arrow_back),
    );
    return null;
  }

  @override
  Widget buildResults(BuildContext context) {
   return ListTile(
     leading: const Icon(Icons.search),
     title:  Text(query),
     onTap: (){
       close(context, query);
     },
   );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final filteredList = query.isEmpty ? cities :
        cities.where((city) => city.toLowerCase().startsWith(query.toLowerCase())).toList();
    return ListView.builder(
        itemCount: filteredList.length,
        itemBuilder: (context, index) => ListTile(
          title: Text(filteredList[index]),
          onTap: () {
            query = filteredList[index];
            close(context, query);
          },
        )
    );
  }

}
