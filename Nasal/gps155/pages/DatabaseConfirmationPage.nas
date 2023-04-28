var DatabaseConfirmationPage = {
    new: func {
        return {
            parents: [DatabaseConfirmationPage, BasePage],
        };
    },

    start: func {
        call(BasePage.start, [], me);
        putLine(0, alignCenter(deviceProps.navdb.getValue('name'), 20));
        putLine(1, sprintf('eff %-9s (%-4s)',
                    deviceProps.navdb.getValue('eff'),
                    deviceProps.navdb.getValue('airac')));
        putLine(2, sprintf('exp %-9s    ok?',
                    deviceProps.navdb.getValue('exp')));
    },

    handleInput: func (what, amount=0) {
        if (what == 'ENT') {
            loadPage(SatPage.new());
            return 1;
        }
        else {
            return 1;
        }
    },
};

