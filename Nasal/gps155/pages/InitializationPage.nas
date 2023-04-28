var InitializationPage = {
    new: func {
        return {
            parents: [InitializationPage, BasePage],
        };
    },

    start: func {
        call(BasePage.start, [], me);
        me.redraw();
    },

    redraw: func {
        putLine(0, sprintf(' GPS 155 Ver %s', version));
        putLine(1, sc.copy ~ "1994-95 GARMIN Corp");
        putLine(2, 'Performing self test');
    },

    update: func (dt) {
        me.redraw();
        if (deviceProps.initializationTimer.getValue() <= 0.01) {
            loadPage(DatabaseConfirmationPage.new());
        }
    },

    handleInput: func (what, amount=0) {
        return 1;
    },
};


