using Toybox.WatchUi;
using Toybox.System;

class DiscardMenuDelegate extends WatchUi.Menu2InputDelegate {
    hidden var mController;
    
    function initialize(controller) {
        Menu2InputDelegate.initialize();
        mController = controller;
    }

    function onSelect(item) {
        if (item.getId() == :yes) {
            mController.discard();
            return true;
        }
        Menu2InputDelegate.onBack();
        return true;
    }
}