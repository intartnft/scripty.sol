function stacked3DObjects1() {
    const camera = new THREE.PerspectiveCamera(70, window.innerWidth / window.innerHeight, 0.01, 10);
    camera.position.z = 1;

    const scene = new THREE.Scene();
    let cubes = []
    for (let i = 0; i < 50; i++) {
        const geometry = new THREE.BoxGeometry(0.2, 0.2, 0.2);
        const material = new THREE.MeshPhysicalMaterial();
        const mesh = new THREE.Mesh(geometry, material);
        mesh.position.x = Math.random() - 0.5
        mesh.position.y = Math.random() - 0.5
        mesh.position.z = Math.random() - 0.5
        mesh.rs = 0.001 + Math.random() * 0.01
        scene.add(mesh);
        cubes.push(mesh)
    }

    const renderer = new THREE.WebGLRenderer({ antialias: true });
    renderer.setSize(window.innerWidth, window.innerHeight);
    renderer.setAnimationLoop(animation);
    document.body.appendChild(renderer.domElement);

    const light = new THREE.PointLight(0xff0000, 1, 10);
    light.position.set(0, 0, 0);
    scene.add(light);

    function animateCubes() {
        cubes.forEach(cube => {
            cube.rotation.x += cube.rs
            cube.rotation.y += cube.rs
            cube.rotation.z += cube.rs
        })
    }

    function animation(time) {
        animateCubes()
        renderer.render(scene, camera);
    }

    function onWindowResize() {
        camera.aspect = window.innerWidth / window.innerHeight;
        camera.updateProjectionMatrix();
        renderer.setSize(window.innerWidth, window.innerHeight);
    }

    onWindowResize()
    window.addEventListener('resize', onWindowResize, false);

    // Register script parameters to global _sb object
    _sb.scripts.stacked3DObjects1 = {
        scene,
        renderer,
        camera,
        cubes,
        animateCubes
    };
};
stacked3DObjects1();