import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/weather_provider.dart';
import '../utils/constants.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  List<String> _suggestions = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSuggestions();
  }

  Future<void> _loadSuggestions([String query = '']) async {
    setState(() => _isLoading = true);
    final result = await context.read<WeatherProvider>().searchCities(query);
    if (!mounted) {
      return;
    }
    setState(() {
      _suggestions = result;
      _isLoading = false;
    });
  }

  Future<void> _onSearchSubmit(String cityName) async {
    await context.read<WeatherProvider>().fetchWeatherByCity(cityName);
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search City')),
      body: Consumer<WeatherProvider>(
        builder: (context, provider, child) {
          return ListView(
            padding: const EdgeInsets.all(AppDimensions.screenPadding),
            children: [
              TextField(
                controller: _controller,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Enter city name',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: IconButton(
                    onPressed: () {
                      _controller.clear();
                      _loadSuggestions();
                    },
                    icon: const Icon(Icons.clear_rounded),
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onChanged: _loadSuggestions,
                onSubmitted: _onSearchSubmit,
              ),
              const SizedBox(height: 18),
              _sectionTitle('Suggestions'),
              const SizedBox(height: 10),
              if (_isLoading)
                const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()))
              else
                ..._suggestions.map((city) {
                  final isFavorite = provider.isFavorite(city);
                  return Card(
                    child: ListTile(
                      title: Text(city),
                      trailing: IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          color: isFavorite ? Colors.red : null,
                        ),
                        onPressed: () => provider.toggleFavorite(city),
                      ),
                      onTap: () => _onSearchSubmit(city),
                    ),
                  );
                }),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(child: _sectionTitle('Recent Searches')),
                  TextButton(
                    onPressed: provider.searchHistory.isEmpty ? null : provider.clearSearchHistory,
                    child: const Text('Clear'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (provider.searchHistory.isEmpty)
                const Text('No recent search yet.')
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: provider.searchHistory
                      .map(
                        (city) => InputChip(
                          label: Text(city),
                          onPressed: () => _onSearchSubmit(city),
                          onDeleted: () => provider.removeSearchItem(city),
                        ),
                      )
                      .toList(),
                ),
              const SizedBox(height: 18),
              _sectionTitle('Favorite Cities (max 5)'),
              const SizedBox(height: 8),
              if (provider.favoriteCities.isEmpty)
                const Text('No favorite city yet.')
              else
                ...provider.favoriteCities.map(
                  (city) => Card(
                    child: ListTile(
                      title: Text(city),
                      leading: const Icon(Icons.place_rounded),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline_rounded),
                        onPressed: () => provider.toggleFavorite(city),
                      ),
                      onTap: () => _onSearchSubmit(city),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
    );
  }
}
