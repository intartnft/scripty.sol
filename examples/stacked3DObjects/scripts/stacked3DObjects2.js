function stacked3DObjects2(params) {
    const camera = params.camera
    camera.position.z = 1;

    const scene = params.scene;
    const group = new THREE.Group();
    let spheres = []
    for (let i = 0; i < 50; i++) {
        const geometry = new THREE.IcosahedronGeometry(0.2, 10);
        const material = new THREE.MeshPhysicalMaterial();
        const mesh = new THREE.Mesh(geometry, material);
        mesh.position.x = (Math.random() - 0.5) * 5
        mesh.position.y = (Math.random() - 0.5) * 5
        mesh.position.z = (Math.random() - 0.5) * 5
        mesh.rs = 0.001 + Math.random() * 0.01
        group.add(mesh);
        spheres.push(mesh)
    }

    scene.add(group)
    const renderer = params.renderer
    renderer.setAnimationLoop(animation);

    const light1 = new THREE.PointLight(0xe100ff, 10, 10);
    light1.position.set(-10, 0, 0);
    scene.add(light1);

    const light2 = new THREE.PointLight(0x2200ff, 10, 10);
    light2.position.set(10, 0, 0);
    scene.add(light2);

    function animation(time) {
        params.animateCubes()
        group.rotation.y += 0.001
        renderer.render(scene, camera);
    }

    camera.position.z = 2.5

    // Register script parameters to global _sb object
    _sb.scripts.stacked3DObjects2 = {
        scene,
        renderer,
        camera,
        spheres
    };
};

// Initiate this script with stacked3DObjects1 
// script parameters
stacked3DObjects2(_sb.scripts.stacked3DObjects1);