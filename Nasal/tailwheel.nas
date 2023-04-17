setprop('/controls/gear/tailwheel-lock', 1);
setprop('/controls/gear/tailwheel-lock-armed', 0);
setprop('/controls/gear/tailwheel-lock-engaged', 1);

var initListener = setlistener("/sim/signals/fdm-initialized", func {
    setlistener('/controls/gear/tailwheel-lock', func (node) {
        if (node.getBoolValue()) {
            # arm
            var angle = getprop('/gear/gear[2]/caster-angle-deg') or 0.0;
            if (angle > 3.0) {
                setprop('/controls/gear/tailwheel-lock-armed', 1);
            }
            elsif (angle < -3.0) {
                setprop('/controls/gear/tailwheel-lock-armed', -1);
            }
            else {
                setprop('/controls/gear/tailwheel-lock-engaged', 1);
                setprop('/controls/gear/tailwheel-lock-armed', 0);
            }
        }
        else {
            setprop('/controls/gear/tailwheel-lock-engaged', 0);
            setprop('/controls/gear/tailwheel-lock-armed', 0);
        }
    }, 1, 0);

    setlistener('/gear/gear[2]/caster-angle-deg', func (node) {
        var engaged = getprop('/controls/gear/tailwheel-lock-engaged');
        if (engaged == 1)
            return; # nothing to do
        var armed = getprop('/controls/gear/tailwheel-lock-armed');
        if (armed == 0)
            return; # nothing to do
        var angle = node.getValue() or 0.0;
        if ((armed > 0 and angle < 3.0) or (armed < 0 and angle > -3.0)) {
            setprop('/fdm/jsbsim/gear/unit[2]/steering-angle-deg', 0);
            setprop('/controls/gear/tailwheel-lock-engaged', 1);
            setprop('/controls/gear/tailwheel-lock-armed', 0);
        }
    }, 1, 0);

    removelistener(initListener);
}, 0, 2);
