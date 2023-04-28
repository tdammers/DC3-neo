var ConfirmPage = {
    new: func (message, accept, reject) {
        return {
            parents: [ConfirmPage, BasePage],
            message: message,
            accept: accept,
            reject: reject,
        };
    },

    start: func {
        call(BasePage.start, [], me);
        me.redraw();
    },

    redraw: func {
        var lines = [me.message, '', '                ok?'];
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

