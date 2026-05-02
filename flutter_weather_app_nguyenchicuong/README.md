# flutter_weather_app_nguyenchicuong

Weather application for Lab 4 with full architecture and required screens/features.

## Features

- Current weather display
  - Temperature, feels-like, condition icon, city/country, date
- Weather details
  - Humidity, wind speed + direction, pressure, visibility, UV index, sunrise/sunset
- Forecast
  - Hourly forecast (next 24 hours)
  - Daily forecast summary (next 5-7 days)
- Air quality
  - US EPA AQI level
  - Pollutant levels (PM2.5, PM10, CO, NO2, O3, SO2)
  - Health recommendation by AQI level
- Search and location
  - Search by city
  - Automatic location weather (with permission handling)
  - Manual city selection
- Favorites and history
  - Favorite cities (up to 5)
  - Recent searches
- Offline support
  - Cache current weather + forecast + hourly data
  - Shows cached/outdated indicator when offline
- Settings
  - Temperature unit (C/F)
  - Wind speed unit (m/s, km/h, mph)
  - 12/24h format
  - Dark mode toggle
  - Language preference (stored)
- UX states
  - Loading state
  - Error state with retry
  - Pull-to-refresh
  - Dynamic UI gradients based on weather condition

## Project Structure

```text
lib/
  main.dart
  models/
    weather_model.dart
    forecast_model.dart
    location_model.dart
    hourly_weather_model.dart
  services/
    weather_service.dart
    location_service.dart
    storage_service.dart
    connectivity_service.dart
  providers/
    weather_provider.dart
    location_provider.dart
  screens/
    home_screen.dart
    search_screen.dart
    forecast_screen.dart
    settings_screen.dart
  widgets/
    current_weather_card.dart
    hourly_forecast_list.dart
    daily_forecast_card.dart
    weather_detail_item.dart
    loading_shimmer.dart
    error_widget.dart
  utils/
    constants.dart
    weather_icons.dart
    date_formatter.dart
  config/
    api_config.dart
```

## API Setup

1. Get a free API key from WeatherAPI (`https://www.weatherapi.com/`).
2. Copy `.env.example` to `.env`.
3. Add your API key to `.env`:

```env
OPENWEATHER_API_KEY=your_actual_key_here
WEATHER_API_KEY=your_backup_api_key_here
```

4. Run the app. `WeatherService` already calls live API endpoints.

## How To Run

```bash
flutter pub get
flutter run
```

## Technologies Used

- Flutter
- Provider
- HTTP (live WeatherAPI integration)
- Geolocator + Geocoding
- Shared Preferences
- Connectivity Plus
- Intl
- Cached Network Image
- Flutter Dotenv

## Testing

```bash
flutter test
```

Included tests:
- JSON parsing for weather model
- Weather service error handling and forecast generation

## Known Limitations

- Language switching is preference-only in this version (UI strings not localized yet).
- No severe weather alert integration yet.
- No weather map layers yet (radar/temperature/precipitation).
- No native home-screen widget yet.
- Multiple locations currently supports favorites only (no swipe/compare view yet).

## Future Improvements

- API fallback strategy (secondary provider)
- Weather alerts/notifications
- Weather map layers
- Home screen widgets
- Swipe between favorite locations
- Compare weather between cities

## Screenshots

Create and place images in a `screenshots/` folder for submission:
- clear/sunny
  <img width="1080" height="2340" alt="image" src="https://github.com/user-attachments/assets/1b33a4de-d8ab-4d59-9a80-a4db0704c830" />

- rainy
  <img width="1080" height="2340" alt="image" src="https://github.com/user-attachments/assets/e57349e2-649c-40e0-91e0-db0ba4997f9f" />

- cloudy
  <img width="1080" height="2340" alt="image" src="https://github.com/user-attachments/assets/07584ce0-1aa5-48fb-b899-d57529069cb0" />

- night mode
  <img width="1080" height="2340" alt="image" src="https://github.com/user-attachments/assets/8e3da7c6-a6ea-4efc-82ab-3a9b39799eba" />

- search screen
  <img width="1080" height="2340" alt="image" src="https://github.com/user-attachments/assets/1c935987-074d-4ccc-8b95-edda83d7034f" />

- forecast screen
  <img width="1080" height="2340" alt="image" src="https://github.com/user-attachments/assets/d425dc1c-7c64-4d5a-8a74-f3b2a2859818" />


