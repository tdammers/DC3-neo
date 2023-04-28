var gpsCanvas = nil;
var gpsScreen = nil;
var charElems = [];
var cursorElem = nil;
var displayLineProps = [];
var modeLightProp = nil;
var msgLightProp = nil;
var blinkProp = nil;

var putLine = func (row, str) {
    displayLineProps[row].setValue(str);
};

var putScreen = func (strs) {
    for (var i = 0; i < 3; i += 1) {
        putLine(i, strs[i]);
    }
};

var clearScreen = func () {
    displayLineProps[0].setValue('');
    displayLineProps[1].setValue('');
    displayLineProps[2].setValue('');
};

var updateCursorBlink = func {
    var blinkState = blinkProp.getValue();
    if (cursorElem != nil) {
        if (blinkState == 0) {
            cursorElem.fg.setColor(0, 1, 0);
            cursorElem.bg.setColorFill(0, 0, 0);
        }
        else {
            cursorElem.fg.setColor(0, 0, 0);
            cursorElem.bg.setColorFill(0, 1, 0);
        }
    }
};

var unsetCursor = func {
    if (cursorElem) {
        cursorElem.fg.setColor(0, 1, 0);
        cursorElem.bg.setColorFill(0, 0, 0);
    }
    cursorElem = nil;
};

var setCursor = func (row, col) {
    unsetCursor();
    cursorElem = charElems[row][col];
    blinkProp.setValue(2);
    updateCursorBlink();
};

var initScreen = func {
    gpsCanvas = canvas.new({
        "name": "GPS155",
        "size": [1024, 128],
        "view": [256, 32],
        "mipmapping": 1
    });
    gpsCanvas.addPlacement({"texture": "gps155-screen.png"});
    gpsScreen = gpsCanvas.createGroup();
    for (var y = 0; y < 3; y += 1) {
        append(charElems, []);
        for (var x = 0; x < 20; x += 1) {
            append(charElems[y], {
                bg: gpsScreen.createChild('path')
                         .rect(58 + x * 7, 2 + y * 10, 7, 9)
                         .setColor(0, 0, 0)
                         .setColorFill(0, 0, 0),
                fg: gpsScreen.createChild('text')
                         .setText('?')
                         .setFont('gps155.txf')
                         .setColor(0, 1, 0)
                         .setColorFill(0, 0, 0)
                         .setTranslation(59 + x * 7, 10 + y * 10)
                         .setFontSize(7, 1)
            });
        }
    }
    for (var l = 0; l < 3; l += 1) {
        (func (y) {
            var prop = props.globals.getNode('/instrumentation/gps155/display/line[' ~ y ~ ']', 1);
            prop.setValue('');
            append(displayLineProps, prop);
            globals.setlistener(prop, func (node) {
                var txt = node.getValue();
                for (var x = 0; x < 20; x += 1) {
                    charElems[y][x].fg.setText(
                        utf8.substr(txt, x, 1));
                }
            }, 1, 0);
        })(l);
    }

    modeLightProp = props.globals.getNode('/instrumentation/gps155/lights/mode', 1);
    msgLightProp = props.globals.getNode('/instrumentation/gps155/lights/msg', 1);
    blinkProp = props.globals.getNode('/instrumentation/gps155/blink-state', 1);
    blinkProp.setValue(0);
};
