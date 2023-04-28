var version = '0.1beta';

var acdir = getprop('/sim/aircraft-dir');
var include = func (basename) {
    var path = acdir ~ '/Nasal/gps155/' ~ basename;
    printf("--- loading " ~ path ~ " ---");
    io.load_nasal(path, 'gps155');
}

var listeners = [];
var setlistener = func (node, code, init=0, type=1) {
    var l = globals.setlistener(node, code, init, type);
    append(listeners, l);
    return l;
};

var removelistener = func (l) {
    if (l == nil) return;
    var i = vecindex(listeners, l);
    if (i != nil) {
        listeners = subvec(listeners, 0, i) ~ subvec(listeners, i+1);
    }
    globals.removelistener(l);
};

var initialized = 0;

var loadIncludes = func {
    include('text.nas');
    include('input.nas');
    include('device.nas');
    include('pages/BasePage.nas');
    include('pages/ConfirmPage.nas');
    include('pages/MultiPage.nas');
    include('pages/DatabaseConfirmationPage.nas');
    include('pages/InitializationPage.nas');
    include('pages/NavPage.nas');
    include('pages/SatPage.nas');
    include('pages/WaypointConfirmPage.nas');
    include('pages/WaypointSelectPage.nas');
    include('pages/SettingsPage.nas');
    include('pages/RoutePage.nas');
};

var initialize = func {
    if (initialized) return;
    initialized = 1;

    include('screen.nas');
    loadIncludes();

    initScreen();
    initInput();
    initDevice();
};

globals.setlistener("sim/signals/fdm-initialized", initialize);

var reload = func {
    # clean up first
    foreach (var l; listeners) {
        globals.removelistener(l);
    }
    listeners = [];

    loadIncludes();

    initDevice();
    initInput();
};
