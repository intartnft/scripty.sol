
# scripty.sol

**scripty.sol** is a gas-efficient HTML builder that can combine multiple JS and a data storage solution that allows on-chain composable generative art.

![scripty.sol](https://3939295614-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2FH5xTgJNBs6I0hLj9RCqL%2Fuploads%2FZBqLDIPkDrohu45QVMiV%2Fheader.png?alt=media)
[Documentation](https://int-art.gitbook.io/scripty.sol/)


**scripty.sol** allows you to build HTML files with embedding JS that are stored on-chain. Some benefits of using scripty.sol:
- Gas efficient. It utilises DynamicBuffer and ethfs to save huge amount of gas while storing and assembling scripts together.
- You can use already deployed storage solutions.
- You can build modular JS based HTML files directly on-chain with low gas cost.
- Supports injecting dynamically created scripts between statically stored scripts.
- Provides multiple JS assembling options.

### Ethereum Mainnet contracts:
-  **ScriptyStorage** - [0x096451F43800f207FC32B4FF86F286EdaF736eE3](https://etherscan.io/address/0x096451F43800f207FC32B4FF86F286EdaF736eE3)
-  **ScriptyBuilder** - [0x16b727a2Fc9322C724F4Bc562910c99a5edA5084](https://etherscan.io/address/0x16b727a2Fc9322C724F4Bc562910c99a5edA5084)
-  **ETHFSFileStorage** - [0xFc7453dA7bF4d0c739C1c53da57b3636dAb0e11e](https://etherscan.io/address/0xFc7453dA7bF4d0c739C1c53da57b3636dAb0e11e)


### Ethereum Goerli contracts:
-  **ScriptyStorage** - [0x730B0ADaaD15B0551928bAE7011F2C1F2A9CA20C](https://goerli.etherscan.io/address/0x730b0adaad15b0551928bae7011f2c1f2a9ca20c)
-  **ScriptyBuilder** - [0xc9AB9815d4D5461F3b53Ebd857b6582E82A45C49](https://goerli.etherscan.io/address/0xc9AB9815d4D5461F3b53Ebd857b6582E82A45C49)
-  **ETHFSFileStorage** - [0x70a78d91A434C1073D47b2deBe31C184aA8CA9Fa](https://goerli.etherscan.io/address/0x70a78d91A434C1073D47b2deBe31C184aA8CA9Fa)


## Examples

#### Stacked 3D Objects Shapes - [NFT1](https://testnets.opensea.io/assets/goerli/0xd220C7FF0d96d61966E8c90e4fDa34C1De1defc0/0) [NFT2](https://testnets.opensea.io/assets/goerli/0x89c5bD1128B3be9219E20bDd59c13E47f9F5A4aF/0)
Both NFTs assemble PNG compressed base 64 encoded `three.js` with an uncompressed demo scene. First NFT creates some 3D cubes. Second NFT gets the first NFT scene on-chain and adds spheres.

#### [p5js from EthFS FileStore](https://testnets.opensea.io/assets/goerli/0x06E61fDf18357a3b9cFA1CeB580d4C0b904E13d5/0)
Assembles base64 encoded `p5.js` that's stored in ethfs's FileStore contract with a demo scene. Metadata and animation URL are both base64 encoded.

#### [p5js from EthFS FileStore - URL Safe](https://testnets.opensea.io/assets/goerli/0xE9920199Df69EB29a7EA1B63B3C2Af2deA5538B0/0)
Assembles base64 encoded `p5.js` that's stored in ethfs's FileStore contract with a demo scene. Metadata and animation URL are both URL encoded.

#### [Random Shapes](https://testnets.opensea.io/assets/goerli/0x242d0acd3667B85da5fC675fF32C0Ad90dAcC3e3/0)
Assembles multiple uncompressed scripts that draw shapes on same `<canvas></canvas>` element with a controller script that is created in NFT contract. This controller script passes some chain parameters to canvas scene.

#### [Cube3D - GZIP Compressed - BASE64 Encoded](https://testnets.opensea.io/assets/goerli/0x499DCa12083b67F55A31763adb2C0626Da50c936/0)
Assembles GZIP compressed Base64 encoded `three.js` with a demo scene. Metadata and animation URL are both base64 encoded.

#### [Cube3D - GZIP Compressed - URL Safe](https://testnets.opensea.io/assets/goerli/0x531179D978f2197960fF9B535eeb931CfB9Fffc8/0)
Assembles GZIP compressed base64 encoded `three.js` with a demo scene. Metadata and animation URL are both URL encoded.

#### [Cube3D - PNG Compressed - URL Safe](https://testnets.opensea.io/assets/goerli/0x50a5e74aEC48E1C1216B854D63571eFF27ad4974/0)
Assembles PNG compressed base64 encoded `three.js` with a demo scene. Metadata and animation URL are both URL encoded.

#### [Cube3D - PNG Compressed - URL Safe with custom wrap](https://testnets.opensea.io/assets/goerli/0x00CBa94Cbe7bB53D0611Ac3a18A7ec91d2De9026/0) 
Assembles PNG compressed base64 encoded `three.js` with a demo scene. Metadata and animation URL are both URL encoded. It uses custom script wraps.