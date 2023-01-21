
function drawRectangles(count) {
    let c = _sb.createMainCanvas();
    let ctx = _sb.mainContext2d;

    for (let i=0; i<count; i++) {
        let px = Math.random() * c.width;
        let py = Math.random() * c.height;
        let s = 1 + Math.random() * 100;
        ctx.beginPath();
        ctx.rect(px, py, s, s);
        ctx.lineWidth = Math.random() * 5 + 1;
        ctx.stroke();
    }
}
