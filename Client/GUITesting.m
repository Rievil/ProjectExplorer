fig = uifigure('Position',[100 100 440 320]);
g = uigridlayout(fig);
g.RowHeight = {22,22,'1x'};
g.ColumnWidth = {'1x','2x'};

% Device drop-down
dd1 = uidropdown(g);
dd1.Items = {'Select a device'};

% Range drop-down
dd2 = uidropdown(g);
dd2.Items = {'Select a range'};
dd2.Layout.Row = 2;
dd2.Layout.Column = 1;

% List box
chanlist = uilistbox(g);
chanlist.Items = {'Channel 1','Channel 2','Channel 3'};
chanlist.Layout.Row = 3;
chanlist.Layout.Column = 1;

% Axes
ax = uiaxes(g);

ax.Layout.Row = [1 3];