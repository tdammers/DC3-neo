var SettingsPage = {
    new: func {
        var m = MultiPage.new(deviceProps.currentPage.set, 'SET');
        m.parents = [SettingsPage] ~ m.parents;
        return m;
    },

    getNumSubpages: func { return 2; },
    getSubpage: func (i) {
        if (i == 0)
            return me.SatSubpage.new();
        else
            return me.NavUnitsSubpage.new();
    },

    start: func {
        call(MultiPage.start, [], me);
        modeLightProp.setValue('SET');
    },

    stop: func {
        call(MultiPage.stop, [], me);
        modeLightProp.setValue('');
    },

    SatSubpage: {
        new: func { return { parents: [SettingsPage.SatSubpage, BasePage], } },
        redraw: func {
            var status = deviceProps.receiver.status.getValue() or 0;
            putScreen(formatSatStatus(status, satellites));
        },
        update: func (dt) {
            me.redraw();
        },
    },

    NavUnitsSubpage: {
        new: func { return { parents: [SettingsPage.NavUnitsSubpage, BasePage], } },

        start: func {
            call(BasePage.start, [], me);
            var self = me;
            me.selectableFields = [
                { row: 0, col: 5,
                  changeValue: func(amount) {
                    cycleProp(deviceProps.settings.units.position,
                        ['dm', 'dms'],
                        amount);
                    self.redraw();
                  }
                },
                { row: 0, col: 13,
                  changeValue: func(amount) {
                    cycleProp(deviceProps.settings.units.altitude,
                        ['ft', 'm'],
                        amount);
                    self.redraw();
                  }
                },
                { row: 0, col: 15,
                  changeValue: func(amount) {
                    cycleProp(deviceProps.settings.units.vspeed,
                        ['fpm', 'mpm', 'mps'],
                        amount);
                    self.redraw();
                  }
                },
                { row: 1, col: 5,
                  changeValue: func(amount) {
                    cycleProp(deviceProps.settings.units.distance,
                        ['nm', 'km', 'mi'],
                        amount);
                    self.redraw();
                  }
                },
                { row: 1, col: 7,
                  changeValue: func(amount) {
                    cycleProp(deviceProps.settings.units.speed,
                        ['kt', 'kmh', 'mph'],
                        amount);
                    self.redraw();
                  }
                },
                { row: 1, col: 14,
                  changeValue: func(amount) {
                    cycleProp(deviceProps.settings.units.fuel,
                        ['gal', 'lt', 'lbs', 'kg', 'igal'],
                        amount);
                    self.redraw();
                  }
                },
                { row: 2, col: 5,
                  changeValue: func(amount) {
                    cycleProp(deviceProps.settings.units.pressure,
                        ['inhg', 'mbar'],
                        amount);
                    self.redraw();
                  }
                },
                { row: 2, col: 14,
                  changeValue: func(amount) {
                    cycleProp(deviceProps.settings.units.temperature,
                        ['degC', 'degF'],
                        amount);
                    self.redraw();
                  }
                },
            ];
        },

        redraw: func {
            putLine(0,
                sprintf('posn %-3s alt %1s %3s',
                    unitSymbol(deviceProps.settings.units.position.getValue()),
                    unitSymbol(deviceProps.settings.units.altitude.getValue()),
                    unitSymbol(deviceProps.settings.units.vspeed.getValue())));
            putLine(1,
                sprintf('nav  %1s %1s fuel %1s',
                    unitSymbol(deviceProps.settings.units.distance.getValue()),
                    unitSymbol(deviceProps.settings.units.speed.getValue()),
                    unitSymbol(deviceProps.settings.units.fuel.getValue())));
            putLine(2,
                sprintf('pres %1s   temp %1s',
                    unitSymbol(deviceProps.settings.units.pressure.getValue()),
                    unitSymbol(deviceProps.settings.units.temperature.getValue())));
        },
    },
};

