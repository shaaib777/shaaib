import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class WeatherPage extends StatefulWidget {
  final double latitude;
  final double longitude;

  const WeatherPage({
    super.key,
    required this.latitude,
    required this.longitude,
  });

  @override
  _WeatherPageState createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // بيانات الطقس الحالية
  String? _currentWeatherDescription;
  double? _currentTemperature;
  int? _currentHumidity;
  bool _isCurrentWeatherLoading = false;

  // بيانات الطقس التاريخي
  String? _historicalWeatherDescription;
  double? _historicalTemperature;
  String? _errorMessage;
  bool _isHistoricalWeatherLoading = false;

  final TextEditingController _timeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchCurrentWeather(widget.latitude, widget.longitude); // جلب الطقس الحالي عند التحميل
  }

  @override
  void dispose() {
    _tabController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  // دالة للحصول على بيانات الطقس الحالية
  Future<void> _fetchCurrentWeather(double lat, double lon) async {
    setState(() {
      _isCurrentWeatherLoading = true;
    });

    final apiKey = "YOUR_API_KEY"; // استبدل هذا بمفتاح API الخاص بك
    final url =
        "https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _currentWeatherDescription = data['weather'][0]['description'];
          _currentTemperature = data['main']['temp'];
          _currentHumidity = data['main']['humidity'];
        });
      } else {
        setState(() {
          _errorMessage = "Failed to fetch current weather data.";
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "An error occurred: $e";
      });
    } finally {
      setState(() {
        _isCurrentWeatherLoading = false;
      });
    }
  }

  // دالة للحصول على بيانات الطقس التاريخي
  Future<void> _fetchHistoricalWeather(int time) async {
    setState(() {
      _isHistoricalWeatherLoading = true;
    });

    final apiKey = "YOUR_API_KEY"; // استبدل هذا بمفتاح API الخاص بك
    final url =
        "https://api.openweathermap.org/data/3.0/onecall/timemachine?lat=${widget.latitude}&lon=${widget.longitude}&dt=$time&appid=$apiKey&units=metric";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _historicalWeatherDescription = data['current']['weather'][0]['description'];
          _historicalTemperature = data['current']['temp'];
          _errorMessage = null;
        });
      } else {
        setState(() {
          _errorMessage = "Failed to fetch historical weather data.";
          _historicalWeatherDescription = null;
          _historicalTemperature = null;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "An error occurred: $e";
        _historicalWeatherDescription = null;
        _historicalTemperature = null;
      });
    } finally {
      setState(() {
        _isHistoricalWeatherLoading = false;
      });
    }
  }

  // دالة للتحقق من صحة القيمة المدخلة
  void _validateAndFetchHistoricalWeather() {
    final input = _timeController.text.trim();
    if (input.isEmpty) {
      setState(() {
        _errorMessage = "Please enter a Unix Timestamp.";
      });
      return;
    }

    final time = int.tryParse(input);
    if (time == null || time <= 0) {
      setState(() {
        _errorMessage = "Invalid time value. Please enter a valid Unix Timestamp.";
      });
      return;
    }

    _fetchHistoricalWeather(time);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'حالة الطقس',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.purple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: "الطقس الحالي"),
            Tab(text: "الطقس التاريخي"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // عرض الطقس الحالي
          _buildCurrentWeatherTab(),
          // عرض الطقس التاريخي
          _buildHistoricalWeatherTab(),
        ],
      ),
    );
  }

  // واجهة الطقس الحالي
  Widget _buildCurrentWeatherTab() {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.purple],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cloud, size: 100, color: Colors.blue),
                    const SizedBox(height: 16),
                    const Text(
                      'الطقس الحالي',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 8),
                    if (_isCurrentWeatherLoading)
                      const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.blue))
                    else if (_currentTemperature != null)
                      Column(
                        children: [
                          Text(
                            "${_currentTemperature!.toStringAsFixed(1)}°C",
                            style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.blue),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _currentWeatherDescription ?? "جاري تحميل البيانات...",
                            style: const TextStyle(fontSize: 18, color: Colors.black54),
                          ),
                        ],
                      )
                    else
                      const Text("--°C", style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.blue)),
                    const SizedBox(height: 8),
                    if (_currentHumidity != null)
                      Text("رطوبة: $_currentHumidity%", style: const TextStyle(fontSize: 16, color: Colors.black54)),
                    const SizedBox(height: 16),
                    if (_errorMessage != null)
                      Text(_errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 14)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // واجهة الطقس التاريخي
  Widget _buildHistoricalWeatherTab() {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.purple],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.history, size: 100, color: Colors.blue),
                    const SizedBox(height: 16),
                    const Text(
                      'الطقس التاريخي',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _timeController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "ادخل التوقيت الزمني (Unix Timestamp)",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _validateAndFetchHistoricalWeather,
                      child: const Text("عرض الطقس التاريخي"),
                    ),
                    const SizedBox(height: 20),
                    if (_isHistoricalWeatherLoading)
                      const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.blue))
                    else if (_historicalTemperature != null)
                      Text(
                        "${_historicalTemperature!.toStringAsFixed(1)}°C",
                        style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.blue),
                      )
                    else
                      const Text("--°C", style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.blue)),
                    const SizedBox(height: 8),
                    if (_historicalWeatherDescription != null)
                      Text(
                        _historicalWeatherDescription!,
                        style: const TextStyle(fontSize: 18, color: Colors.black54),
                      )
                    else
                      const Text("جاري تحميل البيانات...", style: TextStyle(fontSize: 18, color: Colors.black54)),
                    const SizedBox(height: 16),
                    if (_errorMessage != null)
                      Text(_errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 14)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}