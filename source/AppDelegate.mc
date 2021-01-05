using Toybox.WatchUi;
using Toybox.ActivityRecording;

class AppDelegate extends WatchUi.BehaviorDelegate {
    hidden var mController;

    function initialize(controller) {
        BehaviorDelegate.initialize();

        mController = controller;
    }

    function onMenu() {
        // TODO: implement settings menu
        mController.next();
        // WatchUi.pushView(new Rez.Menus.ExitMenu(), new ExitMenuDelegate(), WatchUi.SLIDE_UP);
        return true;
    }

    function onSelect(){
        mController.onStartStop();
        return true;
    }

    function onBack() {
        return mController.onBack();
    }

        function onNextPage() {
        // TODO: implement settings menu
        mController.next();
        // WatchUi.pushView(new Rez.Menus.ExitMenu(), new ExitMenuDelegate(), WatchUi.SLIDE_UP);
        return true;
    }
}