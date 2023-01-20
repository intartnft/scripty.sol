
function drawCircles(count) {
    let c = _sb.createMainCanvas();
    let ctx = _sb.mainContext2d;

    for (let i=0; i<count; i++) {
        let px = Math.random() * c.width;
        let py = Math.random() * c.height;
        let r = 1 + Math.random() * 50;
        ctx.beginPath();
        ctx.arc(px, py, r, 0, 2 * Math.PI, false);
        ctx.lineWidth = Math.random() * 5 + 1;
        ctx.stroke();
    }
}
