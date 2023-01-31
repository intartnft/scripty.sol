// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "solady/src/utils/Base64.sol";

import {IScriptyBuilder, WrappedScriptRequest} from "../../scripty/IScriptyBuilder.sol";

contract ThreeJSModules_URLSafe is ERC721 {
    address public immutable scriptyStorageAddress;
    address public immutable scriptyBuilderAddress;
    uint256 public immutable bufferSize;

    constructor(
        address _scriptyStorageAddress,
        address _scriptyBuilderAddress,
        uint256 _bufferSize
    ) ERC721("example", "EXP") {
        scriptyStorageAddress = _scriptyStorageAddress;
        scriptyBuilderAddress = _scriptyBuilderAddress;
        bufferSize = _bufferSize;
        mint();
    }

    function mint() internal {
        _safeMint(msg.sender, 0);
    }

    function tokenURI(
        uint256 /*_tokenId*/
    ) public view virtual override returns (string memory) {
        WrappedScriptRequest[] memory requests = new WrappedScriptRequest[](7);

        requests[0].name = "gunzipScripts-0.0.1.js";
        requests[0].wrapType = 1; // <script src="data:text/javascript;base64,[script]"></script>
        requests[0].contractAddress = scriptyStorageAddress;

        requests[1].name = "es-module-shims.js.gz";
        requests[1].wrapType = 2; // <script type="text/javascript+gzip" src="data:text/javascript;base64,[script]"></script>
        requests[1].contractAddress = scriptyStorageAddress;

        requests[2].name = "threejs.module.js.gz";
        requests[2].wrapType = 4; // custom see wrapPrefix + wrapSuffix
        // double encoded:
        // - <script>var t3 = "
        // - "</script>
        requests[2].wrapPrefix = "%253Cscript%253Evar%2520t3%2520%253D%2520%2522";
        requests[2].wrapSuffix = "%2522%253C%252Fscript%253E";
        requests[2].contractAddress = scriptyStorageAddress;

        requests[3].name = "OrbitControls.module.js.gz";
        requests[3].wrapType = 4; // custom see wrapPrefix + wrapSuffix
        // double encoded:
        // - <script>var oc = "
        // - "</script>
        requests[3].wrapPrefix = "%253Cscript%253Evar%2520oc%2520%253D%2520%2522";
        requests[3].wrapSuffix = "%2522%253C%252Fscript%253E";
        requests[3].contractAddress = scriptyStorageAddress;

        requests[4].name = "importHandler";
        requests[4].wrapType = 0; // <script>[script]</script>
        requests[4].contractAddress = scriptyStorageAddress;

        requests[5].name = "";
        requests[5].wrapType = 0; // <script>[script]</script>
        requests[5].scriptContent = 'injectImportMap([["three",t3],["OrbitControls",oc]],gunzipScripts)';

        requests[6].name = "torus";
        requests[6].wrapType = 4; // <script>[script]</script>
        // double encoded:
        // - <script type="module" src="data:text/javascript;base64,
        // - "></script>
        requests[6].wrapPrefix = "%253Cscript%2520type%253D%2522module%2522%2520src%253D%2522data%253Atext%252Fjavascript%253Bbase64%252C";
        requests[6].wrapSuffix = "%2522%253E%253C%252Fscript%253E";
        requests[6].contractAddress = scriptyStorageAddress;

        // For easier testing, bufferSize is injected in the constructor
        // of this contract.

        bytes memory doubleURLEncodedHTMLDataURI = IScriptyBuilder(scriptyBuilderAddress)
            .getHTMLWrappedURLSafe(requests, bufferSize);

        return
            string(
                abi.encodePacked(
                    "data:application/json,",
                    // url encoded once
                    // {"name":"three.module.js Example - GZIP - Base64 - Modules - URL Safe", "description":"Assembles GZIP compressed module based threeJS to create a demo scene. Metadata and animation URL are both URL encoded.","animation_url":"
                    "%7B%22name%22%3A%22three.module.js%20Example%20-%20GZIP%20-%20Base64%20-%20Modules%20-%20URL%20Safe%22%2C%20%22description%22%3A%22Assembles%20GZIP%20compressed%20module%20based%20threeJS%20to%20create%20a%20demo%20scene.%20Metadata%20and%20animation%20URL%20are%20both%20URL%20encoded.%22%2C%22animation_url%22%3A%22",
                    doubleURLEncodedHTMLDataURI,
                    // url encoded once
                    // "}
                    "%22%7D"
                )
            );
    }
}
