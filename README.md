  
# scripty.sol

**scripty.sol** is a gas-efficient HTML builder tuned for stitching large JS based <scripts> together.
![scripty.sol](https://3939295614-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2FH5xTgJNBs6I0hLj9RCqL%2Fuploads%2FZBqLDIPkDrohu45QVMiV%2Fheader.png?alt=media)

### [Documentation](https://int-art.gitbook.io/scripty.sol/)
**scripty.sol** allows you to build HTML files that embed JS that are stored on-chain. Some benefits of using scripty.sol:
- Gas efficient. It utilises `DynamicBuffer` and ethfs to save huge amount of gas while storing and assembling scripts together.
- You can use already deployed storage solutions.
- You can build modular JS based HTML files directly on-chain.
- Supports creating dynamically created JS based `<script>` tags that is super helpful for on-chain generative art.

### Platforms that use scripty.sol
- ArtBlocks
- Alba

### Projects that use scripty.sol
- CryptoCoaster
- the metro
- GOLD

## Installation
Contracts and verified scripts(JS) are published through npm:
```javascript
npm install scripty.sol --save-dev
```


## Example
The example below generates a simple HTML with fullsize canvas element and a script element that draws a rectangle on the canvas:
```solidity
// Create head tags
HTMLTag[] memory headTags = new HTMLTag[](1);
headTags[0].tagOpen = "<style>";
headTags[0].tagContent = "html{height:100%}body{min-height:100%;margin:0;padding:0}canvas{padding:0;margin:auto;display:block;position:absolute;top:0;bottom:0;left:0;right:0}";
headTags[0].tagClose = "</style>";

// Create body tags
HTMLTag[] memory bodyTags = new HTMLTag[](2);
bodyTags[0].tagOpen = '<canvas id="myCanvas">';
bodyTags[0].tagClose = "</canvas>";

bodyTags[1].tagContent = 'const canvas=document.getElementById("myCanvas"),ctx=canvas.getContext("2d");ctx.beginPath(),ctx.rect(20,20,150,100),ctx.stroke();';
bodyTags[1].tagType = HTMLTagType.script;

// Create HTML request with head and body tags
HTMLRequest memory headTags;
htmlRequest.headTags = headTags;
htmlRequest.bodyTags = bodyTags;

// Get full HTML string
string memory htmlString = IScriptyBuilderV2(
    scriptyBuilderAddress
).getHTMLString(htmlRequest);
```

#### HTML file output:
```html
<html>
  <head>
    <style>
      html {
        height: 100%
      }

      body {
        min-height: 100%;
        margin: 0;
        padding: 0
      }

      canvas {
        padding: 0;
        margin: auto;
        display: block;
        position: absolute;
        top: 0;
        bottom: 0;
        left: 0;
        right: 0
      }
    </style>
  </head>
  <body>
    <canvas id="myCanvas"></canvas>
    <script>
      const canvas = document.getElementById("myCanvas");
      const ctx = canvas.getContext("2d");

      ctx.beginPath();
      ctx.rect(20, 20, 150, 100);
      ctx.stroke();
    </script>
  </body>
</html>
```

## Deployed Contracts
### Ethereum Mainnet contracts:
-  **ScriptyStorage** - [0x096451F43800f207FC32B4FF86F286EdaF736eE3](https://etherscan.io/address/0x096451F43800f207FC32B4FF86F286EdaF736eE3)
-  **ScriptyBuilder** - [0x16b727a2Fc9322C724F4Bc562910c99a5edA5084](https://etherscan.io/address/0x16b727a2Fc9322C724F4Bc562910c99a5edA5084)
-  **ETHFSFileStorage** - [0xFc7453dA7bF4d0c739C1c53da57b3636dAb0e11e](https://etherscan.io/address/0xFc7453dA7bF4d0c739C1c53da57b3636dAb0e11e)

### Ethereum Goerli contracts:
-  **ScriptyStorage** - [0x4e2f40eef8DFBF200f3f744a9733Afe2E9F83D28](https://goerli.etherscan.io/address/0x730b0adaad15b0551928bae7011f2c1f2a9ca20c)
-  **ScriptyBuilder** - [0xccd7E419f1EEc86fa748c9079584e3a89312f11C](https://goerli.etherscan.io/address/0xc9AB9815d4D5461F3b53Ebd857b6582E82A45C49)
-  **ETHFSFileStorage** - [0x70a78d91A434C1073D47b2deBe31C184aA8CA9Fa](https://goerli.etherscan.io/address/0x70a78d91A434C1073D47b2deBe31C184aA8CA9Fa)


## Live Examples
#### Stacked 3D Objects Shapes - [NFT1](https://testnets.opensea.io/assets/goerli/0x66530853C069734fD0B0A2c28aEd3D60bb76e960/0) [NFT2](https://testnets.opensea.io/assets/goerli/0xCF925C72d69Bf7F1B6123c3036Cb62A79d73d6ea/0)

Both NFTs assemble PNG compressed base 64 encoded `three.js` with an uncompressed demo scene. First NFT creates some 3D cubes. Second NFT gets the first NFT scene on-chain and adds spheres.

#### [p5js from EthFS FileStore](https://testnets.opensea.io/assets/goerli/0x1901C748eE74E6256d58A927f90557C34Dc16181/0)
Assembles base64 encoded `p5.js` that's stored in ethfs's FileStore contract with a demo scene. Metadata and animation URL are both base64 encoded.

#### [p5js from EthFS FileStore - URL Safe](https://testnets.opensea.io/assets/goerli/0xEbadb9173dCb30658808f770Cb0e281A5864F5Ed/0)
Assembles base64 encoded `p5.js` that's stored in ethfs's FileStore contract with a demo scene. Metadata and animation URL are both URL encoded.

#### [Random Shapes](https://testnets.opensea.io/assets/goerli/0x6Db1f31b58C1329CC1b59bEe41C8cD72a1C3D61c/0)
Assembles multiple uncompressed scripts that draw shapes on same `<canvas></canvas>` element with a controller script that is created in NFT contract. This controller script passes some chain parameters to canvas scene.

#### [Cube3D - GZIP Compressed - BASE64 Encoded](https://testnets.opensea.io/assets/goerli/0xEDe0420DAd5e0320919f6EB68caF8f26BFE559C8/0)
Assembles GZIP compressed Base64 encoded `three.js` with a demo scene. Metadata and animation URL are both base64 encoded.

#### [Cube3D - GZIP Compressed - URL Safe](https://testnets.opensea.io/assets/goerli/0xB2Cc44cCEc7be7bdA61053f60469d0f02827c5d4/0)
Assembles GZIP compressed base64 encoded `three.js` with a demo scene. Metadata and animation URL are both URL encoded.

#### [Cube3D - PNG Compressed - URL Safe](https://testnets.opensea.io/assets/goerli/0xfd9c95469d14b01595170e6f29A1a18588487aD8/0)
Assembles PNG compressed base64 encoded `three.js` with a demo scene. Metadata and animation URL are both URL encoded.

#### [Cube3D - PNG Compressed - URL Safe with custom wrap](https://testnets.opensea.io/assets/goerli/0x461D1072DdEF25A6b4B011a32f64EE3Ce22e4D1D/0)
Assembles PNG compressed base64 encoded `three.js` with a demo scene. Metadata and animation URL are both URL encoded. It uses custom script wraps.

#### [ThreeJS Module - GZIP Compressed - URL Safe with custom wrap](https://testnets.opensea.io/assets/goerli/0x7cA4D7310562cA0b563A28c106bBc842f473F73b/0)

Assembles GZIP compressed base64 encoded `modular three.js` with a demo scene. Metadata and animation URL are both URL encoded. It uses custom script wraps. This is the most complex of all the examples. It demonstrates how to:
- dynamically inject data into your javascript code
- load gzipped javascript modules in the desired order, using gzipped es-module-shim for full browser support
- embed custom javascript
- make it all URL safe

## Authors
- [@0xthedude](https://twitter.com/0xthedude)
- [@xtremetom](https://twitter.com/xtremetom)

## Acknowledgments
- [EthFS](https://github.com/holic/ethfs) - [@frolic](https://twitter.com/frolic)
- DynamicBuffer - [@cxkoda](https://twitter.com/cxkoda)