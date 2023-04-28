var dataKnobValues = { inner: 0, outer: 0 };
var dataKnobProps = {};

var handleInput = func (what, amount=0) {
    if (!contains(deviceProps, 'powered')) return;
    if (!deviceProps.powered.getBoolValue()) return;
    if (currentPage != nil) {
        if (currentPage.handleInput(what, amount)) {
            return;
        }
    }
    # Page hasn't handled the key
    if (what == 'DCT') {
        (func (returnPage) {
            if (visibleWaypoint != nil) {
                # The Direct-To key automatically picks up the "current"
                # waypoint on any page that defines one.
                loadPage(
                    WaypointConfirmPage.new(
                        visibleWaypoint,
                        # confirm
                        func {
                            setDTO(visibleWaypoint);
                            NavPage.currentSubpage = 0;
                            loadPage(NavPage.new());
                        },
                        # reject
                        func {
                            loadPage(returnPage);
                        }
                    ));
            }
            else {
                # If no "current" waypoint is defined, fire up a waypoint
                # selector menu (TODO).
            }
        })(currentPage);
    }
    elsif (what == 'NAV') {
        loadPage(NavPage.new());
    }
    elsif (what == 'SET') {
        loadPage(SettingsPage.new());
    }
    elsif (what == 'RTE') {
        loadPage(RoutePage.new());
    }
};

var initInput = func {
    foreach (var which; ['inner', 'outer']) {
        (func (which) {
            dataKnobProps[which] = props.globals.getNode('controls/gps155/data-' ~ which, 1);
            dataKnobProps[which].setValue(dataKnobValues[which]);
            setlistener(dataKnobProps[which], func (node) {
                var val = node.getValue();
                var dist = val - dataKnobValues[which];
                if (dist > 500) {
                    dist -= 1000;
                }
                elsif (dist < -500) {
                    dist += 1000;
                }
                dataKnobValues[which] = val;
                handleInput('data-' ~ which, dist);
            }, 1, 0);
        })(which);
    }
    setlistener('controls/gps155/key', func (node) {
        var which = node.getValue();
        if (which != '') {
            handleInput(which);
        }
    }, 1, 0);
};
