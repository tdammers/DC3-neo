var MultiPage = {
    new: func (currentPageProp, modeKey, wrapLeft=1) {
        return {
            parents: [MultiPage, BasePage],
            currentPageProp: currentPageProp,
            currentSubpage: nil,
            modeKey: modeKey,
            wrapLeft: wrapLeft,
            pagePropListener: nil,
        };
    },

    start: func {
        var self = me;
        call(BasePage.start, [], me);
        me.pagePropListener = setlistener(me.currentPageProp, func (node) {
            var pageIndex = node.getValue() or 0;
            me.setSubpage(me.getSubpage(pageIndex));
        }, 1, 0);
    },

    stop: func {
        call(BasePage.stop, [], me);
        if (me.currentSubpage != nil) {
            me.currentSubpage.stop();
        }
        if (me.pagePropListener != nil) {
            removelistener(me.pagePropListener);
        }
        me.pagePropListener = nil;
    },

    setSubpage: func(subpage) {
        if (me.currentSubpage != nil) {
            me.currentSubpage.stop();
        }
        me.currentSubpage = subpage;
        if (me.currentSubpage != nil) {
            me.currentSubpage.start();
            me.currentSubpage.redraw();
        }
    },

    getSubpage: func (i) {
        return nil;
    },

    getNumSubpages: func {
        return 0; # Override as needed
    },

    update: func (dt) {
        if (me.currentSubpage != nil)
            me.currentSubpage.update(dt);
    },

    moveSubpage: func (amount=1) {
        var subpageIndex = me.currentPageProp.getValue() or 0;
        if (amount == 0) {
            return;
        }
        elsif (amount > 0) {
            me.currentPageProp.setValue(
                math.mod(subpageIndex + amount, me.getNumSubpages()));
        }
        elsif (amount < 0) {
            if (me.wrapLeft) {
                me.currentPageProp.setValue(
                    math.mod(subpageIndex + me.getNumSubpages() + amount, me.getNumSubpages()));
            }
            else {
                me.currentPageProp.setValue(
                    math.max(0, subpageIndex + amount));
            }
        }
    },

    handleInput: func (what, amount=0) {
        var self = me;
        if (me.currentSubpage != nil and me.currentSubpage.handleInput(what, amount)) {
            return 1;
        }
        elsif (call(BasePage.handleInput, [what, amount], me)) {
            return 1;
        }
        elsif (what == me.modeKey) {
            me.moveSubpage(1);
            return 1;
        }
        elsif (what == 'data-outer') {
            if (me.selectedField == -1) {
                me.moveSubpage(amount);
                return 1;
            }
            else {
                return 0;
            }
        }
        else {
            return 0;
        }
    },

};
