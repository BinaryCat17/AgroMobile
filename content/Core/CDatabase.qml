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

    function executeGetQuery(tx, table, props, joins = [], filters = []) {
        var propsString = ''
        for (var p = 0; p < props.length; ++p)
        {
            propsString += `${table}.${props[p]},`
        }

        var joinsString = ''
        if (joins.length > 0) {
            for (var j = 0; j < joins.length; ++j) {
                if (!joins[j].alreadyExist) {
                    joinsString += ` INNER JOIN ${joins[j].table} ON ${table}.${joins[j].column} = ${joins[j].table}.id`
                }

                propsString += `${joins[j].table}.${joins[j].ref_column} AS ${joins[j].name},`
            }
        }

        propsString = propsString.substring(0, propsString.length - 1) + " ";
        var query = `SELECT ${propsString} FROM ${table} ${joinsString}`;

        if (filters.length > 0) {
            query += ' WHERE '
            for (var i = 0; i < filters.length - 1; ++i) {
                query += filters[i] + ' AND '
            }
            query += filters[filters.length - 1]
        }

        console.log(query)
        return tx.executeSql(query);
    }

    function getListFromTable(tx, table, props, listModel, joins = [], filters = []) {
        var rs = executeGetQuery(tx, table, props, joins, filters)

        listModel.length = 0
        for (var i = 0; i < rs.rows.length; i++) {
            var r = rs.rows.item(i);
            var valid = true
            var arr = []
            for (var j in r) {
                if (JSON.stringify(r[j]) === 'null') {
                    //valid = false
                } else {
                    arr.push(r[j])
                }
            }

            if (valid) {
                listModel.push(arr)
            }
        }
    }

    function getItemFromTable(tx, table, props, itemModel, filters = []) {
        var rs = executeGetQuery(tx, table, props, filters)

        itemModel.length = 0
        if (rs.rows.length > 0) {
            var item = rs.rows.item(0)

            for (var i = 0; i < props.length; ++i) {
                itemModel.push(item[props[i]])
            }
        } else {
            //console.log(`query from table ${table} is empty`)
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
            propsValuesString = propsValuesString.substring(0, propsValuesString.length-1) + ')'

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

            tx.executeSql(`UPDATE ${table} SET ${propsString} WHERE id=\"${row.id}\"`, propValues);
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
        return `\"${prop}\" = ${id}`
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
