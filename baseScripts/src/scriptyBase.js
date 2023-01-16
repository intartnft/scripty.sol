let _sb = {};
_sb.events = [];
_sb.scripts = {};
_sb.addEvent = (e,c) => {
    if (!_sb.events[e]) {
        _sb.events[e] = [c];
    }else{
        _sb.events[e].push(c);
    }
}
_sb.callEvents = (e, ...args) => {
    if (_sb.events[e]) {
        _sb.events[e].forEach(c => c(...args));
    }
}
_sb.createMainCanvas = () => {
    if (_sb.mainCanvas) {
        return _sb.mainCanvas;
    }
    const c = document.createElement('canvas');
    _sb.mainCanvas = c;
    _sb.mainContext2d = c.getContext('2d');
    document.body.appendChild(c);
    return c;
}