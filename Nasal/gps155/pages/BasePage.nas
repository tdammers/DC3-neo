var BasePage = {
    new: func {
        return { parents: [BasePage] };
    },

    start: func {
        me.selectableFields = [];
        me.selectedField = -1;
    },
    stop: func {
        unsetCursor();
    },
    update: func (dt) {},

    deselectField: func {
        me.selectedField = -1;
        unsetCursor();
    },

    handleInput: func (what, amount=0) {
        if (what == 'CRSR') {
            if (me.selectedField >= 0) {
                var field = me.selectableFields[me.selectedField];
                if (contains(field, 'stop')) {
                    field.stop();
                }
                me.deselectField();
                return 1;
            }
            elsif (size(me.selectableFields) > 0) {
                me.selectedField = 0;
                var field = me.selectableFields[me.selectedField];
                setCursor(field.row, field.col);
                if (contains(field, 'start')) {
                    field.start();
                }
                return 1;
            }
        }
        elsif (what == 'data-inner') {
            if (me.selectedField >= 0) {
                var field = me.selectableFields[me.selectedField];
                if (contains(field, 'changeValue')) {
                    field.changeValue(amount);
                    return 1;
                }
            }
        }
        elsif (what == 'CLR') {
            if (me.selectedField >= 0) {
                var field = me.selectableFields[me.selectedField];
                if (contains(field, 'erase')) {
                    field.erase();
                    return 1;
                }
            }
        }
        elsif (what == 'ENT') {
            if (me.selectedField >= 0) {
                var field = me.selectableFields[me.selectedField];
                if (contains(field, 'accept')) {
                    field.accept();
                    return 1;
                }
            }
        }
        elsif (what == 'data-outer') {
            if (me.selectedField >= 0 and size(me.selectableFields) > 0) {
                var field = me.selectableFields[me.selectedField];
                if (contains(field, 'stop')) {
                    field.stop();
                }
                me.selectedField += amount;
                while (me.selectedField < 0) {
                    me.selectedField += size(me.selectableFields);
                }
                while (me.selectedField >= size(me.selectableFields)) {
                    me.selectedField -= size(me.selectableFields);
                }
                var field = me.selectableFields[me.selectedField];
                if (contains(field, 'stop')) {
                    field.stop();
                }
                setCursor(field.row, field.col);
                return 1;
            }
        }
        else {
            return 0;
        }
    },
};
