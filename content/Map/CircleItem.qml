// Copyright (C) 2017 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause
import QtQuick
import QtLocation

MapCircle {
    property var position
    color: "#da5546"
    border.color: "#330a0a"
    border.width: 2
    smooth: true
    opacity: 0.75
    referenceSurface: map.referenceSurface

    property string geojsonType: "Point"

    function addGeometry(newCoordinate, changeLast){
        center = newCoordinate
        return true
    }

    function finishAddGeometry(){
    }
}
