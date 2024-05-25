import QtQuick 2.15
import QtLocation

MapPolygon {
    color: "#da5546"
    border.color: "#330a0a"
    border.width: 2
    smooth: true
    opacity: 0.75
    referenceSurface: map.referenceSurface

    property string cDesc: 'undefined'
    property var cInputValue: path

    function addGeometry(newCoordinate, changeLast){
        if (changeLast && path.length > 0)
            removeCoordinate(path[path.length-1])
        addCoordinate(newCoordinate)
        return false
    }

    function finishAddGeometry(){
        if (path.length > 0)
            removeCoordinate(path[path.length-1])
    }
}