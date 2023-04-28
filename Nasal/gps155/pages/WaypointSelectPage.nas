var WaypointSelectPage = {
    new: func (waypoints, accept, reject) {
        return {
            parents: [WaypointSelectPage, BasePage],
            waypoints: waypoints,
            selectedWP: 0,
            accept: accept,
            reject: reject,
        };
    },

    start: func {
        call(BasePage.start, [], me);
        me.redraw();
    },

    redraw: func {
        var waypoint = me.waypoints[me.selectedWP];
        var number = me.selectedWP + 1;
        var formattedNumber = '';
        if (number < 10) {
            formattedNumber = 'nr' ~ number;
        }
        else {
            formattedNumber = '#' ~ number;
        }
        putScreen(formatWaypointInfo(waypoint, formattedNumber));
    },

    handleInput: func (what, amount) {
        if (call(BasePage.handleInput, [what, amount], me)) {
            return 1;
        }
        elsif (what == 'data-inner') {
            me.selectedWP += amount;
            me.selectedWP = math.min(size(me.waypoints) - 1, math.max(0, me.selectedWP));
            me.redraw();
        }
        elsif (what == 'ENT') {
            me.accept(me.waypoints[me.selectedWP]);
            return 1;
        }
        elsif (what == 'CLR') {
            me.reject();
            return 1;
        }
        else {
            return 0;
        }
    },
};
