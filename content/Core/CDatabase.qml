import QtQuick 6.2
import QtQuick.LocalStorage
import '../utils.js' as Utils

Item {
    id: root
    property var cDb
    property bool cInitialized: false

    Component.onCompleted: initializeDB()

    function initializeSQLFile(cDb, file) {
        var loadTables = Utils.openFile(file);
        cDb.transaction(function(tx) {
            var cmds = loadTables.split(' ;')

            for (var i in cmds) {
                var cmd = cmds[i]

                if (!Utils.isWhitespaceString(cmd) && !cmd.trim().startsWith('--')) {
                    tx.executeSql(cmd)
                }
            }
        })
    }

    function initializeDB() {
        cDb = LocalStorage.openDatabaseSync("AgroData", "1.0", "AgroMobile", 1000000);
        initializeSQLFile(cDb, "resources/database.sql");

        console.log('database initialized')
        cInitialized = true
    }

    function transaction(f) {
        cDb.transaction(f)
    }

    // tables ----------------------------------------------------------------------------------------------------

    function executeGetQuery(tx, table, props, filters = []) {
        var propsString = ''
        for (var p = 0; p < props.length; ++p)
        {
            var prop = props[p];
            propsString += `${table}.${prop},`
        }
        propsString = propsString.substring(0, propsString.length - 1) + " ";

        var query = `SELECT ${propsString} FROM ${table}`;

        if (filters.length > 0) {
            query += ' WHERE '
            for (var i = 0; i < filters.length - 1; ++i) {
                query += filters[i] + ' AND '
            }
            query += filters[filters.length - 1]
        }

        return tx.executeSql(query);
    }

    function getListFromTable(tx, table, props, listModel, filters = []) {
        var rs = executeGetQuery(tx, table, props, filters)

        listModel.clear();
        for (var i = 0; i < rows.length; i++) {
            var r = rows.item(i);

            var valid = true
            var arr = []
            for (var j in r) {
                if (JSON.stringify(r[j]) === 'null') {
                    valid = false
                } else {
                    arr.push(r[j])
                }
            }

            if (valid) {
                listModel.append(arr)
            }
        }
    }

    function getItemFromTable(tx, table, props, itemModel, filters = []) {
        var rs = executeGetQuery(tx, table, props, filters)

        itemModel.clear()
        if (rows.length > 0) {
            var item = rows.item(0)

            for (var i = 0; i < props.length; ++i) {
                itemModel.append(item[props[i]])
            }
        } else {
            console.log(`query from table ${table} is empty`)
        }
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
            propsString = propsString.substring(0, propsString.length - 1) + ")";
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
            propsString = propsString.substring(0, propsString.length - 1) + " ";

            tx.executeSql(`UPDATE ${table} SET ${propsString} WHERE id=${row.id}`, propValues);
        }
    }

    function removeFromTable(tx, table, rows) {
        for (const i in rows) {
            var row = rows[i];
            tx.executeSql(`DELETE FROM ${table} WHERE id = ?`, [row.id]);
        }
    }

    // filters --------------------------------------------------------------------------------------------------

    function filterEq(id, prop) {
        return `${prop} = ${id}`
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
}
