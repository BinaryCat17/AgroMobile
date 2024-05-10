.pragma library

function openFile(fileUrl) {
    var request = new XMLHttpRequest();
    request.open("GET", fileUrl, false);
    request.send(null);
    return request.responseText;
};

function saveFile(fileUrl, text) {
    var request = new XMLHttpRequest();
    request.open("PUT", fileUrl, false);
    request.send(text);
    return request.status;
};

function check(c, val, other = 'undefined') {
     return c.id !== 'undefined' ? val : other
}

function isWhitespaceString(text) {
    return !text.replace(/\s/g, '').length
};

function randomRange(min, max) {
    return Math.random() * (max - min) + min;
};

function clearAnchors(item) {
    item.anchors.top = undefined
    item.anchors.bottom = undefined
    item.anchors.right = undefined
    item.anchors.left = undefined
}

function geopolyRegular(longitude, latitude, R, N) {
    return `geopoly_regular(
        ${longitude},
        ${latitude},
        abs(${R}/(40075017*cos(${latitude})/360)),
        ${N}
    )`
};

function splitMultiple(str, separators) {
    for (var i in separators) {
        str = str.replace(separators[i], separators[i] + "$");
    }
    return str.split('$');
};

function roundNumber(number, digits)
{
    var multiple = Math.pow(10, digits);
    return Math.round(number * multiple) / multiple;
};

function formatTime(sec)
{
    var value = sec
    var seconds = value % 60
    value /= 60
    value = (value > 1) ? Math.round(value) : 0
    var minutes = value % 60
    value /= 60
    value = (value > 1) ? Math.round(value) : 0
    var hours = value
    if (hours > 0) value = hours + "h:"+ minutes + "m"
    else value = minutes + "min"
    return value
};

function formatDistance(meters)
{
    var dist = Math.round(meters)
    if (dist > 1000 ){
        if (dist > 100000){
            dist = Math.round(dist / 1000)
        }
        else{
            dist = Math.round(dist / 100)
            dist = dist / 10
        }
        dist = dist + " km"
    }
    else{
        dist = dist + " m"
    }
    return dist
};

function generateUUID(){
    var d = new Date().getTime();
    var uuid = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
        var r = (d + Math.random()*16)%16 | 0;
        d = Math.floor(d/16);
        return (c === 'x' ? r : (r&0x3|0x8)).toString(16);
    });
    return uuid;
};

function escapeRegExp(string) {
  return string.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'); // $& means the whole matched string
}

function replaceAll(str, find, replace) {
  return str.replace(new RegExp(escapeRegExp(find), 'g'), replace);
}

function dateTimeToStr(time) {
    var locale = Qt.locale()
    return time.toLocaleString(locale, "yyyy-MM-dd hh:mm:ss")
}

function strToDateTime(time) {
    var locale = Qt.locale()
    return Date.fromLocaleString(locale, time, "yyyy-MM-dd hh:mm:ss")
}
