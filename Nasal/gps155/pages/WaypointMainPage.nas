var WaypointMainPage = {
    new: func () {
        deviceProps.currentPage.wpt.setValue(WaypointMainPage.SUBPAGE_MENU);
        var m = MultiPage.new(deviceProps.currentPage.wpt, 'WPT', 0);
        m.parents = [WaypointMainPage] ~ m.parents;
        return m;
    },

    SUBPAGE_MENU: 0,
    SUBPAGE_PROXIMITY: 1,
    SUBPAGE_USER: 2,
    SUBPAGE_COMMENTS: 3,

    getNumSubpages: func { return 1; },

    getSubpage: func (i) {
        if (i == me.SUBPAGE_MENU) return WaypointMenuPage.new();
        else return nil;
    },

    start: func {
        call(MultiPage.start, [], me);
        modeLightProp.setValue('WPT');
    },

    stop: func {
        call(MultiPage.stop, [], me);
        modeLightProp.setValue('');
    },
};

var WaypointMenuPage = {
    new: func () {
        var m = BasePage.new();
        m.parents = [WaypointMenuPage] ~ m.parents;
        return m;
    },

    start: func {
        call(BasePage.start, [], me);
        me.selectableFields = [
            { row: 1, col: 1,
                accept: func {
                    print("APT");
                    return 1;
                },
            },
            { row: 1, col: 7,
                accept: func {
                    print("VOR");
                    return 1;
                },
            },
            { row: 1, col: 13,
                accept: func {
                    print("NDB");
                    return 1;
                },
            },
            { row: 2, col: 1,
                accept: func {
                    print("INT");
                    return 1;
                },
            },
            { row: 2, col: 7,
                accept: func {
                    print("USER");
                    return 1;
                },
            },
        ];
    },

    redraw: func () {
        putScreen([
            'Select waypoint type',
            ' apt?  vor?  ndb? ',
            ' int?  user? '
        ]);
    },
};

var WaypointSearchPage = {
    new: func (category) {
        var m = BasePage.new();
        m.parents = [WaypointSearchPage] ~ m.parents;
        m.category = category;
        return m;
    },
};
