using Toybox.WatchUi;
using Toybox.Graphics as Gfx;

class ColoredSquareDrawable extends WatchUi.Drawable {
    hidden var mColor, locX, locY, width, height;

    function initialize(params) {
        Drawable.initialize(params);
        mColor = Gfx.COLOR_TRANSPARENT;
        locX = params.get(:locX);
        locY = params.get(:locY);
        width = params.get(:width);
        height = params.get(:height);
    }

     function setColor(color) {
        mColor = color;
    }

    function draw(dc) {
        dc.setColor(mColor, mColor);
        dc.fillRectangle(locX, locY, width, height);
    }
}
