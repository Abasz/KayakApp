using Toybox.Graphics as Gfx;
using Toybox.Timer;
using Toybox.Application;
using Toybox.WatchUi;
using Toybox.System;
using Toybox.Attention;

class Controller
{
    hidden var mSession;
    hidden var mDataService;
    hidden var mHasBeenStarted;
    
    // Initialize the controller
    function initialize(session, dataService) {
        mSession = session;
        mDataService = dataService;
        mHasBeenStarted = false;
    }

    function start() {
        mSession.start();
        
        if (Attention has :vibrate) {
            Attention.vibrate([new Attention.VibeProfile(100, 1000)]);
        }

        mHasBeenStarted = true;
    }

    function next() {
        WatchUi.switchToView(new View(self), new AppDelegate(self), WatchUi.SLIDE_UP);
    }

    function onBack() {
        if(mSession.isRecording()) {
            mSession.addLap();
            mDataService.addLap();

            if (Attention has :vibrate) {
                Attention.vibrate([new Attention.VibeProfile(100, 1000)]);
            }
            
            return true;
        }

        if (!mSession.isRecording() && mHasBeenStarted) {
            //TODO: Needs to be updated to use menu2 with header
            WatchUi.pushView(new Rez.Menus.ExitMenu(), new ExitMenuDelegate(self), WatchUi.SLIDE_UP);

            return true;
        }

        return false;
    }

    function onStartStop() {
        if(mSession.isRecording()) {
            mSession.stop();
            
            if (Attention has :vibrate) {
                Attention.vibrate([new Attention.VibeProfile(100, 1000)]);
            }

            //TODO: Needs to be updated to use menu2 with header
            WatchUi.pushView(new Rez.Menus.ExitMenu(), new ExitMenuDelegate(self), WatchUi.SLIDE_UP);
        } else {
            start();
        }
    }

    // Save the recording
    function save() {
        // Save the recording
        mDataService.dispose();
        mSession.save();

        if (Attention has :vibrate) {
            Attention.vibrate([new Attention.VibeProfile(100, 1000)]);
        }

        // Give the system some time to finish the recording. Push up a progress bar
        // and start a timer to allow all processing to finish
        WatchUi.pushView(new WatchUi.ProgressBar("Saving", null), new ProgressDelegate(), WatchUi.SLIDE_DOWN);

        var mTimer = new Timer.Timer();
        mTimer.start(method(:onExit), 3000, false);
    }

    function confirmDiscard() {
        // TODO: Menu popup directions need to be checked
        WatchUi.pushView(new Rez.Menus.ConfirmDiscardMenu(), new DiscardMenuDelegate(self), WatchUi.SLIDE_UP);
    }

    function discard() {
        // Discard the recording
        mSession.discard();
        mDataService.dispose();

        if (Attention has :vibrate) {
            Attention.vibrate([new Attention.VibeProfile(100, 1000)]);
        }

        // Give the system some time to discard the recording. Push up a progress bar
        // and start a timer to allow all processing to finish
        WatchUi.pushView(new WatchUi.ProgressBar("Discarding", null), new ProgressDelegate(), WatchUi.SLIDE_DOWN);
        
        var mTimer = new Timer.Timer();
        mTimer.start(method(:onExit), 3000, false);
    }

    function getData() {
        var data = mDataService.getAllData();
        var gpsColor;

        switch(data[:gpsAccuracy]) {
            case 4:
            gpsColor = Gfx.COLOR_DK_GREEN;
            break;
            case 0:
            gpsColor = Gfx.COLOR_TRANSPARENT;
            break;
            default:
            gpsColor = Gfx.COLOR_RED;
            break;
        }

        return {
            :avgLapSpeed => data[:avgLapSpeed].format("%.1f").toString(),
            :avgLapPace => data[:avgLapPace],
            :lapTime => data[:lapTime],
            :currentPace => data[:currentPace],
            :currentSpeed => data[:currentSpeed].format("%.1f").toString(),
            :currentHr => data[:currentHr] != 0 ? data[:currentHr] : "--",
            :hrColor => data[:hrColor],
            :currentCad => data[:currentCad] != 0 ? data[:currentCad] : "--",
            :cadColor => data[:cadColor],
            :elapsedTime => data[:elapsedTime],
            :elapsedDistance => data[:elapsedDistance],
            :gpsColor => gpsColor,
            :battery => data[:battery],
            :strokeCount => data[:strokeCount],
            :time => data[:time]
        };
    }

    // Are we running currently?
    function isRunning() {
        return mSession.isRecording();
    }

    // Handle timing out after exit and cleanup
    function onExit() {
        System.exit();
    }
}