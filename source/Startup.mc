using Toybox.Application;
using Toybox.WatchUi;

class Startup extends Application.AppBase {

    hidden var dataService;
    hidden var controller;

    hidden var mySettings = {
        "isGpsEnabled" => true
    };

    hidden var mSession = null;

    function initialize() {
        AppBase.initialize();
                
        mSession = ActivityRecording.createSession({
            :sport=>ActivityRecording.SPORT_ROWING, 
            :subSport=>mySettings["isGpsEnabled"] ? ActivityRecording.SUB_SPORT_GENERIC : ActivityRecording.SUB_SPORT_INDOOR_ROWING,
            :name=>"Kayaking"
        });

        dataService = new $.DataService({
            "mySettings" => mySettings,
            "deviceSettings" => System.getDeviceSettings()
        },
        mSession);

        controller = new $.Controller(mSession, dataService);
    }

    // onStart() is called on application start up
    function onStart(state) {
    }

    // onStop() is called when your application is exiting  
    function onStop(state) {
    }

    // Return the initial view of your application here
    function getInitialView() {
        return [ new View(controller), new AppDelegate(controller) ];
    }
}
