  
# scripty.sol

**scripty.sol** is a gas-efficient, on-chain HTML builder that's tuned for stitching large JS based <scripts> tags together.

![scripty.sol](https://3939295614-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2FH5xTgJNBs6I0hLj9RCqL%2Fuploads%2FZBqLDIPkDrohu45QVMiV%2Fheader.png?alt=media)

### [Documentation](https://int-art.gitbook.io/scripty.sol-v2/)
**scripty.sol** allows you to build HTML files directly on-chain with minimal gas cost. Some benefits of using scripty.sol:
- Gas efficient. It utilises `DynamicBuffer` to save huge amount of gas while assembling scripts together. 
- scripty.sol is storage agnostic. You can use any on-chain storage solutions available.
- You can build modular JS based HTML files directly on-chain.
- You can dynamically inject data into your HTML.

### Platforms using scripty.sol
- [Art Blocks](https://www.artblocks.io)
- [Alba](https://www.alba.art)

### Projects using scripty.sol
- [CryptoCoaster](https://www.cryptocoaster.fun/)
- [the metro](https://drops.int.art/the-metro)
- [GOLD](https://www.making.gold/)
- [Terraform Navigator](https://etherscan.io/address/0xad41bf1c7f22f0ec988dac4c0ae79119cab9bb7e#code)
- [Panopticon](https://panopticon.teto.io)

### Protocols using scripty.sol
- [Mint](https://mint.vv.xyz)

## Installation
Contracts and verified scripts(JS) are published through npm:
```javascript
npm install scripty.sol --save-dev
```

## Example
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
HTMLRequest memory htmlRequest;
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
### Ethereum Mainnet
-  **ScriptyStorageV2** - [0xbD11994aABB55Da86DC246EBB17C1Be0af5b7699](https://etherscan.io/address/0xbD11994aABB55Da86DC246EBB17C1Be0af5b7699)
-  **ScriptyBuilderV2** - [0xD7587F110E08F4D120A231bA97d3B577A81Df022](https://etherscan.io/address/0xD7587F110E08F4D120A231bA97d3B577A81Df022)
-  **ETHFSV2FileStorage** - [0x8FAA1AAb9DA8c75917C43Fb24fDdb513edDC3245](https://etherscan.io/address/0x8FAA1AAb9DA8c75917C43Fb24fDdb513edDC3245)

### Ethereum Goerli
-  **ScriptyStorageV2** - [0xbD11994aABB55Da86DC246EBB17C1Be0af5b7699](https://goerli.etherscan.io/address/0xbD11994aABB55Da86DC246EBB17C1Be0af5b7699)
-  **ScriptyBuilderV2** - [0xD7587F110E08F4D120A231bA97d3B577A81Df022](https://goerli.etherscan.io/address/0xD7587F110E08F4D120A231bA97d3B577A81Df022)
-  **ETHFSV2FileStorage** - [0x8FAA1AAb9DA8c75917C43Fb24fDdb513edDC3245](https://goerli.etherscan.io/address/0x8FAA1AAb9DA8c75917C43Fb24fDdb513edDC3245)

### Ethereum Sepolia
-  **ScriptyStorageV2** - [0xbD11994aABB55Da86DC246EBB17C1Be0af5b7699](https://sepolia.etherscan.io/address/0xbD11994aABB55Da86DC246EBB17C1Be0af5b7699)
-  **ScriptyBuilderV2** - [0xD7587F110E08F4D120A231bA97d3B577A81Df022](https://sepolia.etherscan.io/address/0xD7587F110E08F4D120A231bA97d3B577A81Df022)
-  **ETHFSV2FileStorage** - [0x8FAA1AAb9DA8c75917C43Fb24fDdb513edDC3245](https://sepolia.etherscan.io/address/0x8FAA1AAb9DA8c75917C43Fb24fDdb513edDC3245)

### Ethereum Holesky
-  **ScriptyStorageV2** - [0xbD11994aABB55Da86DC246EBB17C1Be0af5b7699](https://holesky.etherscan.io/address/0xbD11994aABB55Da86DC246EBB17C1Be0af5b7699)
-  **ScriptyBuilderV2** - [0xD7587F110E08F4D120A231bA97d3B577A81Df022](https://holesky.etherscan.io/address/0xD7587F110E08F4D120A231bA97d3B577A81Df022)
-  **ETHFSV2FileStorage** - [0x8FAA1AAb9DA8c75917C43Fb24fDdb513edDC3245](https://holesky.etherscan.io/address/0x8FAA1AAb9DA8c75917C43Fb24fDdb513edDC3245)

### Base
-  **ScriptyStorageV2** - [0xbD11994aABB55Da86DC246EBB17C1Be0af5b7699](https://basescan.org/address/0xbD11994aABB55Da86DC246EBB17C1Be0af5b7699)
-  **ScriptyBuilderV2** - [0xD7587F110E08F4D120A231bA97d3B577A81Df022](https://basescan.org/address/0xD7587F110E08F4D120A231bA97d3B577A81Df022)
-  **ETHFSV2FileStorage** - [0x8FAA1AAb9DA8c75917C43Fb24fDdb513edDC3245](https://basescan.org/address/0x8FAA1AAb9DA8c75917C43Fb24fDdb513edDC3245)

### Base Sepolia
-  **ScriptyStorageV2** - [0xbD11994aABB55Da86DC246EBB17C1Be0af5b7699](https://sepolia.basescan.org/address/0xbD11994aABB55Da86DC246EBB17C1Be0af5b7699)
-  **ScriptyBuilderV2** - [0xD7587F110E08F4D120A231bA97d3B577A81Df022](https://sepolia.basescan.org/address/0xD7587F110E08F4D120A231bA97d3B577A81Df022)
-  **ETHFSV2FileStorage** - [0x8FAA1AAb9DA8c75917C43Fb24fDdb513edDC3245](https://sepolia.basescan.org/address/0x8FAA1AAb9DA8c75917C43Fb24fDdb513edDC3245)

### Optimism
-  **ScriptyStorageV2** - [0xbD11994aABB55Da86DC246EBB17C1Be0af5b7699](https://optimistic.etherscan.io/address/0xbD11994aABB55Da86DC246EBB17C1Be0af5b7699)
-  **ScriptyBuilderV2** - [0xD7587F110E08F4D120A231bA97d3B577A81Df022](https://optimistic.etherscan.io/address/0xD7587F110E08F4D120A231bA97d3B577A81Df022)
-  **ETHFSV2FileStorage** - [0x8FAA1AAb9DA8c75917C43Fb24fDdb513edDC3245](https://optimistic.etherscan.io/address/0x8FAA1AAb9DA8c75917C43Fb24fDdb513edDC3245)

### Optimism Sepolia
-  **ScriptyStorageV2** - [0xbD11994aABB55Da86DC246EBB17C1Be0af5b7699](https:/sepolia-optimism.etherscan.io/address/0xbD11994aABB55Da86DC246EBB17C1Be0af5b7699)
-  **ScriptyBuilderV2** - [0xD7587F110E08F4D120A231bA97d3B577A81Df022](https://sepolia-optimism.etherscan.io/address/0xD7587F110E08F4D120A231bA97d3B577A81Df022)
-  **ETHFSV2FileStorage** - [0x8FAA1AAb9DA8c75917C43Fb24fDdb513edDC3245](https://sepolia-optimism.etherscan.io/address/0x8FAA1AAb9DA8c75917C43Fb24fDdb513edDC3245)


## Live Examples
#### Stacked 3D Objects Shapes - [NFT1](https://testnets.opensea.io/assets/sepolia/0x29aefc985abE4ea7EEf671686423E8E5dfC81b3F/0) [NFT2](https://testnets.opensea.io/assets/sepolia/0x7A89d427099c331234D96AA97AF56ab1D23Eb100/0)

Both NFTs assemble PNG compressed base 64 encoded `three.js` with an uncompressed demo scene. First NFT creates some 3D cubes. Second NFT gets the first NFT scene on-chain and adds spheres.

#### [p5js from EthFS FileStore V2](https://testnets.opensea.io/assets/sepolia/0x652d9938C49b1a08B32dE62420Bd7c0f80aDfF17/0)
Assembles base64 encoded `p5.js` that's stored in ethfs's FileStore contract with a demo scene. Metadata and animation URL are both base64 encoded.

#### [p5js from EthFS FileStore V2 - URL Safe](https://testnets.opensea.io/assets/sepolia/0xda6ca4a69b775fd37f6a2b418065dc68de28cf15/0)
Assembles base64 encoded `p5.js` that's stored in ethfs's FileStore contract with a demo scene. Metadata and animation URL are both URL encoded.

#### [Random Shapes](https://testnets.opensea.io/assets/sepolia/0xe40e09F70197d4C01bAa250cbE2d0e28d4E40251/0)
Assembles multiple uncompressed scripts that draw shapes on same `<canvas></canvas>` element with a controller script that is created in NFT contract. This controller script passes some chain parameters to canvas scene.

#### [Cube3D - GZIP Compressed - BASE64 Encoded](https://testnets.opensea.io/assets/sepolia/0x27013186Bde55Fd474f7f314299a09185e59D05d/0)
Assembles GZIP compressed Base64 encoded `three.js` with a demo scene. Metadata and animation URL are both base64 encoded.

#### [Cube3D - GZIP Compressed - URL Safe](https://testnets.opensea.io/assets/sepolia/0x0df753000d277E043d7Cf713A79cfa3976AC28F2/0)
Assembles GZIP compressed base64 encoded `three.js` with a demo scene. Metadata and animation URL are both URL encoded.

#### [Cube3D - PNG Compressed - URL Safe](https://testnets.opensea.io/assets/sepolia/0x770d0949e28B42405aDA6E8c26D051D99c7476C8/0)
Assembles PNG compressed base64 encoded `three.js` with a demo scene. Metadata and animation URL are both URL encoded.

#### [Cube3D - PNG Compressed - URL Safe with custom wrap](https://testnets.opensea.io/assets/sepolia/0x2aB58dcDAC58636294F5F2d6b4D018F55Dab6842/0)
Assembles PNG compressed base64 encoded `three.js` with a demo scene. Metadata and animation URL are both URL encoded. It uses custom script wraps.

#### [ThreeJS Module - GZIP Compressed - URL Safe with custom wrap](https://testnets.opensea.io/assets/sepolia/0x2BC45AFC7D73456D9aFEfd3751accCFa92522EC0/0)

Assembles GZIP compressed base64 encoded `modular three.js` with a demo scene. Metadata and animation URL are both URL encoded. It uses custom script wraps. This is the most complex of all the examples. It demonstrates how to:
- dynamically inject data into your javascript code
- load gzipped javascript modules in the desired order, using gzipped es-module-shim for full browser support
- embed custom javascript
- make it all URL safe

## Authors
- [int.art / @0xthedude](https://twitter.com/intartNFT)
- [@xtremetom](https://twitter.com/xtremetom)

## Acknowledgments
- [EthFS](https://github.com/holic/ethfs) - [@frolic](https://twitter.com/frolic)
- DynamicBuffer - [@cxkoda](https://twitter.com/cxkoda)