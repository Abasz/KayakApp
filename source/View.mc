using Toybox.Application;
using Toybox.WatchUi;
using Toybox.Graphics as Gfx;
using Toybox.Timer;

enum {
    SPEED,
    PACE
}

class View extends WatchUi.View {
    
    hidden var timer;
    hidden var mController;
    hidden var data;

    hidden var textColor;
    hidden var backgroundColor = Gfx.COLOR_WHITE;
    hidden var speedType = PACE;

    hidden var background, timeOfDayValue, speedLabel, speedValue, totalDistanceLabel,       totalDistanceValue, timerLabel, timerValue, avgLapSpeedLabel, avgLapSpeedValue, lapTimeLabel, lapTimeValue, cadenceValue, cadenceLabel, cadenceSquare, heartRateLabel, heartRateValue, heartRateSquare, gpsLabel, batterySign;

    function initialize(controller) {
        View.initialize();
        mController = controller;
        data = mController.getData();
        timer = new Timer.Timer();
    }

    function onLayout(dc) {
        setLayout(Rez.Layouts.MainLayout(dc));

        background = View.findDrawableById("Background");
        timeOfDayValue = View.findDrawableById("TimeOfDayValue");
        speedLabel = View.findDrawableById("SpeedLabel");
        speedValue = View.findDrawableById("SpeedValue");
        totalDistanceLabel = View.findDrawableById("TotalDistanceLabel");
        totalDistanceValue = View.findDrawableById("TotalDistanceValue");
        timerLabel = View.findDrawableById("TimerLabel");
        timerValue = View.findDrawableById("TimerValue");
        avgLapSpeedLabel = View.findDrawableById("AvgLapSpeedLabel");
        avgLapSpeedValue = View.findDrawableById("AvgLapSpeedValue");
        lapTimeLabel = View.findDrawableById("LapTimeLabel");
        lapTimeValue = View.findDrawableById("LapTimeValue");
        cadenceValue = View.findDrawableById("CadenceValue");
        cadenceLabel = View.findDrawableById("CadenceLabel");
        cadenceSquare = View.findDrawableById("CadenceSquare");
        heartRateValue = View.findDrawableById("HeartRateValue");
        heartRateLabel = View.findDrawableById("HeartRateLabel");
        heartRateSquare = View.findDrawableById("HeartRateSquare");
        gpsLabel = View.findDrawableById("GpsLabel");
        batterySign = View.findDrawableById("BatterySign");
    }

    function onShow() {
		timer.start( method(:timerCallback), 1000, true );
    }

    function onUpdate(dc) {
        // var bgSetting = App.getApp().getProperty("BgSettings");
        // var backgroundColor;

        // switch (bgSetting) {
        // case Bg.AUTO:
        //     backgroundColor = getBackgroundColor();
        //     break;
        // case Bg.BLACK:
        //     backgroundColor = Gfx.COLOR_BLACK;
        //     break;
        // case Bg.WHITE:
        //     backgroundColor = Gfx.COLOR_WHITE;
        //     break;
        // }

        textColor = backgroundColor == Gfx.COLOR_BLACK ? Gfx.COLOR_WHITE : Gfx.COLOR_BLACK;
        
        setColors();
        setValues();

        View.onUpdate(dc);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
		timer.stop();
    }

    function setValues() {
        timeOfDayValue.setText(data[:time]);
        speedLabel.setText(speedType == PACE ? "PACE" : "SPEED");
        speedValue.setText(data[speedType == PACE ? :currentPace : :currentSpeed]);
        totalDistanceValue.setText(data[:elapsedDistance]);
        timerValue.setText(data[:elapsedTime]);
        avgLapSpeedLabel.setText(speedType == PACE ? "AVG PACE" : "AVG SPD");
        heartRateValue.setText(data[:currentHr].toString());
        cadenceValue.setText(data[:currentCad].toString());
        avgLapSpeedValue.setText(speedType == PACE ? data[:avgLapPace] : data[:avgLapSpeed]);
        lapTimeValue.setText(data[:lapTime]);
        batterySign.setPercentage(data[:battery]);
    }

    function setColors() {
        timeOfDayValue.setColor(textColor);
        speedLabel.setColor(textColor);
        speedValue.setColor(textColor);
        totalDistanceLabel.setColor(textColor);
        totalDistanceValue.setColor(textColor);
        timerLabel.setColor(textColor);
        timerValue.setColor(textColor);
        avgLapSpeedLabel.setColor(textColor);
        avgLapSpeedValue.setColor(textColor);
        lapTimeLabel.setColor(textColor);
        lapTimeValue.setColor(textColor);
        cadenceLabel.setColor(textColor);
        cadenceValue.setColor(textColor);
        cadenceSquare.setColor(data[:cadColor]);
        heartRateLabel.setColor(textColor);
        heartRateValue.setColor(textColor);
        heartRateSquare.setColor(data[:hrColor]);
        background.setColor(textColor, backgroundColor);
        gpsLabel.setColor(data[:gpsColor]);
    }
    
    function timerCallback() {
        data = mController.getData();
        WatchUi.requestUpdate();            
    }
}
