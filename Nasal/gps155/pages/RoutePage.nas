var RoutePage = {
    new: func () {
        var m = MultiPage.new(deviceProps.currentPage.rte, 'RTE');
        m.parents = [RoutePage] ~ m.parents;
        return m;
    },

    SUBPAGE_ACTIVE_ROUTE: 0,
    SUBPAGE_APPROACH_SELECT: 1,
    SUBPAGE_STAR_SELECT: 2,
    SUBPAGE_SID_SELECT: 3,

    getNumSubpages: func { return 4; },
    getSubpage: func (i) {
        if (i == RoutePage.SUBPAGE_ACTIVE_ROUTE) {
            return ActiveRoutePage.new(me);
        }
        elsif (i == RoutePage.SUBPAGE_APPROACH_SELECT) {
            return ApproachSelectPage.new(me);
        }
        elsif (i == RoutePage.SUBPAGE_STAR_SELECT) {
            return STARSelectPage.new(me);
        }
        elsif (i == RoutePage.SUBPAGE_SID_SELECT) {
            return SIDSelectPage.new(me);
        }
        else {
            return nil;
        }
    },

    start: func {
        call(MultiPage.start, [], me);
        modeLightProp.setValue('RTE');
    },

    stop: func {
        call(MultiPage.stop, [], me);
        modeLightProp.setValue('');
    },
};

var ActiveRoutePage = {
    new: func () {
        return {
            parents: [ActiveRoutePage, BasePage],
            editableWaypointID: '',
            deletingWaypoint: 0,
        };
    },

    scrollResetTimer: 0,
    scrollPos: 0,

    start: func {
        call(BasePage.start, [], me);
        var fp = flightplan();
        if (fp != nil) {
            var idx = ActiveRoutePage.scrollPos + 1;
            if (idx < fp.getPlanSize()) {
                me.editableWaypointID = fp.getWP(idx).id;
            }
        }
        me.setSelectableFields();
        me.redraw();
    },

    editingWaypoint: func {
        return (me.selectedField >= 0 and me.selectedField < 5);
    },

    setSelectableFields: func {
        var self = me;
        me.selectableFields = [];
        for (var i = 0; i < 5; i += 1) {
            (func (i) {
                append(self.selectableFields, {
                    row: 2,
                    col: 3 + i,
                    changeValue: func (amount) {
                        self.editableWaypointID = scrollChar(self.editableWaypointID, i, amount);
                        self.redraw();
                    }
                });
            })(i);
        }
        append(self.selectableFields,
            { row: 0, col: 12,
              changeValue: func(amount) {
                cycleProp(deviceProps.settings.fields.route.distanceMode,
                    ['leg', 'cum', 'rem'],
                    amount);
                self.redraw();
              }
            });
        append(self.selectableFields,
            { row: 0, col: 17,
              changeValue: func(amount) {
                cycleProp(deviceProps.settings.fields.route.legExtraMode,
                    ['dtk', 'ete', 'eta'],
                    amount);
                self.redraw();
              }
            });
    },

    update: func (dt) {
        var fp = flightplan();
        if (me.selectedField < 0 and fp != nil) {
            ActiveRoutePage.scrollResetTimer -= dt;
            if (ActiveRoutePage.scrollResetTimer <= 0)
                ActiveRoutePage.scrollPos = math.max(0, fp.current - 1);
        }
        else {
            ActiveRoutePage.scrollResetTimer = 10;
        }
        me.redraw();
    },

    redraw: func {
        var fp = flightplan();
        var fromID = deviceProps.wp[0].ident.getValue() or '';
        var tgtID = deviceProps.wp[1].ident.getValue() or '';
        var mode = deviceProps.mode.getValue() or 'obs';
        var legInfo = '_____' ~ sc.arrowR ~ '_____';

        var lines = ['', 'NO ACTIVE ROUTE', ''];
        if (mode == 'dto') {
            legInfo = sprintf('go to:%-5s', navid5(tgtID));
        }
        elsif (mode == 'leg') {
            legInfo = sprintf('%-5s' ~ sc.arrowR ~ '%-5s',
                            navid5(fromID), navid5(tgtID));
        }

        var distMode = deviceProps.settings.fields.route.distanceMode.getValue();
        var extraMode = deviceProps.settings.fields.route.legExtraMode.getValue();
        lines[0] = sprintf('%-11s %3s  %3s', legInfo, distMode, extraMode);

        if (fp != nil and fp.getPlanSize() > 1) {
            for (var y = 0; y < 2; y += 1) {
                var index = ActiveRoutePage.scrollPos + y;
                var wp = fp.getWP(index);
                var wpPrev = (index > 0) ? fp.getWP(index - 1) : nil;
                var wpCurr = fp.currentWP();
                var current = index == fp.current;
                var first = ActiveRoutePage.scrollPos == 0;
                var last = ActiveRoutePage.scrollPos >= fp.getPlanSize() - 1;
                var scrollSymbol = ' ';
                if (!first) {
                    if (!last) {
                        scrollSymbol = sc.updown;
                    }
                    else {
                        scrollSymbol = sc.arrowUp;
                    }
                }
                else {
                    if (!last) {
                        scrollSymbol = sc.arrowDn;
                    }
                    else {
                        scrollSymbol = ' ';
                    }
                }

                var distStr = '__' ~ smallStr('.___');
                var extraStr = '_____';
                var identStr = '';
                var wpSymbol = '';

                if (wpPrev != nil and wp != nil) {
                    # Determine IAF
                    # debug.dump(wp.wp_role, wpPrev.wp_role);
                    if (wp.wp_role == 'approach' and wpPrev.wp_role != 'approach') {
                        wpSymbol = sc['if'];
                    }
                }

                if (y == 1 and me.editingWaypoint()) {
                    identStr = me.editableWaypointID;
                }
                elsif (wp != nil) {
                    if (distMode == 'leg')
                        distStr = formatDistance(wp.leg_distance);
                    elsif (distMode == 'cum')
                        distStr = formatDistance(wp.distance_along_route);
                    elsif (distMode == 'rem')
                        distStr = formatDistance ((getprop('/autopilot/route-manager/total-distance') or 0) - wp.distance_along_route);
                    if (extraMode == 'dtk')
                        extraStr = ' ' ~ formatHeading(wp.leg_bearing);
                    elsif (extraMode == 'ete') {
                        var gs = math.max(100, deviceProps.groundspeed.getValue() or 0);
                        var eteMinutesRaw = math.round(60 * wp.leg_distance / gs);
                        var eteMinutes = math.mod(eteMinutesRaw, 60);
                        var eteHours = math.floor(eteMinutesRaw / 60);
                        extraStr = sprintf("%2i:%02i", eteHours, eteMinutes);
                    }
                    elsif (extraMode == 'eta') {
                        var distIntoRoute = wpCurr.distance_along_route - deviceProps.wp[1].distance.getValue();
                        var gs = math.max(100, deviceProps.groundspeed.getValue() or 0);
                        var eteMinutesRaw = 60 * (wp.distance_along_route - distIntoRoute)  / gs;
                        var etaMinutesRaw = math.round(getprop('/sim/time/utc/day-seconds') / 60 + eteMinutesRaw);
                        var etaMinutes = math.mod(etaMinutesRaw, 60);
                        var etaHours = math.mod(math.floor(etaMinutesRaw / 60), 24);
                        extraStr = sprintf("%02i:%02i", etaHours, etaMinutes);
                    }
                    identStr = navid5(wp.id, 5);
                }

                if (me.deletingWaypoint and y == 1) {
                    lines[y+1] = sprintf('%1s%1s%1s%_____           ',
                        (y == 0) ? ' ' : scrollSymbol,
                        wpSymbol,
                        current ? sc.arrowR : ':');
                }
                else {
                    lines[y+1] = sprintf('%1s%1s%1s%-5s %5s %-5s',
                        (y == 0) ? ' ' : scrollSymbol,
                        wpSymbol,
                        current ? sc.arrowR : ':',
                        identStr,
                        distStr,
                        extraStr);
                }
            }
        }
        else {
            if (me.editingWaypoint()) {
                lines[2] = sprintf('   %-5s______ ___ ', me.editableWaypointID);
            }
        }

        putScreen(lines);
    },

    handleInput: func (what, amount) {
        var fp = flightplan();
        if (call(BasePage.handleInput, [what, amount], me)) {
            return 1;
        }
        elsif (what == 'data-inner') {
            if (fp == nil) {
                ActiveRoutePage.scrollPos = 0;
            }
            else {
                var maxPos = fp.getPlanSize() - 2;
                ActiveRoutePage.scrollPos += amount;
                if (ActiveRoutePage.scrollPos < 0) ActiveRoutePage.scrollPos = 0;
                if (ActiveRoutePage.scrollPos > maxPos) ActiveRoutePage.scrollPos = maxPos;
            }
            var idx = ActiveRoutePage.scrollPos + 1;
            if (fp != nil and idx < fp.getPlanSize()) {
                me.editableWaypointID = fp.getWP(idx).id;
            }
            ActiveRoutePage.scrollResetTimer = 10;
            me.redraw();
        }
        elsif (what == 'CLR') {
            (func (returnPage) {
                loadPage(
                    ConfirmPage.new(
                        "CLEAR ROUTE",
                        # confirm
                        func {
                            fp.cleanPlan();
                            fp.departure = nil;
                            fp.destination = nil;
                            ActiveRoutePage.scrollPos = 0;
                            loadPage(NavPage.new());
                        },
                        # reject
                        func {
                            loadPage(returnPage);
                        }
                    ));
                })(currentPage);
        }
        elsif (what == 'DCT') {
            (func (returnPage) {
                var wp = fp.getWP(ActiveRoutePage.scrollPos + 1);
                if (wp != nil) {
                    # debug.dump(wp);
                    loadPage(
                        WaypointConfirmPage.new(
                            wp,
                            # confirm
                            func {
                                setDTO(wp);
                                loadPage(NavPage.new(NavPage.SUBPAGE_CDI));
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
                return 1;
            })(currentPage);
        }
        elsif (what == 'ENT' and me.deletingWaypoint) {
            fp.deleteWP(ActiveRoutePage.scrollPos + 1);
            me.deletingWaypoint = 0;
            me.selectedField = -1;
            unsetCursor();
            me.redraw();
        }
        elsif (what == 'ENT' and me.editingWaypoint()) {
            var self = me;
            searchAndConfirmWaypoint(me.editableWaypointID, self, func (waypoint) {
                var leg = createWP(waypoint.lat, waypoint.lon, waypoint.ident);
                if (fp.getPlanSize() == 1 and (ghosttype(waypoint) == 'airport' or ghosttype(waypoint) == 'FGAirport')) {
                    fp.destination = airportinfo(waypoint.id);
                }
                elsif (ActiveRoutePage.scrollPos >= fp.getPlanSize())
                    fp.appendWP(leg);
                else
                    fp.insertWPAfter(leg, ActiveRoutePage.scrollPos);
                ActiveRoutePage.scrollPos += 1;
            });
        }
        elsif (what == 'ENT' and deviceProps.mode.getValue() != 'leg') {
            deviceProps.command.setValue('leg');
            # TODO: find closest leg
            me.redraw();
        }
        elsif (what == 'CLR' and me.deletingWaypoint) {
            me.deletingWaypoint = 0;
            me.redraw();
        }
        elsif (what == 'CLR' and me.editingWaypoint() and me.scrollPos + 1 < fp.getPlanSize()) {
            me.deletingWaypoint = 1;
            me.redraw();
        }
    },
};

var ApproachSelectPage = {
    new: func (parentPage) {
        var m = ProcedureSelectPage.new(parentPage);
        m.parents = [ApproachSelectPage] ~ m.parents;
        m.fp = nil;
        return m;
    },

    start: func {
        me.fp = flightplan();
        me.available = me.fp.active and me.fp.destination != nil;
        call(ProcedureSelectPage.start, [], me);
    },

    getProcedures: func { return (me.fp.destination == nil) ? [] : me.fp.destination.getApproachList(); },
    getProcedureTypeName: func { return 'appr'; },
    selectProcedure: func (procedure) { me.fp.approach = procedure; },
    getRefWaypointName: func { return me.fp.destination.id; },
    formatProcedure: func (procedure) { return formatApproach(procedure); },
    isCurrentProcedure: func (procedure) { return (me.fp.approach != nil and procedure == me.fp.approach.id); },
    procedureSelected: func { return me.fp.approach != nil; },
};

var STARSelectPage = {
    new: func (parentPage) {
        var m = ProcedureSelectPage.new(parentPage);
        m.parents = [STARSelectPage] ~ m.parents;
        m.fp = nil;
        return m;
    },

    start: func {
        me.fp = flightplan();
        me.available = me.fp.active and me.fp.destination != nil;
        call(ProcedureSelectPage.start, [], me);
    },

    getProcedures: func { return (me.fp.destination == nil) ? [] : me.fp.destination.stars(); },
    getProcedureTypeName: func { return 'star'; },
    selectProcedure: func (procedure) {
        if (procedure == nil)
            me.fp.star = nil;
        else
            me.fp.star = me.fp.destination.getStar(procedure);
    },
    getRefWaypointName: func { return me.fp.destination.id; },
    formatProcedure: func (procedure) {
        var star = me.fp.destination.getStar(procedure);
        var runways = star.runways;
        if (size(runways) == 1)
            return sprintf("%-6s %4s", procedure, runways[0]);
        else
            return procedure;
    },
    isCurrentProcedure: func (procedure) { return (me.fp.star != nil and procedure == me.fp.star.id); },
    procedureSelected: func { return me.fp.star != nil; },
};

var SIDSelectPage = {
    new: func (parentPage) {
        var m = ProcedureSelectPage.new(parentPage);
        m.parents = [SIDSelectPage] ~ m.parents;
        m.fp = nil;
        return m;
    },

    start: func {
        me.fp = flightplan();
        me.available = me.fp.active and me.fp.departure != nil;
        call(ProcedureSelectPage.start, [], me);
    },

    getProcedures: func { return (me.fp.departure == nil) ? [] : me.fp.departure.sids(); },
    getProcedureTypeName: func { return 'sid'; },
    selectProcedure: func (procedure) {
        var self = me;
        var wpIndex = me.fp.current;
        if (procedure == nil) {
            me.fp.sid = nil;
        }
        else {
            me.fp.sid = me.fp.departure.getSid(procedure);
            if (size(me.fp.sid.transitions) > 1) {
                me.parentPage.setSubpage(SIDTransitionSelectPage.new(me.parentPage));
                me.fp.activate();
                if (wpIndex == 0)
                    me.fp.current = 0;
            }
            elsif (size(me.fp.sid.runways) > 1) {
                me.parentPage.setSubpage(RunwaySelectPage.new(me.parentPage,
                    me.fp.departure.id,
                    me.fp.sid.runways,
                    func (runwayID) {
                        self.fp.departure_runway = self.fp.departure.runway(runwayID);
                        self.fp.activate();
                        if (wpIndex == 0)
                            self.fp.current = 0;
                    }));
            }
            else {
                me.fp.departure_runway = me.fp.departure.runway(me.fp.sid.runways[0]);
                me.fp.activate();
                if (wpIndex == 0)
                    me.fp.current = 0;
            }
        }
    },
    getRefWaypointName: func { return me.fp.departure.id; },
    formatProcedure: func (procedure) {
        var sid = me.fp.departure.getSid(procedure);
        var runways = sid.runways;
        if (size(runways) == 1)
            return sprintf("%-6s %4s", procedure, runways[0]);
        else
            return procedure;
    },
    isCurrentProcedure: func (procedure) { return (me.fp.sid != nil and procedure == me.fp.sid.id); },
    procedureSelected: func { return me.fp.sid != nil; },
};

var RunwaySelectPage = {
    new: func (parentPage, refID, runways, accept) {
        var m = ProcedureSelectPage.new(parentPage);
        m.parents = [RunwaySelectPage] ~ m.parents;
        m.runways = runways;
        m.accept = accept;
        m.refID = refID;
        return m;
    },

    start: func {
        me.available = size(me.runways) > 0;
        call(ProcedureSelectPage.start, [], me);
    },

    getProcedures: func { return me.runways; },
    getProcedureTypeName: func { return 'rwy'; },
    selectProcedure: func (procedure) {
        me.accept(procedure);
    },
    getRefWaypointName: func { return me.refID; },
    formatProcedure: func (procedure) { return procedure; },
    isCurrentProcedure: func (procedure) { return 0; },
    procedureSelected: func { return nil; },
};

var SIDTransitionSelectPage = {
    new: func (parentPage) {
        var m = ProcedureSelectPage.new(parentPage);
        m.parents = [SIDTransitionSelectPage] ~ m.parents;
        m.fp = nil;
        return m;
    },

    start: func {
        me.fp = flightplan();
        me.available = me.fp.active and me.fp.sid != nil;
        call(ProcedureSelectPage.start, [], me);
    },

    getProcedures: func { return (me.fp.sid == nil) ? [] : me.fp.sid.transitions; },
    getProcedureTypeName: func { return 'trns'; },
    selectProcedure: func (procedure) {
        me.fp.sid_transition = procedure;
    },
    getRefWaypointName: func { return me.fp.sid.id; },
    formatProcedure: func (procedure) { return procedure; },
    isCurrentProcedure: func (procedure) { return (me.fp.sid_trans != nil and procedure == me.fp.sid_trans.id); },
    procedureSelected: func { return me.fp.sid_trans != nil; },
};


var ProcedureSelectPage = {
    new: func (parentPage) {
        var m = BasePage.new();
        m.parents = [ProcedureSelectPage] ~ m.parents;
        m.selectedApproach = nil;
        m.available = 0;
        m.scrollPos = 0;
        m.procedures = [];
        m.parentPage = parentPage;
        return m;
    },

    start: func {
        var self = me;
        call(BasePage.start, [], me);
        me.procedures = me.getProcedures();
        for (var i = 0; i < size(me.procedures); i += 1) {
            if (me.isCurrentProcedure(me.procedures[i])) {
                me.scrollPos = math.min(i, size(me.procedures) - 2);
                break;
            }
        }
        me.selectableFields = [];
        if (me.available) {
            me.selectableFields = [
                {
                    row: 1,
                    col: 2,
                    accept: func {
                        self.selectProcedure(self.procedures[self.scrollPos]);
                        self.deselectField();
                        self.redraw();
                    },
                    erase: func {
                        print("Erase");
                        self.selectProcedure(nil);
                        self.deselectField();
                        self.redraw();
                    },
                },
                {
                    row: 2,
                    col: 2,
                    accept: func {
                        self.selectProcedure(self.procedures[self.scrollPos + 1]);
                        self.deselectField();
                        self.redraw();
                    },
                },
            ];
        }
        me.redraw();
    },

    redraw: func {
        if (me.available) {
            putLine(0,
                sprintf("Rt 0 %4s %5s %4s",
                    me.getRefWaypointName(),
                    me.procedureSelected() ? '*actv' : 'slct',
                    me.getProcedureTypeName()));
            for (var i = 0; i < 2; i += 1) {
                var pos = me.scrollPos + i;
                var marker = ' ';
                if (i == 1) {
                    if (pos == 1)
                        marker = sc.arrowDn;
                    elsif (pos == size(me.procedures) - 1)
                        marker = sc.arrowUp;
                    else
                        marker = sc.updown;
                }
                if (pos >= size(me.procedures))  {
                    putLine(i + 1, marker);
                }
                else {
                    var procedure = me.procedures[pos] or nil;
                    if (procedure == nil)
                        putLine(i + 1, marker);
                    else
                        putLine(i + 1, sprintf('%1s%1s%s',
                            marker, 
                            me.isCurrentProcedure(procedure) ? '*' : '',
                            me.formatProcedure(procedure)));
                }
            }
        }
        else {
            putScreen([
                sprintf("Rt 0 ----  slct %4s", me.getProcedureTypeName()),
                "NO ROUTE",
                ""
            ]);
        }
    },

    handleInput: func (what, amount=1) {
        if (call(BasePage.handleInput, [what, amount], me)) {
            return 1;
        }
        elsif (what == 'data-inner') {
            me.scrollPos += amount;
            if (!me.available)
                me.scrollPos = 0;
            else
                me.scrollPos =
                    math.min(size(me.procedures) - 2,
                    math.max(0,
                    me.scrollPos));
            me.redraw();
        }
    },
};
