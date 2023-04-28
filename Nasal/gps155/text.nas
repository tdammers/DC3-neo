var sc = {
    'updown': utf8.chstr(0x12),
    'cursor': utf8.chstr(0x16),
    'arrowL': utf8.chstr(0x1b),
    'arrowR': utf8.chstr(0x1a),
    'arrowUp': utf8.chstr(0x18),
    'arrowDn': utf8.chstr(0x19),

    'ft': utf8.chstr(0x80),
    'mt': utf8.chstr(0x81),
    'nm': utf8.chstr(0x82),
    'mi': utf8.chstr(0x83),
    'km': utf8.chstr(0x84),
    'kt': utf8.chstr(0x85),
    'mh': utf8.chstr(0x86),
    'kh': utf8.chstr(0x87),
    'gl': utf8.chstr(0x88),
    'kg': utf8.chstr(0x89),
    'lt': utf8.chstr(0x8a),
    'ig': utf8.chstr(0x8b),
    'lb': utf8.chstr(0x8c),
    'hg': utf8.chstr(0x8d),
    'mb': utf8.chstr(0x8e),

    'fr': utf8.chstr(0x90),
    'if': utf8.chstr(0x91),
    'ff': utf8.chstr(0x92),
    'mp': utf8.chstr(0x93),

    'cdiFromL3': utf8.chstr(0x94),
    'cdiFromL2': utf8.chstr(0x95),
    'cdiFromL1': utf8.chstr(0x96),
    'cdiFromC': utf8.chstr(0x19),
    'cdiFromR1': utf8.chstr(0x97),
    'cdiFromR2': utf8.chstr(0x98),
    'cdiFromR3': utf8.chstr(0x99),

    'cdiToL3': utf8.chstr(0x9a),
    'cdiToL2': utf8.chstr(0x9b),
    'cdiToL1': utf8.chstr(0x9c),
    'cdiToC': utf8.chstr(0x18),
    'cdiToR1': utf8.chstr(0x9d),
    'cdiToR2': utf8.chstr(0x9e),
    'cdiToR3': utf8.chstr(0x9f),

    'copy': utf8.chstr(0xb9),
    'deg': utf8.chstr(0xc0),
    'degC': utf8.chstr(0xc4),
    'degF': utf8.chstr(0xc5),
    'dot': utf8.chstr(0xc7),
};

# Convert a regular numeric string into a small-size string, as per the GPS155
# font.
# The following special characters and transformations are applied:
# - A digit or underscore following a dot character is converted to the
#   corresponding small-size character with integrated leading dot
#   (0xD0 series)
# - A digit or underscore followed by a tick character is converted to the
#   corresponding small-size character with integrated trailing tick
#   (0xE0 series)
# - A digit or underscore following a backtick character is converted to the
#   corresponding right-aligned small-size character (0xA0 series), and the
#   backtick removed
# - A space following a backtick character is converted to a plain space, and
#   the backtick removed
# - A digit or underscore outside of the above situations is converted to the
#   corresponding regular small-size character (0xF0 series)
# - All other characters are left untouched
var smallStr = func (str) {
    var accum = '';
    var rem = isstr(str) ? str : '';
    var c = '';
    var d = '';
    var series = 0xf0;
    var offset = 0x00;
    var dot = utf8.strc('.', 0);
    var tick = utf8.strc('\'', 0);
    var backtick = utf8.strc('`', 0);
    var underscore = utf8.strc('_', 0);
    var space = utf8.strc(' ', 0);
    while (size(rem) > 0) {
        c = (size(rem) >= 1) ? rem[0] : 0;
        d = (size(rem) >= 2) ? rem[1] : 0;

        if (c == dot and string.isdigit(d)) {
            series = 0xd0;
            offset = d & 0x0f;
            rem = substr(rem, 2);
            accum = accum ~ utf8.chstr(series + offset);
        }
        elsif (c == dot and d == underscore) {
            series = 0xd0;
            offset = 0x0a;
            rem = substr(rem, 2);
            accum = accum ~ utf8.chstr(series + offset);
        }
        elsif (c == backtick and string.isdigit(d)) {
            series = 0xa0;
            offset = d & 0x0f;
            rem = substr(rem, 2);
            accum = accum ~ utf8.chstr(series + offset);
        }
        elsif (c == backtick and d == underscore) {
            series = 0xa0;
            offset = 0x0a;
            rem = substr(rem, 2);
            accum = accum ~ utf8.chstr(series + offset);
        }
        elsif (c == backtick and d == space) {
            rem = substr(rem, 2);
            accum = accum ~ ' ';
        }
        elsif (d == tick and string.isdigit(c)) {
            series = 0xe0;
            offset = c & 0x0f;
            rem = substr(rem, 2);
            accum = accum ~ utf8.chstr(series + offset);
        }
        elsif (d == tick and c == underscore) {
            series = 0xe0;
            offset = 0x0a;
            rem = substr(rem, 2);
            accum = accum ~ utf8.chstr(series + offset);
        }
        elsif (string.isdigit(c)) {
            series = 0xf0;
            offset = c & 0x0f;
            rem = substr(rem, 1);
            accum = accum ~ utf8.chstr(series + offset);
        }
        elsif (c == underscore) {
            series = 0xf0;
            offset = 0x0a;
            rem = substr(rem, 1);
            accum = accum ~ utf8.chstr(series + offset);
        }
        else {
            accum = accum ~ utf8.substr(rem, 0, 1);
            rem = substr(rem, 1);
        }
    }
    return accum;
};

var formatLat = func (lat) {
    var result = '';
    if (lat < 0) {
        result = 'S';
        lat = -lat;
    }
    else {
        result = 'N';
    }
    var degrees = math.floor(lat);
    var minutesF = (lat - degrees) * 60;
    var minutes = math.floor(minutesF);
    var minutesFrac = math.floor((minutesF - minutes) * 1000);

    result ~= sprintf('%02i', degrees) ~
              sc.deg ~
              sprintf('%02i', minutes) ~
              smallStr(sprintf('.%03i\'', minutesFrac));
};

var formatLon = func (lat) {
    var result = '';
    if (lat < 0) {
        result = 'W';
        lat = -lat;
    }
    else {
        result = 'E';
    }
    var degrees = math.floor(lat);
    var minutesF = (lat - degrees) * 60;
    var minutes = math.floor(minutesF);
    var minutesFrac = math.floor((minutesF - minutes) * 1000);

    result ~= sprintf('%03i', degrees) ~
              sc.deg ~
              sprintf('%02i', minutes) ~
              smallStr(sprintf('.%03i\'', minutesFrac));
};

formatWaypointInfo = func (waypoint, indexStr = '', promptStr = '') {
    var extraInfo0 = '';
    var extraInfo1 = '';
    var extraInfo2 = '';

    var line0 = '';
    var line1 = '';
    var line2 = '';

    var type = '';
    if (ghosttype(waypoint) == 'flightplan-leg') {
        extraInfo2 = waypoint.wp_name;
    }
    else {
        extraInfo2 = waypoint.name;
    }
    if (ghosttype(waypoint) == 'airport' or ghosttype(waypoint) == 'FGAirport') {
        var apinfo = airportinfo(waypoint.id);
        extraInfo0 = formatAltitude(waypoint.elevation);
        var twrStation = nil;
        var ctfStation = nil;
        var uniStation = nil;
        foreach (var commStation; waypoint.comms()) {
            # debug.dump(commStation.name ~ ' ' ~ commStation.frequency);
            if (twrStation == nil and
                (commStation.name == 'TWR' or
                    string.imatch(commStation.name, '* TWR') or
                    string.imatch(commStation.name, '*Tower*'))) {
                twrStation = commStation;
            }
            elsif (ctfStation == nil and
                (commStation.name == 'RADIO' or
                    string.imatch(commStation.name, 'CTAF*') or
                    string.imatch(commStation.name, '* RADIO'))) {
                ctfStation = commStation;
            }
            elsif (uniStation == nil and
                (commStation.name == 'UNICOM') or
                 string.imatch(commStation.name, '* UNICOM')) {
                uniStation = commStation;
            }
        }
        if (twrStation != nil)
            extraInfo1 = 'twr' ~ format8_33khz(twrStation.frequency);
        elsif (uniStation != nil)
            extraInfo1 = 'uni' ~ format8_33khz(uniStation.frequency);
        elsif (ctfStation != nil)
            extraInfo1 = 'ctf' ~ format8_33khz(ctfStation.frequency);
        if (promptStr == '') {
            var longestLength = 0;
            var bestRunway = nil;
            foreach (var idx; keys(apinfo.runways)) {
                var runway = apinfo.runways[idx];
                if (runway.length > longestLength) {
                    bestRunway = runway;
                }
            }
            if (bestRunway != nil) {
                if (bestRunway.reciprocal == nil) {
                    extraInfo2 = 
                        sprintf('rnwy %-3s      %6s',
                            bestRunway.id,
                            formatRunwayLength(bestRunway.length, 'm'));
                }
                else {
                    if (bestRunway.heading > bestRunway.reciprocal.heading)
                        bestRunway = bestRunway.reciprocal;
                    extraInfo2 = 
                        sprintf('rnwy %-3s/%-3s %5s',
                            bestRunway.id,
                            bestRunway.reciprocal.id,
                            formatRunwayLength(bestRunway.length, 'm'));
                }
            }
        }
    }
    elsif (ghosttype(waypoint) == 'flightplan-leg') {
        extraInfo0 = '';
    }
    elsif (waypoint.type == 'VOR') {
        extraInfo0 = format25khz(waypoint.frequency / 100);
    }
    elsif (waypoint.type == 'NDB') {
        extraInfo0 = format1khz(waypoint.frequency / 100);
    }
    var db = getWaypointDistanceAndBearing(waypoint);
    if (indexStr == '')
        line0 =
            sprintf("%-3s %-5s %-11s",
                getWaypointType(waypoint, 1),
                substr(waypoint.id, 0, 5),
                extraInfo0);
    else
        line0 =
            sprintf("%-3s %-3s %-5s %-7s",
                indexStr,
                getWaypointType(waypoint, 1),
                substr(waypoint.id, 0, 5),
                extraInfo0);
    line1 =
        sprintf(' %4s%5s %-9s',
            formatHeading(db.bearing),
            formatDistanceShort(db.distance),
            extraInfo1);
    if (promptStr == '')
        line2 =
            sprintf(' %-20s',
                shorten(extraInfo2, 20));
    else
        line2 =
            sprintf(' %-15s %3s',
                shorten(extraInfo2, 15),
                promptStr);
    return [line0, line1, line2];
};

var formatSatStatus = func(status, satellites) {
    var identLine = 'sat ';
    var sglLine = 'sgl ';
    var totalStrength = 0;
    foreach (var sat; satellites) {
        identLine ~= smallStr(sprintf('`%2i', sat.ident));
        sglLine ~= smallStr(sprintf('`%2i', math.round(sat.sgl * 10)));
        totalStrength += sat.sgl;
    }

    var epe = 100 / totalStrength; # TODO: proper EPE calculation

    return [
        sprintf('%-11s epe%5s',
            receiverStatusTexts[status],
            string.trim(formatRunwayLength(epe))),
        identLine,
        sglLine,
    ];
};

var degF2degC = func (f) {
    return (f-32) / 1.8;
};

var degC2degF = func (c) {
    return c*1.8 + 32;
};

var fuelDensity = 718.9585645;

var units = {
    # Position (lat/lon)
    'dm': { inFactor: 1, outFactor: 1, symbol: 'dm' },
    'dms': { inFactor: 1, outFactor: 1, symbol: 'dms' },

    # Lengths (distance, altitude, ...); canonical unit: m
    'm':  { inFactor:    1, outFactor: 1, symbol: sc.mt },
    'ft': { inFactor: FT2M, outFactor: 1, symbol: sc.ft },
    'km': { inFactor: 1000, outFactor: 1/1000, symbol: sc.km },
    'nm': { inFactor: NM2M, outFactor: M2NM, symbol: sc.nm },
    'mi': { inFactor: 1608.344, outFactor: 1/1608.344, symbol: sc.mi },

    # Speeds; canonical unit: m/s
    'kt': { inFactor: KT2MPS, outFactor: MPS2KT, symbol: sc.kt },
    'kmh': { inFactor: 3600/1000, outFactor: 1000/3600, symbol: sc.kh },
    'mph': { inFactor: 3600/1608.344, outFactor: 1608.344/3600, symbol: sc.mh },

    # Vertical speeds; canonical unit: m/s
    'mps': { inFactor: 1, outFactor: 1, symbol: 'mps' },
    'mpm': { inFactor: 60, outFactor: 1/60, symbol: 'mpm' },
    'fps': { inFactor: FT2M, outFactor: M2FT, symbol: 'fps' },
    'fpm': { inFactor: FT2M * 60, outFactor: M2FT / 60, symbol: 'fpm' },

    # Pressure; canonical unit: hPa
    'hpa': { inFactor: 1, outFactor: 1, symbol: sc.mb, format: '%4.0f' },
    'mbar': { inFactor: 1, outFactor: 1, symbol: sc.mb, format: '%4.0f' },
    'inhg': { inFactor: 1013.25/29.921, outFactor: 29.921/1013.25, symbol: sc.hg, format: '%2.2f' },

    # Temperature; canonical unit: °C
    'degC': { inFactor: 1, outFactor: 1, symbol: sc.degC },
    'degF': { inFactor: degF2degC, outFactor: degC2degF, symbol: sc.degF },

    # Fuel; canonical unit: kg
    'kg': { inFactor: 1, outFactor: 1, symbol: sc.kg },
    'lbs': { inFactor: LB2KG, outFactor: LB2KG, symbol: sc.lb },
    'lt': { inFactor: 0.001 * fuelDensity, outFactor: 1000 / fuelDensity, symbol: sc.lt },
    'l': { inFactor: 0.001 * fuelDensity, outFactor: 1000 / fuelDensity, symbol: sc.lt },
    'gal': { inFactor: GAL2L * 0.001 * fuelDensity
           , outFactor: L2GAL * 1000 / fuelDensity
           , symbol: sc.gl
           },
    'igal': { inFactor: 4.54609 * 0.001 * fuelDensity
            , outFactor: 1000 / 4.54609 / fuelDensity
            , symbol: sc.ig
            },
};

unitSymbol = func (unit) {
    return units[unit].symbol;
};

convertUnits = func (val, inUnit, outUnit) {
    if (inUnit == outUnit)
        return val;

    var inFactor = units[inUnit].inFactor;
    var outFactor = units[outUnit].outFactor;

    if (typeof(inFactor) == 'func') {
        val = inFactor(val);
    }
    else {
        val *= inFactor;
    }
    if (typeof(outFactor) == 'func') {
        val = outFactor(val);
    }
    else {
        val *= outFactor;
    }
    return val;
};

formatTemperature = func (temp, inUnit='degC') {
    var outUnit = deviceProps.settings.units.temperature.getValue() or 'degC';
    var displayValue = convertUnits(temp, inUnit, outUnit);
    var symbol = units[outUnit].symbol;
    return sprintf('%3i' ~ symbol, displayValue);
};

formatAltitude = func (alt, inUnit='ft') {
    var outUnit = deviceProps.settings.units.altitude.getValue() or 'ft';
    var displayValue = convertUnits(alt, inUnit, outUnit);
    var symbol = units[outUnit].symbol;
    return sprintf('%5i' ~ symbol, displayValue);
};

formatSpeed = func (speed, inUnit='kts') {
    var outUnit = deviceProps.settings.units.speed.getValue() or 'kts';
    var displayValue = convertUnits(speed, inUnit, outUnit);
    var symbol = units[outUnit].symbol;
    return sprintf('%4i' ~ symbol, displayValue);
};

formatRunwayLength = func (len, inUnit='ft') {
    var outUnit = deviceProps.settings.units.runwayLength.getValue() or 'ft';
    var displayValue = convertUnits(len, inUnit, outUnit);
    var symbol = units[outUnit].symbol;
    return sprintf('%5i' ~ symbol, displayValue);
};

formatHeading = func (hdg) {
    hdg = math.round(geo.normdeg(hdg));
    if (hdg < 1)
        hdg += 360;
    if (hdg >= 361)
        hdg -= 360;
    return sprintf('%03i' ~ sc.deg, hdg);
};

var formatDistanceLong = func (dist, inUnit='nm') {
    var outUnit = deviceProps.settings.units.distance.getValue() or 'ft';
    var displayValue = convertUnits(dist, inUnit, outUnit);
    var symbol = units[outUnit].symbol;

    if (displayValue > 999999) {
        return '++++++';
    }
    elsif (displayValue < 0) {
        return '------';
    }
    elsif (displayValue < 1000) {
        var i = math.floor(displayValue);
        var f = math.floor((displayValue - i) * 100);
        return sprintf('%4i', i) ~ smallStr(sprintf('.%02i', f)) ~ symbol;
    }
    elsif (displayValue < 10000) {
        var i = math.floor(displayValue);
        var f = math.floor((displayValue - i) * 10);
        return sprintf('%5i', i) ~ smallStr(sprintf('.%01i', f)) ~ symbol;
    }
    else {
        return sprintf('%6i', displayValue) ~ symbol;
    }
};

var formatDistance = func (dist, inUnit='nm') {
    var outUnit = deviceProps.settings.units.distance.getValue() or 'ft';
    var displayValue = convertUnits(dist, inUnit, outUnit);
    var symbol = units[outUnit].symbol;

    if (displayValue > 99999) {
        return '+++++';
    }
    elsif (displayValue < 0) {
        return '-----';
    }
    elsif (displayValue < 100) {
        var i = math.floor(displayValue);
        var f = math.floor((displayValue - i) * 100);
        return sprintf('%2i', i) ~ smallStr(sprintf('.%02i', f)) ~ symbol;
    }
    elsif (displayValue < 1000) {
        var i = math.floor(displayValue);
        var f = math.floor((displayValue - i) * 10);
        return sprintf('%3i', i) ~ smallStr(sprintf('.%01i', f)) ~ symbol;
    }
    else {
        return sprintf('%4i', displayValue) ~ symbol;
    }
};

var formatDistanceShort = func (dist) {
    var inUnit = 'nm';
    var outUnit = deviceProps.settings.units.distance.getValue() or 'ft';
    var displayValue = convertUnits(dist, inUnit, outUnit);
    var symbol = units[outUnit].symbol;

    if (displayValue > 9999) {
        return '++++';
    }
    elsif (displayValue < 0) {
        return '----';
    }
    if (displayValue < 10) {
        var i = math.floor(displayValue);
        var f = math.floor((displayValue - i) * 100);
        return sprintf('%1i', i) ~ smallStr(sprintf('.%02i', f)) ~ symbol;
    }
    if (displayValue < 100) {
        var i = math.floor(displayValue);
        var f = math.floor((displayValue - i) * 10);
        return sprintf('%2i', i) ~ smallStr(sprintf('.%01i', f)) ~ symbol;
    }
    else {
        return sprintf('%3i', math.round(displayValue)) ~ symbol;
    }
};

var format25khz = func (freq) {
    var i = math.floor(freq);
    var f = math.floor((freq - i) * 100 + 0.05);
    return sprintf('%3i', i) ~ smallStr(sprintf('.%02i', f));
};

var format8_33khz = func (freq) {
    var i = math.floor(freq - 100);
    var f = math.round((freq - 100 - i) * 1000);
    if (math.mod(math.round(freq * 1000), 25) == 0)
        return ' ' ~ format25khz(freq);
    else
        return smallStr('`1') ~ sprintf('%02i', i) ~ smallStr(sprintf('.%03i', f));
};

var format1khz = func (freq) {
    var i = math.floor(freq);
    var f = math.floor((freq - i) * 10);
    return sprintf('%4i', i) ~ smallStr(sprintf('.%01i', f));
};

var shorten = func (str, maxlen) {
    if (utf8.size(str) <= maxlen)
        return str;

    var half = math.ceil((maxlen - 2) / 2);
    return utf8.substr(str, 0, half) ~
           '..' ~
           utf8.substr(str, utf8.size(str) - (maxlen - 2 - half));
};

var longSpace = '                                                             ';

var alignCenter = func (str, maxlen) {
    var l = utf8.size(str);
    if (l > maxlen) {
        return shorten(str, maxlen);
    }
    else {
        var left = math.floor((maxlen - l) / 2);
        var right = maxlen - l - left;
        return substr(longSpace, 0, left) ~ str ~ substr(longSpace, 0, right);
    }
};

var navid5 = func (str) {
    if (utf8.size(str) <= 5) return str;
    if (string.match(str, '*-*')) {
        return utf8.substr(str, 0, 4);
    }
    else {
        return utf8.substr(str, 0, 5);
    }
};

var scrollAlphabet = [
    " ",
    "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M",
    "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
    "0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
    "_", "-", "/", ",", ".", "?", "!" ];

var scrollChar = func (str, index, amount) {
    if (utf8.size(str) < index) return str;
    var charNum = vecindex(scrollAlphabet, string.uc(utf8.substr(str, index, 1)));
    if (charNum == nil)
        charNum = 0;
    else
        charNum = math.mod(charNum + amount, size(scrollAlphabet));
    str = utf8.substr(str, 0, index) ~ scrollAlphabet[charNum];
    return str;
};

var parseApproachID = func (approachID) {
    var rem = approachID;
    var consume = func (count) {
        var result = substr(rem, 0, count);
        rem = substr(rem, count);
        return result;
    };
    var approachType = string.lc(consume(3));
    var approachLetter = '';
    if (!string.isdigit(rem[0])) {
        approachLetter = consume(1);
    }
    var runway = rem;
    return {
        id: approachID,
        type: approachType,
        letter: approachLetter,
        runway: runway,
    };
};

var formatApproach = func (approach) {
    if (isscalar(approach)) {
        approach = parseApproachID(approach);
    }
    elsif (isghost(approach)) {
        approach = parseApproachID(approach.id);
    }
    return sprintf('%3s %1s rw%-3s',
        approach.type, approach.letter, approach.runway);
};
