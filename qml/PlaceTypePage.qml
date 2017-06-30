/* -*- coding: utf-8-unix -*-
 *
 * Copyright (C) 2014 Osmo Salomaa
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.0
import Sailfish.Silica 1.0
import "."

Dialog {
    id: dialog
    allowedOrientations: app.defaultAllowedOrientations
    canAccept: dialog.query.length > 0

    property var history: []
    property string query: ""

    SilicaListView {
        id: listView
        anchors.fill: parent
        // Prevent list items from stealing focus.
        currentIndex: -1

        delegate: ListItem {
            id: listItem
            contentHeight: visible ? Theme.itemSizeSmall : 0
            menu: contextMenu
            visible: model.visible

            ListItemLabel {
                anchors.leftMargin: listView.searchField.textLeftMargin
                color: listItem.highlighted ? Theme.highlightColor : Theme.primaryColor
                height: Theme.itemSizeSmall
                text: model.text
            }

            ContextMenu {
                id: contextMenu
                MenuItem {
                    text: qsTranslate("", "Remove")
                    onClicked: {
                        py.call_sync("poor.app.history.remove_place_type", [model.type]);
                        dialog.history = py.evaluate("poor.app.history.place_types");
                        listView.model.remove(index);
                    }
                }
            }

            ListView.onRemove: animateRemoval(listItem);

            onClicked: {
                dialog.query = model.type;
                dialog.accept();
            }

        }

        header: Column {
            height: dialogHeader.height + searchField.height
            width: parent.width
            DialogHeader { id: dialogHeader }
            SearchField {
                id: searchField
                placeholderText: qsTranslate("", "Type of venue")
                width: parent.width
                EnterKey.enabled: text.length > 0
                EnterKey.onClicked: dialog.accept();
                onTextChanged: {
                    dialog.query = searchField.text;
                    dialog.filterHistory();
                }
            }
            Component.onCompleted: listView.searchField = searchField;
        }

        model: ListModel {}

        property var searchField: undefined

        VerticalScrollDecorator {}

    }

    onStatusChanged: {
        if (dialog.status === PageStatus.Activating) {
            dialog.loadHistory();
            dialog.filterHistory();
        }
    }

    function filterHistory() {
        // Filter search history for current search field text.
        var query = listView.searchField.text.toLowerCase();
        var found = [], n = 0;
        for (var i = 0; i < dialog.history.length; i++) {
            var historyItem = dialog.history[i].toLowerCase();
            if (query && historyItem.indexOf(query) === 0) {
                found.splice(n++, 0, dialog.history[i]);
                if (found.length >= listView.count) break;
            } else if (query.length === 0 || historyItem.indexOf(query) > 0) {
                found.push(dialog.history[i]);
                if (found.length >= listView.count) break;
            }
        }
        for (var i = 0; i < found.length; i++) {
            var text = Theme.highlightText(found[i], query, Theme.highlightColor);
            listView.model.setProperty(i, "type", found[i]);
            listView.model.setProperty(i, "text", text);
            listView.model.setProperty(i, "visible", true);
        }
        for (var i = found.length; i < listView.count; i++)
            listView.model.setProperty(i, "visible", false);
    }

    function loadHistory() {
        // Load search history and preallocate list items.
        dialog.history = py.evaluate("poor.app.history.place_types");
        while (listView.model.count < 50)
            listView.model.append({"type": "", "text": "", "visible": false});
    }

}
