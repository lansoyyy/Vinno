# Real-Time Threshold Monitoring Implementation

## Overview
This implementation adds real-time threshold monitoring to your Smart Circuit Breaker app. The system continuously monitors all circuit breakers and automatically triggers actions (Off/Alarm/Trip) when thresholds are exceeded.

## Architecture

### 1. **ThresholdMonitorService** (`lib/services/threshold_monitor_service.dart`)
A dedicated service that:
- Monitors all circuit breakers in real-time via Firebase streams
- Checks voltage, current, power, and temperature against configured thresholds
- Executes actions based on threshold violations
- Prevents notification spam with 30-second cooldown

### 2. **NavHome Integration** (`lib/Owner_Side/Owner_LandingPage/nav_home.dart`)
The home screen now:
- Displays threshold violations in a prominent alert banner
- Shows real-time updates as violations occur
- Automatically executes configured actions (Trip/Alarm/Off)

## Features

### Threshold Types Monitored
1. **Overvoltage** - Triggers when voltage exceeds threshold
2. **Undervoltage** - Triggers when voltage drops below threshold
3. **Overcurrent** - Triggers when current exceeds threshold
4. **Overpower** - Triggers when power exceeds threshold
5. **Temperature** - Triggers when temperature exceeds threshold

### Action Types
1. **Trip** - Automatically turns OFF the circuit breaker
2. **Alarm** - Shows alert banner (circuit breaker stays ON)
3. **Off** - Monitoring disabled for this threshold

### Real-Time Alert Banner
When thresholds are violated, users see:
- **Red alert banner** at the top of the screen
- **Circuit breaker name** that triggered the alert
- **Threshold type** (e.g., "Overvoltage")
- **Current vs threshold values** (e.g., "235.5V > 230.0V")
- **Action badge** showing what action was taken (TRIP/ALARM/OFF)
- **Color-coded icons** for each threshold type

## How It Works

### Data Flow
```
Firebase Realtime Database
    ↓
ThresholdMonitorService (Stream)
    ↓
Check each circuit breaker's current values
    ↓
Compare against configured thresholds
    ↓
If violation detected:
    - Execute action (Trip/Alarm/Off)
    - Display alert banner
    - Prevent spam (30s cooldown)
```

### Firebase Database Structure
```
circuitBreakers/
  └── {scbId}/
      ├── scbName: "Kitchen CB"
      ├── isOn: true
      ├── voltage: 235.5
      ├── current: 15.2
      ├── power: 3580
      ├── temperature: 45.5
      └── thresholds/
          ├── overvoltage/
          │   ├── enabled: true
          │   ├── value: 230
          │   └── action: "trip"
          ├── undervoltage/
          │   ├── enabled: true
          │   ├── value: 180
          │   └── action: "alarm"
          ├── overcurrent/
          │   ├── enabled: true
          │   ├── value: 50
          │   └── action: "trip"
          ├── overpower/
          │   ├── enabled: true
          │   ├── value: 3450
          │   └── action: "alarm"
          └── temperature/
              ├── enabled: true
              ├── value: 50
              └── action: "trip"
```

## User Experience

### Setting Thresholds
1. User navigates to **Voltage Settings** for a circuit breaker
2. User adjusts threshold values using sliders
3. User selects action (Off/Alarm/Trip) for each threshold
4. User taps **Save** to store in Firebase

### Monitoring in Action
1. App continuously monitors all circuit breakers
2. When a threshold is exceeded:
   - **If action = "Trip"**: Circuit breaker turns OFF automatically
   - **If action = "Alarm"**: Alert banner shows, CB stays ON
   - **If action = "Off"**: No action taken
3. Alert banner displays at top of home screen
4. User can see all active violations in scrollable list
5. Violations auto-clear when values return to normal

### Spam Prevention
- Each violation has a 30-second cooldown
- Prevents repeated actions for the same violation
- Ensures smooth user experience

## Example Scenarios

### Scenario 1: Overvoltage Trip
```
1. User sets overvoltage threshold: 230V, action: Trip
2. Voltage rises to 235V
3. System detects violation
4. Circuit breaker automatically turns OFF
5. Alert banner shows: "Overvoltage: 235.0V > 230.0V"
6. Badge shows: "TRIP" (red)
```

### Scenario 2: Temperature Alarm
```
1. User sets temperature threshold: 50°C, action: Alarm
2. Temperature rises to 52°C
3. System detects violation
4. Circuit breaker stays ON
5. Alert banner shows: "Temperature: 52.0°C > 50.0°C"
6. Badge shows: "ALARM" (orange)
7. User can manually turn off if needed
```

### Scenario 3: Multiple Violations
```
1. Circuit breaker has both overvoltage and overcurrent
2. Both thresholds exceeded simultaneously
3. Alert banner shows count: "Threshold Alert (2)"
4. Scrollable list shows both violations
5. Each violation executes its configured action
```

## Benefits

### Safety
- **Automatic protection** against electrical hazards
- **Real-time response** to dangerous conditions
- **Customizable actions** per threshold type

### User Control
- **Flexible configuration** for each circuit breaker
- **Visual feedback** on all violations
- **Manual override** always available

### Reliability
- **Firebase real-time sync** ensures instant updates
- **Stream-based monitoring** for continuous protection
- **Spam prevention** avoids excessive actions

## Technical Details

### Performance
- Uses Firebase streams for efficient real-time updates
- Only monitors circuit breakers owned by current user
- Minimal battery impact with stream-based approach

### Error Handling
- Gracefully handles missing threshold data
- Continues monitoring even if one CB fails
- Logs errors for debugging

### Scalability
- Supports unlimited circuit breakers
- Efficient stream processing
- No polling overhead

## Future Enhancements (Optional)

1. **Push Notifications** - Alert users even when app is closed
2. **Threshold History** - Log all violations for analysis
3. **Email Alerts** - Notify via email for critical violations
4. **Custom Actions** - Allow users to define custom responses
5. **Threshold Templates** - Pre-configured threshold sets
6. **Analytics Dashboard** - Visualize threshold violations over time

## Testing

### Test Cases
1. **Set threshold and exceed it** - Verify action executes
2. **Multiple violations** - Verify all show in alert banner
3. **Cooldown period** - Verify no spam after 30 seconds
4. **Circuit breaker OFF** - Verify no monitoring when OFF
5. **Action types** - Test Trip, Alarm, and Off actions
6. **Real-time updates** - Verify instant response to changes

### Manual Testing Steps
1. Create a circuit breaker
2. Set overvoltage threshold to 230V with Trip action
3. Manually update voltage in Firebase to 235V
4. Verify alert banner appears
5. Verify circuit breaker turns OFF automatically
6. Verify alert clears when voltage returns to normal

## Conclusion

The threshold monitoring system provides comprehensive, real-time protection for all circuit breakers in your app. Users can configure custom thresholds with flexible actions, and the system automatically responds to violations while providing clear visual feedback.
