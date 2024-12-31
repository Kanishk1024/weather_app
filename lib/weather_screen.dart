import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
import 'package:weather_app/additional_info.dart';
import 'package:weather_app/hourly_forecast_card.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/imp_keys.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late Future<Map<String, dynamic>> weather;

  Future<Map<String, dynamic>> getCurrentWhether() async {
    try {
      String cityName = "London";
      final res = await http.get(Uri.parse(
          "https://api.openweathermap.org/data/2.5/forecast?q=$cityName,uk&APPID=$apiKey"));
      final data = jsonDecode(res.body);

      if (data['cod'] != '200') {
        throw "An unexpected error ocurred";
      }
      return data;
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  void initState() {
    super.initState();
    weather = getCurrentWhether();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Weather App",
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          // Icon(Icons.refresh_sharp),
          IconButton(
            onPressed: () {
              setState(() {
                weather = getCurrentWhether();
              });
            },
            icon: Icon(Icons.refresh_sharp),
          ),
        ],
      ),
      body: FutureBuilder(
        future: weather,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator.adaptive());
          }
          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          }

          final data = snapshot.data!;
          final currentWeatherData = data["list"][0];
          final currentTemp = currentWeatherData["main"]["temp"];
          final currentWeather = currentWeatherData["weather"][0]["main"];
          final currentHumidity = currentWeatherData["main"]["humidity"];
          final currentPressure = currentWeatherData["main"]["pressure"];
          final currentWindSpeed = currentWeatherData["wind"]["speed"];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Box
                SizedBox(
                  width: double.infinity,
                  // Card is like a container with elevation
                  child: Card(
                    elevation: 30,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "${(currentTemp - 273).toStringAsFixed(2)} ºC",
                                style: const TextStyle(
                                  fontSize: 38,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Icon(
                                currentWeather == "Clouds" ||
                                        currentWeather == "Rain"
                                    ? Icons.cloud
                                    : Icons.sunny,
                                size: 65,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                currentWeather,
                                style: const TextStyle(fontSize: 28),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                //Weather Forecast
                const Text(
                  "Hourly Forecast",
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                // SingleChildScrollView(
                //   scrollDirection: Axis.horizontal,
                //   child: Row(
                //     children: [
                //       for (int i = 0; i < 5; i++)
                //         HourlyForecastCard(
                //           time: data["list"][i + 1]["dt"].toString(),
                //           temp: data["list"][i + 1]["main"]["temp"].toString(),
                //           icon: data["list"][i + 1]["weather"][0]["main"] ==
                //                       "Clouds" ||
                //                   data["list"][i + 1]["weather"][0]["main"] ==
                //                       "Rain"
                //               ? Icons.cloud
                //               : Icons.sunny,
                //         ),
                //     ],
                //   ),
                // ),
                SizedBox(
                  height: 150,
                  child: ListView.builder(
                    itemCount: 5,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      final hourlyForecast = data["list"][index + 1];
                      final time = DateTime.parse(hourlyForecast["dt_txt"]);
                      return HourlyForecastCard(
                        time: DateFormat.j().format(time),
                        temp:
                            "${(hourlyForecast["main"]["temp"] - 273).toStringAsFixed(2)} ºC",
                        icon: hourlyForecast["weather"][0]["main"] ==
                                    "Clouds" ||
                                hourlyForecast["weather"][0]["main"] == "Rain"
                            ? Icons.cloud
                            : Icons.sunny,
                      );
                    },
                  ),
                ),

                const SizedBox(height: 25),

                // Additional Info
                const Text(
                  "Additional Information",
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    AdditionalInfo(
                      icon: Icons.water_drop,
                      label: "Humidity",
                      value: currentHumidity.toString(),
                    ),
                    AdditionalInfo(
                      icon: Icons.air,
                      label: "Wind Speed",
                      value: currentWindSpeed.toString(),
                    ),
                    AdditionalInfo(
                      icon: Icons.beach_access,
                      label: "Pressure",
                      value: currentPressure.toString(),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
