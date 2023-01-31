function drawShapes(circleCount, rectangleCount) {
    let c = _sb.createMainCanvas();

    function draw() {
        window.requestAnimationFrame(draw);
        c.width = window.innerWidth
        c.height = window.innerHeight
        drawCircles(circleCount)
        drawRectangles(rectangleCount)   
    }

    window.requestAnimationFrame(draw);
}