import QtQuick 6.2
import QtQuick.LocalStorage
import '../utils.js' as Utils

Item {
    id: database;
    property var db;

    Component.onCompleted: initializeDB()

    function initializeSQLFile(db, file) {
        var loadTables = Utils.openFile(file);
        db.transaction(function(tx) {
            var cmds = loadTables.split(' ;')

            for (var i in cmds) {
                var cmd = cmds[i];

                if (!Utils.isWhitespaceString(cmd)) {
                    tx.executeSql(cmd);
                }
            }
        })
    }

    function initializeDB() {
        db = LocalStorage.openDatabaseSync("QDeclarativeExampleDB", "1.0", "The Example QML SQL!", 1000000);
        initializeSQLFile(db, "Database/initialize.sql");

        console.log('database initialized')
    }

    function transaction(f) {
        db.transaction(f)
    }

    // geo ------------------------------------------------------------------------------------------------------

    function polyShape(tx, polyId) {
        var rs = tx.executeSql(`SELECT tg._shape FROM tg WHERE tg.t_id = ${polyId}`)
        if (rs.rows.length > 0) {
            return rs.rows.item(0)
        } else
        {
            return undefined;
        }
    }

    function filterNearestPoints(point) {
        return `geopoly_overlap(
                    tg._shape,
                    geopoly_bbox(
                        ${Utils.geopolyRegular(point.longitude, point.latitude, point.R, point.N)}
                    ))`
    }

    function filterPoligonPoints(poly) {
        return `geopoly_overlap(
               tg._shape,
               ${polyShape}
        )`
    }

    function savePointsToList(rows, listModel) {
        for (var i = 0; i < rows.length; i++) {
            var r = rows.item(i);
            listModel.append({
                id: r.id,
                longitude: r.longitude,
                latitude: r.latitude,
                desc: r.desc
            })
        }
    }

    function findPoints(tx, listModel, filters = []) {
        var query = `SELECT points.id, points.longitude, points.latitude, points.desc
                     FROM points JOIN tg ON points.id = tg.t_id `

        if (filters.length > 0) {
            query += 'WHERE '
            for (var i = 0; i < filters.length - 1; ++i) {
                query += filters[i] + ' AND '
            }
            query += filters[filters.length - 1]
        }

        var rs = tx.executeSql(query);
        savePointsToList(rs.rows, listModel);
    }

    function insertPoints(tx, points) {
        for (const i in points) {
            var row = points[i];
            tx.executeSql(`INSERT INTO points (id, longitude, latitude, desc)
                          VALUES (?, ?, ?, ?)`, [row.id, row.longitude, row.latitude, row.desc]);
        }
    }

    function removePoints(tx, points) {
        for (const i in points) {
            var row = points[i];
            tx.executeSql(`DELETE FROM points WHERE id = ?`, [row.id]);
            tx.executeSql(`DELETE FROM tg WHERE t_id = ?`, [row.id]);
        }
    }

    function savePolysToList(rows, listModel) {
        for (var i = 0; i < rows.length; i++) {
            var r = rows.item(i);
            var a = JSON.parse(r.shape)
            listModel.append({poly: {
                id: r.id,
                shape: a,
                desc: r.desc
           }})
        }
    }

    function findPolys(tx, listModel, filters = []) {
        var query = `SELECT polys.id, tg._shape, polys.shape, polys.desc
                     FROM polys JOIN tg ON polys.id = tg.t_id `

        var rs = tx.executeSql(query);
        savePolysToList(rs.rows, listModel);
    }

    function insertPolys(tx, poly) {
        for (const i in poly) {
            var row = poly[i];
            var shapeLoop = row.shape
            shapeLoop.push(row.shape[0])
            var shape = JSON.stringify(shapeLoop)
            tx.executeSql(`INSERT INTO polys (id, desc, shape)
                              VALUES (?, ?, ?)`, [row.id, row.desc, shape]);
        }
    }

    function removePolys(tx, polys) {
        for (const i in polys) {
            var row = polys[i];
            tx.executeSql(`DELETE FROM polys WHERE id = ?`, [row.id]);
            tx.executeSql(`DELETE FROM tg WHERE t_id = ?`, [row.id]);
        }
    }

    // documents ----------------------------------------------------------------------------------------------------

    function saveTableToList(rows, listModel) {
        listModel.clear();

        for (var i = 0; i < rows.length; i++) {
            var r = rows.item(i);
            listModel.append(r)
        }
    }

    function getFromTable(tx, table, props, listModel) {
        var propsString = ''
        for (var p = 0; p < props.length; ++p)
        {
            var prop = props[p];
            propsString += `${table}.${prop},`
        }
        propsString[propsString.length-1] = ' '

        var query = `SELECT ${propsString} FROM ${table}`;
        var rs = tx.executeSql(query);
        saveTableToList(rs.rows, listModel);
    }

    function insertInTable(tx, table, props, rows) {
        for (const i in rows) {
            var row = rows[i];

            var propsString = '('
            var propsValuesString = '('
            var propValues = []
            for (var p = 0; p < props.length; ++p)
            {
                var prop = props[p];
                propsString += (prop + ',')
                propsValuesString += ('?,')
                propValues.push(row[prop])
            }
            propsString[propsString.length-1] = ')'
            propsValuesString[propsValuesString.length-1] = ')'

            tx.executeSql(`INSERT INTO ${table} ${propsString}
                          VALUES ${propsValuesString}`, propValues);
        }
    }

    function updateTable(tx, table, props, rows) {
        for (const i in rows) {
            var row = rows[i];

            var propsString = ''
            var propValues = []
            for (var p = 0; p < props.length; ++p)
            {
                var prop = props[p];
                propValues.push(row[prop])
                propsString += `${prop} = (?),`
            }
            propsString[propsString.length-1] = ' '

            tx.executeSql(`UPDATE ${table} SET ${propsString} WHERE id=${row.id}`, propValues);
        }
    }

    function removeFromTable(tx, table, rows) {
        for (const i in rows) {
            var row = rows[i];
            tx.executeSql(`DELETE FROM ${table} WHERE id = ?`, [row.id]);
        }
    }
}
