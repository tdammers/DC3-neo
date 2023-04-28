# LATERAL MODES:
#
# 0 = wings level
# 1 = HDG
# 2 = NAV
#
# VERTICAL MODES:
#
# 0 = ATT (pitch hold)
# 1 = ALT (altitude hold)

var ROLL = 0;
var HDG = 1;
var NAV = 2;

var ATT = 0;
var ALT = 1;
var GS = 2;
var GA = 3;


setprop('controls/autoflight/cws', 0);
setprop('controls/autoflight/toga', 0);
setprop('autopilot/century/hdg-button', 0);
setprop('autopilot/century/nav-button', 0);
setprop('autopilot/century/apr-button', 0);
setprop('autopilot/century/att-button', 0);
setprop('autopilot/century/alt-button', 0);

props.globals.getNode('autopilot/century/lights').setBoolValue('blink-state', 0);

var blinkProp = props.globals.getNode('autopilot/century/lights/blink-state');

var p = {
    "verticalMode": props.globals.getNode('autopilot/century/vertical-mode'),
    "lateralMode": props.globals.getNode('autopilot/century/lateral-mode'),
    "navArmed": props.globals.getNode('autopilot/century/nav-armed'),
    "gsArmed": props.globals.getNode('autopilot/century/gs-armed'),
};

var syncVertical = func (mode=-1) {
    if (mode < 0)
        mode = p.verticalMode.getValue() or 0;
    if (mode == ALT) {
        setprop('autopilot/settings/target-altitude-ft',
            getprop('instrumentation/altimeter/pressure-alt-ft'));
    }
    elsif (mode == ATT) {
        setprop('autopilot/settings/target-pitch-deg',
            getprop('instrumentation/attitude-indicator/indicated-pitch-deg'));
    }
};

var wingsLevel = func {
    setprop('autopilot/settings/target-roll-deg', 0.0);
}

var initialized = 0;

setlistener('/sim/signals/fdm-initialized', func {
    if (initialized) return;
    initialized = 1;

    setlistener('autopilot/century/active', func (node) {
        if (node.getBoolValue()) {
            # A/P activated

            # wings level
            p.lateralMode.setValue(0);

            # pitch hold
            p.verticalMode.setValue(0);

            # disarm APR
            p.gsArmed.setValue(0);

            # disarm NAV
            p.navArmed.setValue(0);

            # wings level
            wingsLevel();
            syncVertical(0);
        }
    }, 1, 0);

    setlistener('autopilot/century/hdg-button', func (node) {
        var mode = p.lateralMode.getValue();

        if (mode == HDG) {
            p.lateralMode.setValue(ROLL);
            wingsLevel();
        }
        else {
            p.lateralMode.setValue(HDG);
        }
        p.gsArmed.setBoolValue(0);
        p.navArmed.setBoolValue(0);
    }, 1, 1);

    setlistener('autopilot/century/nav-button', func (node) {
        var mode = p.lateralMode.getValue();
        var arm = node.getValue() == 2;

        if (arm) {
            p.navArmed.toggleBoolValue();
            p.gsArmed.setBoolValue(0);
        }
        else {
            if (mode == NAV) {
                p.lateralMode.setValue(ROLL);
                wingsLevel();
            }
            else {
                p.lateralMode.setValue(NAV);
            }
            p.gsArmed.setBoolValue(0);
            p.navArmed.setBoolValue(0);
        }
    }, 1, 1);

    setlistener('autopilot/century/apr-button', func (node) {
        var mode = p.lateralMode.getValue();
        var arm = node.getValue() == 2;

        if (arm) {
            p.gsArmed.toggleBoolValue();
            p.navArmed.setBoolValue(p.gsArmed.getBoolValue());
        }
        else {
            if (p.gsArmed.getBoolValue()) {
                p.lateralMode.setValue(ROLL);
                wingsLevel();
                p.gsArmed.setBoolValue(0);
            }
            else {
                p.lateralMode.setValue(NAV);
                p.gsArmed.setBoolValue(1);
            }
            p.navArmed.setBoolValue(0);
        }
    }, 1, 1);

    setlistener('autopilot/century/att-button', func (node) {
        p.verticalMode.setValue(ATT);
        syncVertical(ATT);
        p.gsArmed.setBoolValue(0);
    }, 1, 1);

    setlistener('autopilot/century/alt-button', func (node) {
        p.verticalMode.setValue(ALT);
        syncVertical(ALT);
        p.gsArmed.setBoolValue(0);
    }, 1, 1);

    setlistener('controls/autoflight/toga', func (node) {
        var state = node.getValue() or 0;
        if (state) {
            p.verticalMode.setValue(GA);
            syncVertical(GA);
            p.gsArmed.setBoolValue(0);
        }
    }, 1, 1);

    setlistener('autopilot/inputs/pitch-button', func (node) {
        var state = node.getValue() or 0;
        setprop('autopilot/century/pitch-button', state);
        if (!state) {
            syncVertical();
        }
    }, 1, 0);

    setlistener('controls/autoflight/cws', func (node) {
        var state = node.getValue() or 0;
        if (!state) {
            syncVertical();
        }
    }, 1, 0);

    setlistener('autopilot/century/gs-captured', func (node) {
        if (node.getBoolValue()) {
            if (getprop('autopilot/century/gs-armed')) {
                setprop('autopilot/century/vertical-mode', 2);
            }
        }
    }, 1, 0);

    setlistener('autopilot/century/nav-armed', func (node) {
        if (node.getBoolValue()) {
            if (getprop('autopilot/century/nav-captured')) {
                setprop('autopilot/century/lateral-mode', 2);
                setprop('autopilot/century/nav-armed', 0);
            }
        }
    }, 1, 0);

    setlistener('autopilot/century/nav-captured', func (node) {
        if (node.getBoolValue()) {
            if (getprop('autopilot/century/nav-armed')) {
                setprop('autopilot/century/lateral-mode', 2);
                setprop('autopilot/century/nav-armed', 0);
            }
        }
    }, 1, 0);
});

var blinkTimer = maketimer(0.5, func { blinkProp.toggleBoolValue(); });
blinkTimer.simulatedTime = 1;
blinkTimer.start();
