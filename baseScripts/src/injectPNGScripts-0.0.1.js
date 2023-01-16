"use strict";
(() => {
    let nodes = document.querySelectorAll(
        'script[type="text/javascript+png"][src]'
    );
    const total = nodes.length;
    let loaded_script_count = 0;

    function loadImage(base64URI) {
        let image = new Image();
        image.src = base64URI;
        image.onload = () => {
            const canvas = document.createElement("canvas");
            const gl = canvas.getContext("webgl");

            let texture = gl.createTexture();
            gl.bindTexture(gl.TEXTURE_2D, texture);

            let width = image.width;
            let height = image.height;

            gl.bindTexture(gl.TEXTURE_2D, texture);
            gl.texImage2D(
                gl.TEXTURE_2D,
                0,
                gl.RGBA,
                gl.RGBA,
                gl.UNSIGNED_BYTE,
                image
            );
            gl.generateMipmap(gl.TEXTURE_2D);

            let fb = gl.createFramebuffer();
            gl.bindFramebuffer(gl.FRAMEBUFFER, fb);
            gl.framebufferTexture2D(
                gl.FRAMEBUFFER,
                gl.COLOR_ATTACHMENT0,
                gl.TEXTURE_2D,
                texture,
                0
            );

            if (
                gl.checkFramebufferStatus(gl.FRAMEBUFFER) ==
                gl.FRAMEBUFFER_COMPLETE
            ) {
                let pixels = new Uint8Array(width * height * 4);
                gl.readPixels(
                    0,
                    0,
                    width,
                    height,
                    gl.RGBA,
                    gl.UNSIGNED_BYTE,
                    pixels
                );

                let decoder = new TextDecoder("utf-8");
                let b64encoded = btoa(decoder.decode(pixels));

                let script = document.createElement("script");
                script.type = "text/javascript";
                script.async = true;
                script.onload = () => {
                    loaded_script_count++;
                    if (loaded_script_count == total) {
                        _sb.callEvents("base64URI_loaded");
                    }
                };
                script.src = "data:text/javascript;base64," + b64encoded.trim();
                document.body.appendChild(script);
            }
            canvas.remove();
        };
    }

    for (let node of nodes)
        try {
            let [source] = node.src.match(/^data:(.*?)(?:;(base64))?,(.*)$/);
            loadImage(source);
        } catch (error) {
            console.error("Could not INFLATE script", node, error);
        }
})();
