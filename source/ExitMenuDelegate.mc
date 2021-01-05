using Toybox.WatchUi;
using Toybox.System;

class ExitMenuDelegate extends WatchUi.Menu2InputDelegate {
    hidden var mController;
    
    function initialize(controller) {
        Menu2InputDelegate.initialize();
        mController = controller;
    }

    function onSelect(item) {
        if (item.getId() == :resume) {
            mController.start();
            Menu2InputDelegate.onBack();
            return true;
        }

        if (item.getId() == :save) {
            mController.save();
            return true;
        }
        
        if (item.getId() == :discard) {
            mController.confirmDiscard();
            return true;
        }

        return false;
    }
}