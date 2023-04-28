var previousChannel = func (prop) {
    var chan = getprop(prop);
    var frac = math.fmod(chan, 0.025);
    # 00 <- 05 <- 10 <- 15
    if (frac > 0.01667)
        chan = chan - frac + 0.015;
    elsif (frac > 0.0125)
        chan = chan - frac + 0.010;
    elsif (frac > 0.0075)
        chan = chan - frac + 0.005;
    elsif (frac > 0.0025)
        chan = chan - frac;
    else
        chan = chan - frac - 0.010;
    if (chan < 118.00) chan = 136.990;
    setprop(prop, chan);
};

var nextChannel = func (prop) {
    var chan = getprop(prop);
    var frac = math.fmod(chan, 0.025);
    # 00 -> 05 -> 10 -> 15
    if (frac < 0.0025)
        chan = chan - frac + 0.005;
    elsif (frac < 0.0075)
        chan = chan - frac + 0.010;
    elsif (frac < 0.0125)
        chan = chan - frac + 0.015;
    elsif (frac < 0.01667)
        chan = chan - frac + 0.025;
    else
        chan = chan - frac + 0.030;
    if (chan > 136.990) chan = 118.00;
    setprop(prop, chan);
};

var previousChannelCoarse = func (prop) {
    var chan = getprop(prop);
    var frac = math.fmod(chan, 1.0);
    chan = chan - 1;
    if (chan < 118.00) chan = 136.00 + frac;
    setprop(prop, chan);
};

var nextChannelCoarse = func (prop) {
    var chan = getprop(prop);
    var frac = math.fmod(chan, 1.0);
    chan = chan + 1;
    if (chan > 136.990) chan = 118.00 + frac;
    setprop(prop, chan);
};

