using Toybox.WatchUi;
using Toybox.Graphics as Gfx;

class BatterySignDrawable extends WatchUi.Drawable {
    hidden var mPercentage, locX, locY, width, height, positiveSideWidth, positiveSideHeight;

    function initialize(params) {
        Drawable.initialize(params);
        mPercentage = 0;
        locX = params.get(:locX);
        locY = params.get(:locY);
        width = params.get(:width);
        height = params.get(:height);
        positiveSideWidth = params.get(:positiveSideWidth);
        positiveSideHeight = params.get(:positiveSideHeight);
    }

    function setPercentage(percentage) {
        mPercentage = percentage;
    }

    function draw(dc) {
        dc.drawRectangle(locX, locY, width + 4, height + 4);
        dc.fillRectangle(locX + width + 4, locY + 4, positiveSideWidth, positiveSideHeight);

        dc.setColor(Gfx.COLOR_GREEN, Gfx.COLOR_GREEN);

        if (mPercentage < 15) {
            dc.setColor(Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT);
        } else if (mPercentage < 30) {
            dc.setColor(Gfx.COLOR_YELLOW, Gfx.COLOR_TRANSPARENT);
        } else {
            dc.setColor(Gfx.COLOR_DK_GREEN, Gfx.COLOR_TRANSPARENT);
        }
        dc.fillRectangle(locX + 2, locY + 2, mPercentage / 100 * width, height);
    }
}
