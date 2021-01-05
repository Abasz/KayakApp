using Toybox.WatchUi;

class BackgroundDrawable extends WatchUi.Drawable {
    hidden var foregroundColor, backgroundColor;

    function initialize(settings) {
        Drawable.initialize(settings);
    }

    function setColor(foreground, background) {
        foregroundColor = foreground;
        backgroundColor = background;
    }

    function draw(dc) {
        if (foregroundColor != null && backgroundColor != null) {
            dc.setColor(foregroundColor, backgroundColor);
        }

        dc.clear();
    }
}
