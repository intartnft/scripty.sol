function base64FromGzip(data) {
    let i = Uint8Array.from(atob(data), w => w.charCodeAt(0));
    let d = gunzipSync(i);

    var asString = arrayToBinaryString(d);
    var encodedForDataUrl = btoa(asString);

    return `data:text/javascript;base64,${encodedForDataUrl}`;
}

function arrayToBinaryString(array) {
    var str = '';
    array.map(val => {
        str += String.fromCharCode(val)
    })
    return str;
}

function injectImportMap(dataObj, callback) {
    let json = {"imports":{}};
    let map = document.createElement("script");
    map.setAttribute("type", "importmap");
    dataObj.map(importData => {
        json.imports[`${importData[0]}`] = base64FromGzip(importData[1])
    })
    map.innerText = JSON.stringify(json);
    document.body.appendChild(map);

    callback();
}