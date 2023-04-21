var meshEngine = func (v, which...) {
    if(size(which)) {
        foreach(var i; which)
            foreach(var e; engines)
            if(e.index == i) {
                var n = e.controls.getNode("boost-coil");
                if (n != nil)
                    n.setBoolValue(v);
            }
    }
    else {
        foreach(var e; engines)
            if(e.selected.getValue()) {
                var n = e.controls.getNode("boost-coil");
                if (n != nil)
                    n.setBoolValue(v);
            }
    }
}

var primeEngine = func (v, which...) {
    if(size(which)) {
        foreach(var i; which)
            foreach(var e; engines)
            if(e.index == i) {
                var n = e.controls.getNode("primer");
                if (n != nil)
                    n.setBoolValue(v);
            }
    }
    else {
        foreach(var e; engines)
            if(e.selected.getValue()) {
                var n = e.controls.getNode("primer");
                if (n != nil)
                    n.setBoolValue(v);
            }
    }
}

var _mixtureStops = [0, 0.25, 0.75, 1.0];

var _nextStop = func (v, stops) {
    foreach (var stop; stops) {
        if (stop > v)
            return stop;
    }
    return stops[size(stops) - 1];
};

var _prevStop = func (v, stops) {
    var acc = stops[0];
    foreach (var stop; stops) {
        if (stop >= v)
            break;
        else
            acc = stop;
    }
    return acc;
};

var modifyMixture = func (dir, which...) {
    var adjust = func (e) {
        var n = e.controls.getNode("mixture");
        var v = n.getValue();
        if (dir > 0)
            n.setValue(_nextStop(v, _mixtureStops));
        else
            n.setValue(_prevStop(v, _mixtureStops));
    };
    if(size(which)) {
        foreach(var i; which)
            foreach(var e; engines)
            if (e.index == i)
                adjust(e);
    }
    else {
        foreach(var e; engines)
            if(e.selected.getValue())
                adjust(e);
    }
}

var modifyCowlFlaps = func (dir, which...) {
    printf("Cowl flaps: %s", dir);
    var adjust = func (e) {
        var n = e.controls.getNode("cowl-flaps-cmd");
        if (n != nil) {
            var v = math.min(4, math.max(0, (n.getValue() or 0) - dir));
            n.setValue(v);
        }
    };
    if(size(which)) {
        foreach(var i; which)
            foreach(var e; engines)
            if (e.index == i)
                adjust(e);
    }
    else {
        foreach(var e; engines)
            if(e.selected.getValue())
                adjust(e);
    }
}
