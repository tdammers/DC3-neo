var NavPage = {
    new: func (gotoPage=nil) {
        if (gotoPage != nil)
            deviceProps.currentPage.nav.setValue(gotoPage);
        var m = MultiPage.new(deviceProps.currentPage.nav, 'NAV', 0);
        m.parents = [NavPage] ~ m.parents;
        return m;
    },

    SUBPAGE_CDI: 0,
    SUBPAGE_POSITION: 1,
    SUBPAGE_MENU1: 2,
    SUBPAGE_MENU2: 3,

    getNumSubpages: func { return 2; },

    getSubpage: func (i) {
        if (i == NavPage.SUBPAGE_CDI) return NavPage.CDIPage.new();
        elsif (i == NavPage.SUBPAGE_POSITION) return NavPage.PositionPage.new();
        else return nil;
    },

    start: func {
        call(MultiPage.start, [], me);
        modeLightProp.setValue('NAV');
    },

    stop: func {
        call(MultiPage.stop, [], me);
        modeLightProp.setValue('');
    },

    CDIPage: {
        new: func {
            var m = BasePage.new();
            m.parents = [NavPage.CDIPage] ~ m.parents;
            m.editingWPT = nil;
            return m;
        },

        start: func {
            call(BasePage.start, [], me);
            var self = me;
            me.updateSelectableFields();
        },

        deselectField: func {
            call(BasePage.deselectField, [], me);
            me.editingWPT = nil;
            me.updateSelectableFields();
            me.redraw();
        },

        updateSelectableFields: func {
            var self = me;
            me.selectableFields = [];
            var editingWPT = me.editingWPT or '';
            for (var i = 0; i <= size(editingWPT) and i < 5; i += 1) {
                (func (i) {
                    append(me.selectableFields,
                        { row: 2, col: 6 + i,
                            changeValue: func (amount) {
                                self.editingWPT = scrollChar(editingWPT, i, amount);
                                self.updateSelectableFields();
                                self.redraw();
                            },
                            accept: func {
                                printf("Accept WP: %s", self.editingWPT);
                                searchAndConfirmWaypoint(self.editingWPT, self, func (waypoint) {
                                    setDTO(waypoint);
                                    self.editingWPT = nil;
                                    self.updateSelectableFields();
                                    self.redraw();
                                });
                                return 1;
                            },
                            erase: func {
                                var mode = deviceProps.mode.getValue();
                                if (mode == 'dto' and flightplan() != nil and flightplan().getPlanSize() > 1) {
                                    deviceProps.command.setValue('leg');
                                }
                                else {
                                    deviceProps.command.setValue('obs');
                                }
                            }
                        });
                })(i);
            }
            append(me.selectableFields,
                { row: 0, col: 12,
                    changeValue: func (amount) {
                        cycleProp(deviceProps.settings.fields.cdi.gs,
                            ['gs', 'str'],
                            amount);
                        self.redraw();
                    }
                },
                { row: 1, col: 12,
                    changeValue: func (amount) {
                        cycleProp(deviceProps.settings.fields.cdi.trk,
                            ['trk', 'brg', 'dtk'], # TODO: cts, trn
                            amount);
                        self.redraw();
                    }
                },
                { row: 2, col: 12,
                    changeValue: func (amount) {
                        cycleProp(deviceProps.settings.fields.cdi.ete,
                            ['eta', 'ete', 'trk'], # TODO: vn
                            amount);
                        self.redraw();
                    }
                });
        },

        update: func (dt) {
            visibleWaypoint = referenceWaypoint;
            me.redraw();
        },

        redraw: func {
            var mode = getprop('/instrumentation/gps/mode') or 'obs';
            var tgtID = getprop('/instrumentation/gps/wp/wp[1]/ID') or '';
            var fromID = getprop('/instrumentation/gps/wp/wp[0]/ID') or '';
            var fromFlag = getprop('/instrumentation/gps/from-flag') or 0;

            var tgtBRG = getprop('/instrumentation/gps/wp/wp[1]/bearing-mag-deg');
            var tgtDST = getprop('/instrumentation/gps/wp/wp[1]/distance-nm');
            var legTRK = getprop('/instrumentation/gps/wp/leg-mag-course-deg');
            var ete = getprop('/instrumentation/gps/wp/wp[1]/TTW') or '';
            var eta = (getprop('/instrumentation/gps/wp/wp[1]/TTW-sec') or 0) +
                      (getprop('/sim/time/utc/day-seconds') or 0);
            var gs = getprop('/instrumentation/gps/indicated-ground-speed-kt') or 0;
            var cte = getprop('/instrumentation/gps/wp/wp[1]/course-error-nm') or 0;
            var trk = getprop('/instrumentation/gps/indicated-track-magnetic-deg') or 0;

            var cdiFormatted = 'No actv wpt';
            var gsFormatted = '___ ';
            var distanceFormatted = "___" ~ smallStr('.__') ~ sc.nm;
            var trackFormatted = "___";
            var legInfo = "_____" ~ sc.arrowR ~ "_____";
            var eteFormatted = "__:__";

            if (me.editingWPT != nil) {
                tgtID = substr(me.editingWPT ~ "_____", 0, 5);
                legInfo = "_____" ~ sc.arrowR ~ tgtID;
            }

            if (tgtID != '' or mode == 'obs') {
                var needleDeflection = cte * 2;
                    needlePosRaw = math.round(needleDeflection);
                    needlePosFine = needleDeflection - needlePosRaw;
                    needlePos = math.min(5, math.max(-5, needlePosRaw)) + 5;
                    needlePosOffset = math.min(2, math.max(-2, math.round(needlePosFine * 6))) + 2;

                cdiFormatted = '';
                var i = 0;
                for (i = 0; i < needlePos; i += 1)
                    if (i == 5)
                        cdiFormatted ~= '+';
                    else
                        cdiFormatted ~= sc.dot;
                var tbl = [];

                if (fromFlag)
                    tbl = [
                        sc.cdiFromL2, sc.cdiFromL1,
                        sc.cdiFromC,
                        sc.cdiFromR1, sc.cdiFromR2,
                    ];
                else
                    tbl = [
                        sc.cdiToL2, sc.cdiToL1,
                        sc.cdiToC,
                        sc.cdiToR1, sc.cdiToR2,
                    ];

                cdiFormatted ~= tbl[needlePosOffset];
                for (i = needlePos + 1; i < 11; i += 1)
                    if (i == 5)
                        cdiFormatted ~= '+';
                    else
                        cdiFormatted ~= sc.dot;
                if (mode != 'obs')
                    distanceFormatted = formatDistance(tgtDST);
                if (mode == 'dto') {
                    legInfo = sprintf('go to:%-5s', navid5(tgtID));
                }
                elsif (mode == 'leg') {
                    legInfo = sprintf('%-5s' ~ sc.arrowR ~ '%-5s',
                                    navid5(fromID), navid5(tgtID));
                }
            }

            var formatCDIField = func (type) {
                var mode = deviceProps.mode.getValue();
                if (type == 'gs') {
                    return 'gs ' ~ formatSpeed(gs, 'kt');
                }
                elsif (type == 'str') {
                    var deviation = formatDistanceShort(math.abs(cte));
                    if (cte < -0.01)
                        return 'strL' ~ deviation;
                    elsif (cte > 0.01)
                        return 'strR' ~ deviation;
                    else
                        return 'strC' ~ deviation;
                }
                elsif (type == 'trk') {
                    return 'trk ' ~ formatHeading(trk);
                }
                elsif (type == 'brg') {
                    if (mode == 'obs')
                        return 'brg ____';
                    else
                        return 'brg ' ~ formatHeading(tgtBRG);
                }
                elsif (type == 'dtk') {
                    if (mode == 'obs')
                        return 'dtk ____';
                    else
                        return 'dtk ' ~ formatHeading(legTRK);
                }
                elsif (type == 'ete') {
                    if (substr(ete or '__:__', 0, 3) == '00:')
                        return 'ete' ~ substr(ete or '__:__', 3, 5);
                    elsif (substr(ete or '__:__', 0, 1) == '0:')
                        return 'ete' ~ substr(ete or '__:__', 1, 4);
                    else
                        return 'ete' ~ substr(ete or '__:__', 0, 5);
                }
                elsif (type == 'eta') {
                    var minutesRaw = math.round(eta / 60) + 1440;
                    var minutes = math.mod(minutesRaw, 60);
                    var hours = math.mod(math.floor(minutesRaw / 60), 24);
                    return sprintf('eta%02i:%02i', hours, minutes);
                }
                else {
                    # TODO: dis, cts, trn, vn
                    return sprintf('%-3s ____', type);
                }
            };

            var formattedFields = {};
            foreach (var f; ['gs', 'trk', 'ete']) {
                var mode = deviceProps.settings.fields.cdi[f].getValue();
                formattedFields[f] = formatCDIField(mode);
            }

            putLine(0, cdiFormatted ~ " " ~ formattedFields.gs);
            putLine(1, "dis " ~ distanceFormatted ~ '   ' ~ formattedFields.trk);
            putLine(2, legInfo ~ " " ~ formattedFields.ete);
        },
    },

    PositionPage: {
        new: func {
            return {
                parents: [NavPage.PositionPage, BasePage],
            };
        },

        setSelectableFields: func {
            var self = me;
            me.selectableFields = [
                { row: 2, col:  1,
                    changeValue: func (amount) {
                        changeRefMode(amount);
                        visibleWaypoint = referenceWaypoint;
                        self.setSelectableFields();
                        self.redraw();
                    }
                },
            ];
            if (deviceProps.referenceMode.getValue() == 'wpt') {
                for (var i = 0; i < 5; i += 1) {
                    (func (i) {
                        append(me.selectableFields, {
                            row: 2,
                            col: 5 + i,
                            changeValue: func (amount) {
                                var str = deviceProps.referenceSearchID.getValue();
                                deviceProps.referenceSearchID.setValue(scrollChar(str, i, amount));
                                self.redraw();
                            },
                            accept: func {
                                var searchID = deviceProps.referenceSearchID.getValue();

                                searchAndConfirmWaypoint(searchID, self, func (waypoint) {
                                    referenceWaypoint = waypoint;
                                    visibleWaypoint = referenceWaypoint;
                                    deviceProps.referenceSearchID.setValue(referenceWaypoint.id);
                                    updateReference();
                                });
                                return 1;
                            }
                        });
                    })(i);
                }
            }
        },

        start: func {
            call(BasePage.start, [], me);
            me.setSelectableFields();
        },

        redraw: func {
            var lat = getprop('/instrumentation/gps/indicated-latitude-deg') or 0;
            var lon = getprop('/instrumentation/gps/indicated-longitude-deg') or 0;
            var searchID = deviceProps.referenceSearchID.getValue() or '';
            var refID = deviceProps.referenceID.getValue() or '';
            var refBRG = deviceProps.referenceBRG.getValue() or 0;
            var refDST = deviceProps.referenceDist.getValue() or -1;
            var refMode = deviceProps.referenceMode.getValue() or '';
            var alt = getprop('/instrumentation/altimeter/indicated-altitude-ft') or 0;

            var formattedLat = '___.__' ~ sc.deg ~ '__' ~ smallStr('.___');
            var formattedLon = '____.__' ~ sc.deg ~ '__' ~ smallStr('.___');
            var formattedDistance = '__' ~ smallStr('.__') ~ '_';
            var formattedBearing = '___';
            var line2 = '____ ____ ___' ~ sc.deg ~ formattedDistance;
            var visibleID = '_____';

            if (refMode == 'wpt' and me.selectedField > 0 and me.selectedField < 5)
                visibleID = searchID;
            else
                visibleID = refID;

            if (lat and lon) {
                formattedLat = formatLat(lat);
                formattedLon = formatLon(lon);
            }
            if (refDST >= 0)
                formattedDistance = formatDistanceShort(refDST);
            if (refBRG >= 0)
                formattedBearing = sprintf('%03.0f', refBRG);
            line2 = sc.fr ~ refMode ~ ' ' ~ sprintf('%-5s', visibleID) ~ ' ' ~
                        formattedBearing ~ sc.deg ~
                        formattedDistance;

            putLine(0, sprintf('alt %6s', formatAltitude(alt)));
            putLine(1, formattedLat ~ ' ' ~ formattedLon);
            putLine(2, line2);
        },

        update: func (dt) {
            me.setSelectableFields();
            me.redraw();
        },
    },
};
