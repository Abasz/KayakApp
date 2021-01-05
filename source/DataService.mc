using Toybox.Sensor;
using Toybox.Position;
using Toybox.UserProfile;
using Toybox.System;
using Toybox.Timer;
using Toybox.Graphics;

class DataService
{
    hidden var mTimer;
    hidden var mSession;

    hidden var mHrZones;
    hidden var mDeviceSettings;
    hidden var mIsGpsEnabled;

    hidden var mCurrentCadence;
    hidden var mCurrentSpeed;
    hidden var mCurrentHeartRate;
    hidden var mAvgStroke;
    hidden var mStrokeCount;
    hidden var mLapAvgStroke;
    hidden var mElapsedTime;
    hidden var mElapsedDistance;
    hidden var mAvgLapSpeed;
    hidden var mLapAvgCadence;
    hidden var mLapTime;
    hidden var mLapTimerOffset;
    hidden var mLapDistanceOffset;
    hidden var mLapStrokeCountOffset;

    hidden var mBattery;
    hidden var mGpsAccuracy;
    hidden var mTimeOfDay;

    hidden var mCurrentStrokeRateField;
    hidden var mAvgStrokeRateField;
    hidden var mLapAvgStrokeRateField;
    hidden var mTotalStrokeCountField;


    function initialize(settings, session) {
        mDeviceSettings = settings["deviceSettings"];
        mIsGpsEnabled = settings["mySettings"]["isGpsEnabled"];
        mSession = session;

        mCurrentCadence = 0;
        mCurrentSpeed = 0;
        mCurrentHeartRate = 0;
        mAvgStroke = 0;
        mStrokeCount = 0;
        mLapAvgStroke = 0;
        mLapStrokeCountOffset = 0;
        mElapsedTime = 0;
        mElapsedDistance = 0;
        mAvgLapSpeed = 0;
        mLapTimerOffset = 0;
        mLapDistanceOffset = 0;
        mLapTime = 0;
        mBattery = System.getSystemStats().battery;
        mGpsAccuracy = 0;
        mTimeOfDay = System.getClockTime();

        // create a setting to disabled GPS
        Sensor.setEnabledSensors([Sensor.SENSOR_HEARTRATE, Sensor.SENSOR_BIKECADENCE]);

        mHrZones = UserProfile.getHeartRateZones(UserProfile.HR_ZONE_SPORT_RUNNING);
        
        Position.enableLocationEvents(mIsGpsEnabled ? Position.LOCATION_CONTINUOUS : Position.LOCATION_DISABLE, method(:onPosition));

        // need: max stroke, avg dist per stroke (summary and lap), dist per stroke (graph)
        mCurrentStrokeRateField = mSession.createField("stroke_rate", 1, FitContributor.DATA_TYPE_UINT8, {
            :mesgType => FitContributor.MESG_TYPE_RECORD,
            :units=>"spm",
            :nativeNum=>4
        });
        
        mAvgStrokeRateField = mSession.createField("avg_stroke_rate", 2, FitContributor.DATA_TYPE_UINT8, {
            :mesgType => FitContributor.MESG_TYPE_SESSION, 
            :units=>"spm", 
            :nativeNum=>18
        });

        mTotalStrokeCountField = mSession.createField("total_stroke_count", 3, FitContributor.DATA_TYPE_UINT8, {
            :mesgType => FitContributor.MESG_TYPE_SESSION, 
            :units=>"strokes", 
            //TODO: needs to be checked for nativeNum
            :nativeNum=>17
        });

        mLapAvgStrokeRateField = mSession.createField("lap_avg_stroke_rate", 4, FitContributor.DATA_TYPE_UINT8, {
            :mesgType => FitContributor.MESG_TYPE_LAP, 
            :units=>"spm", 
            :nativeNum=>17
        });

        // Allocate the timer
        mTimer = new Timer.Timer();
        // Process the sensors per second
        mTimer.start(method(:sensorCallback), 1000, true);
    }

    function getAllData(){
        return {
            :avgLapSpeed => getKmOrMile(mAvgLapSpeed),
            :avgLapPace => getMinutesPerKmOrMile(mAvgLapSpeed),
            :lapTime => getElapsedTime(mLapTime),
            :currentPace => getMinutesPerKmOrMile(mCurrentSpeed),
            :currentSpeed => getKmOrMile(mCurrentSpeed),
            :currentHr => mCurrentHeartRate,
            :hrColor => getHrColor(mCurrentHeartRate),
            :currentCad => mCurrentCadence,
            :cadColor => getCadColor(mCurrentCadence),
            :elapsedTime => getElapsedTime(mElapsedTime),
            :elapsedDistance => getElapsedDistance(mElapsedDistance),
            :gpsAccuracy => mGpsAccuracy,
            :battery => mBattery,
            :strokeCount => mStrokeCount,
            :avgStroke => mAvgStroke,
            :avgLapStroke => mLapAvgStroke,
            :time => getTime(mTimeOfDay)
        };
    }

    function sensorCallback() {

        // sensor is in fact needed as activity info does not provide bikecadence sensor data only accelerometer in rowing mode
        var info = Activity.getActivityInfo();
        var sensorInfo = Sensor.getInfo();

        //this needs updating and the avg should be tracked manually
        mCurrentCadence = sensorInfo.cadence != null ? sensorInfo.cadence : 0;
        mStrokeCount = mSession.isRecording() ? mStrokeCount + mCurrentCadence / 60.0 : mStrokeCount;
        mElapsedTime = info.timerTime != null ? info.timerTime : 0;
        mElapsedDistance = info.elapsedDistance != null ? info.elapsedDistance : 0;
        mBattery = System.getSystemStats().battery;
        mGpsAccuracy = info.currentLocationAccuracy != null ? info.currentLocationAccuracy : 0;
        mCurrentSpeed = info.currentSpeed != null ? info.currentSpeed : 0;
        mCurrentHeartRate = info.currentHeartRate != null ? info.currentHeartRate : 0;
        
        mLapTime = mElapsedTime - mLapTimerOffset;
        mAvgStroke = mStrokeCount > 0 && mElapsedTime > 1000 ? 
            mStrokeCount / (mElapsedTime / 1000.0) * 60 : 0;
        mAvgLapSpeed = (mElapsedDistance - mLapDistanceOffset) > 0 && mLapTime > 1000 ? 
                (mElapsedDistance - mLapDistanceOffset) / (mLapTime / 1000) : 0;
        mLapAvgStroke = mLapTime > 1000 && (mStrokeCount - mLapStrokeCountOffset) > 0 ? 
                (mStrokeCount - mLapStrokeCountOffset) / (mLapTime / 1000.0) * 60 : 0;
        
        mTimeOfDay = System.getClockTime();

        // Update the fields
        mCurrentStrokeRateField.setData(mCurrentCadence);
        mTotalStrokeCountField.setData(mStrokeCount);
        mLapAvgStrokeRateField.setData(mLapAvgStroke);
        mAvgStrokeRateField.setData(mAvgStroke);
    }

    function addLap() {
        mLapTimerOffset = mElapsedTime;
        mLapStrokeCountOffset = mStrokeCount;
        mLapDistanceOffset = mElapsedDistance;
    }

    function getHrColor(currHr) {
        if (currHr == 0) {
            return Graphics.COLOR_TRANSPARENT;
        }

        if (currHr > mHrZones[4]) {
            return Graphics.COLOR_RED;
        }
        if (currHr > mHrZones[3]) {
            return Graphics.COLOR_ORANGE;
        }
        if (currHr > mHrZones[2]) {
            return Graphics.COLOR_GREEN;
        }
        if (currHr > mHrZones[1]) {
            return Graphics.COLOR_BLUE;
        }
        return Graphics.COLOR_LT_GRAY;
    }

    function getCadColor(currCad) {
        if (currCad == 0) {
            return Graphics.COLOR_TRANSPARENT;
        }
        if (currCad > 185) {
            return Graphics.COLOR_PURPLE;
        }
        if (currCad > 173) {
            return Graphics.COLOR_BLUE;
        }
        if (currCad > 162) {
            return Graphics.COLOR_GREEN;
        }
        if (currCad > 151) {
            return Graphics.COLOR_ORANGE;
        }
        return Graphics.COLOR_RED;
    }

    function getElapsedTime(elapsedTime) {
        if (elapsedTime == null && elapsedTime < 0) {
            return "0:00";
        }

        var totalSeconds = elapsedTime / 1000;
        var days = (totalSeconds / 86400).toNumber();
        var hours = ((totalSeconds % 86400) / 3600).toNumber();
        var mins = ((totalSeconds % 86400 % 3600) / 60).toNumber();
        var seconds = (totalSeconds % 86400 % 3600 % 3600 % 60).toNumber();

        if (days > 0) {
            return days.format("%d") + ":" + hours.format("%02d") + ":" + mins.format("%02d");
        }

        if (hours == 0) {
            return mins.format("%d") + ":" + seconds.format("%02d");
        }

        return hours.format("%d") + ":" + mins.format("%02d") + ":" + seconds.format("%02d");
    }

    function getMinutesPerKmOrMile(speedMetersPerSecond) {
        if (speedMetersPerSecond != null && speedMetersPerSecond > 0.3) {

            var kmOrMileInMeters = 1000;

            if (mDeviceSettings.distanceUnits == System.UNIT_STATUTE) {
                kmOrMileInMeters = 1610;
            }

            var metersPerMinute = speedMetersPerSecond * 60.0;
            var minutesPerKmOrMilesDecimal = kmOrMileInMeters / metersPerMinute;
            var minutesPerKmOrMilesFloor = minutesPerKmOrMilesDecimal.toNumber();
            var seconds = (minutesPerKmOrMilesDecimal - minutesPerKmOrMilesFloor) * 60;
            return Lang.format("$1$:$2$", [ minutesPerKmOrMilesDecimal.format("%1d"), seconds.format("%02d") ]);
        }
        return ":";
    }

    function getKmOrMile(speedMetersPerSecond) {
        var kmOrMileInMeters = 3.6;

        if (mDeviceSettings.distanceUnits == System.UNIT_STATUTE) {
            kmOrMileInMeters = 2.236936;
        }

        return speedMetersPerSecond * kmOrMileInMeters;
    }

    function getTime(clockTime) {
        if (mDeviceSettings.is24Hour) {
            return Lang.format("$1$:$2$", [ clockTime.hour, clockTime.min.format("%02d") ]);
        }

        var hour = clockTime.hour;

        if (clockTime.hour > 12) {
            hour = clockTime.hour - 12;
        }

        if (clockTime.hour == 0) {
            hour = 12;
        }

        var time = Lang.format("$1$:$2$", [ hour, clockTime.min.format("%02d") ]);
        var ampm = mDeviceSettings.is24Hour ? "" : (clockTime.hour < 12) ? "am" : "pm";
        return time + ampm;
    }

    function getElapsedDistance(elapsedDistance) {
        if (elapsedDistance == null) {
            return "0.00";
        }

        var kmOrMileInMeters = 1000.0;

        if (mDeviceSettings.distanceUnits == System.UNIT_STATUTE) {
            kmOrMileInMeters = 1610.0;
        }

        var elapsedDistanceKmOrMiles = elapsedDistance / kmOrMileInMeters;
        if (elapsedDistance >= 999950) {
            return elapsedDistanceKmOrMiles.format("%.0f");
        }
        if (elapsedDistance >= 99990) {
            return elapsedDistanceKmOrMiles.format("%.1f");
        }

        return elapsedDistanceKmOrMiles.format("%.2f");
    }

    function dispose() {
        mTimer.stop();
    }

    function onPosition(info) {
    }
}