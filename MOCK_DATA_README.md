# Mock Data Generator for Circuit Breakers

This document explains how to use the mock data generator to add sample circuit breaker data to your Firebase Realtime Database.

## Overview

The mock data generator is a utility that creates sample circuit breaker data for testing purposes. It adds:

1. **Circuit Breakers**: 5 sample circuit breakers with different properties
2. **Historical Data**: Mock historical data for different time periods (day, week, month, year)
3. **Real-time Data**: Sample real-time data points for visualization

## How to Access

1. Run the app in debug mode
2. Log in as an Owner, Admin, or Staff user
3. Navigate to Settings
4. Look for the "Mock Data Generator" option (visible only in debug mode)
5. Tap on it to open the mock data generator screen

## Options

### Generate Mock Circuit Breakers
Creates 5 sample circuit breakers with the following properties:
- Kitchen Circuit Breaker (100A rating)
- Living Room Circuit Breaker (80A rating)
- Master Bedroom Circuit Breaker (60A rating)
- Garage Circuit Breaker (120A rating)
- Air Conditioning Circuit Breaker (150A rating)

Each circuit breaker includes:
- Name and ID
- Circuit breaker rating
- WiFi credentials
- Current readings (voltage, current, temperature, power, energy)
- Location data
- Owner association

### Generate Mock Historical Data
Creates historical data for all existing circuit breakers:
- Daily data (24 hours)
- Weekly data (7 days)
- Monthly data (4 weeks)
- Yearly data (12 months)

### Generate All Mock Data
Combines both options above to create a complete test dataset.

## Data Structure

The mock data is saved to your Firebase Realtime Database with the following structure:

```
circuitBreakers/
  [circuitBreakerId]/
    scbId: "CB-KITCHEN-001"
    scbName: "Kitchen Circuit Breaker"
    circuitBreakerRating: 100.0
    wifiName: "HomeWiFi_5G"
    wifiPassword: "password123"
    isOn: true
    voltage: 220.5
    current: 15.2
    temperature: 35.5
    power: 3351.6
    energy: 45.2
    latitude: 14.5995
    longitude: 120.9842
    ownerId: [userUid]
    createdAt: [timestamp]

historicalData/
  [circuitBreakerId]/
    day/
      "00:00": 10.5
      "01:00": 12.3
      ...
    week/
      "Mon": 75.2
      "Tue": 82.1
      ...
    month/
      "Week 1": 250.5
      "Week 2": 275.3
      ...
    year/
      "Jan": 750.2
      "Feb": 800.5
      ...

realTimeData/
  [circuitBreakerId]/
    voltage/
      0: 220.5
      1: 221.3
      ...
    current/
      0: 15.2
      1: 15.8
      ...
    power/
      0: 3351.6
      1: 3500.2
      ...
    temperature/
      0: 35.5
      1: 36.2
      ...

users/
  [userUid]/
    circuitBreakers/
      [circuitBreakerId]: true
```

## Important Notes

- The mock data generator is only visible in debug mode to prevent accidental use in production
- The generated data is for testing purposes only
- All circuit breakers will be associated with the currently logged-in user
- If you're logged in as an Admin or Staff, the circuit breakers will be associated with the owner who created your account
- The mock data includes realistic values for electrical measurements
- You can generate the data multiple times, but it will overwrite existing entries with the same IDs

## Troubleshooting

If you encounter issues:

1. Make sure you're logged in before using the generator
2. Check your Firebase connection
3. Ensure you have the necessary permissions in your Firebase project
4. Look at the console output for any error messages