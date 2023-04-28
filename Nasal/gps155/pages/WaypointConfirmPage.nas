var WaypointConfirmPage = {
    new: func (waypoint, accept, reject) {
        return {
            parents: [WaypointConfirmPage, BasePage],
            waypoint: waypoint,
            accept: accept,
            reject: reject,
        };
    },

    start: func {
        call(BasePage.start, [], me);
        me.redraw();
    },

    redraw: func {
        var lines = formatWaypointInfo(me.waypoint, '', 'ok?');
        putScreen(lines);
    },

    handleInput: func (what, amount) {
        if (call(BasePage.handleInput, [what, amount], me)) {
            return 1;
        }
        elsif (what == 'ENT') {
            me.accept();
            return 1;
        }
        elsif (what == 'CLR') {
            me.reject();
            return 1;
        }
    },
};
