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

Column {

    ComboBox {
        id: closestComboBox
        label: qsTranslate("", "Prefer")
        menu: ContextMenu {
            MenuItem { text: qsTranslate("", "Closest") }
            MenuItem { text: qsTranslate("", "Best") }
        }
        Component.onCompleted: {
            var option = "guides.foursquare.sort_by_distance";
            closestComboBox.currentIndex = app.conf.get(option) ? 0 : 1;
        }
        onCurrentIndexChanged: {
            var option = "guides.foursquare.sort_by_distance";
            app.conf.set(option, closestComboBox.currentIndex === 0);
        }
    }

}
