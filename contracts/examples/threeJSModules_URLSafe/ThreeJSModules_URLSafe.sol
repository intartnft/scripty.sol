// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "solady/src/utils/Base64.sol";

import {IScriptyBuilderV2, HTMLRequest, HTMLTagType, HTMLTag} from "../../scripty/interfaces/IScriptyBuilderV2.sol";

contract ThreeJSModules_URLSafe is ERC721 {
    address public immutable scriptyStorageAddress;
    address public immutable scriptyBuilderAddress;

    constructor(
        address _scriptyStorageAddress,
        address _scriptyBuilderAddress
    ) ERC721("example", "EXP") {
        scriptyStorageAddress = _scriptyStorageAddress;
        scriptyBuilderAddress = _scriptyBuilderAddress;
        mint();
    }

    function mint() internal {
        _safeMint(msg.sender, 0);
    }

    function tokenURI(
        uint256 /*_tokenId*/
    ) public view virtual override returns (string memory) {
        HTMLTag[] memory bodyTags = new HTMLTag[](7);

        bodyTags[0].name = "gunzipScripts-0.0.1.js";
        bodyTags[0].tagType = HTMLTagType.scriptBase64DataURI; // <script src="data:text/javascript;base64,[script]"></script>
        bodyTags[0].contractAddress = scriptyStorageAddress;

        bodyTags[1].name = "es-module-shims.js.gz";
        bodyTags[1].tagType = HTMLTagType.scriptGZIPBase64DataURI; // <script type="text/javascript+gzip" src="data:text/javascript;base64,[script]"></script>
        bodyTags[1].contractAddress = scriptyStorageAddress;

        bodyTags[2].name = "threejs.module.js.gz";
        bodyTags[2].tagType = HTMLTagType.any; // custom see tagOpen + tagClose
        // double encoded:
        // - <script>var t3 = "
        // - "</script>
        bodyTags[2].tagOpen = "%253Cscript%253Evar%2520t3%2520%253D%2520%2522";
        bodyTags[2].tagClose = "%2522%253C%252Fscript%253E";
        bodyTags[2].contractAddress = scriptyStorageAddress;

        bodyTags[3].name = "OrbitControls.module.js.gz";
        bodyTags[3].tagType = HTMLTagType.any; // custom see wrapPrefix + wrapSuffix
        // double encoded:
        // - <script>var oc = "
        // - "</script>
        bodyTags[3].tagOpen = "%253Cscript%253Evar%2520oc%2520%253D%2520%2522";
        bodyTags[3].tagClose = "%2522%253C%252Fscript%253E";
        bodyTags[3].contractAddress = scriptyStorageAddress;

        bodyTags[4].name = "importHandler";
        bodyTags[4].tagType = HTMLTagType.any; // <script>[script]</script>
        bodyTags[4].contractAddress = scriptyStorageAddress;

        bodyTags[5].name = "";
        bodyTags[5].tagType = HTMLTagType.script; // <script>[script]</script>
        bodyTags[5].tagContent = 'injectImportMap([["three",t3],["OrbitControls",oc]],gunzipScripts)';

        bodyTags[6].name = "torus";
        bodyTags[6].tagType = HTMLTagType.any; // <script>[script]</script>
        // double encoded:
        // - <script type="module" src="data:text/javascript;base64,
        // - "></script>
        bodyTags[6].tagOpen = "%253Cscript%2520type%253D%2522module%2522%2520src%253D%2522data%253Atext%252Fjavascript%253Bbase64%252C";
        bodyTags[6].tagClose = "%2522%253E%253C%252Fscript%253E";
        bodyTags[6].contractAddress = scriptyStorageAddress;

        // double encoded:
        // <style>
        //     html{height:100%}body{min-height:100%;margin:0;padding:0}canvas{padding:0;margin:auto;display:block;position:absolute;top:0;bottom:0;left:0;right:0}
        // </style>
        HTMLTag[] memory headTags = new HTMLTag[](1);
        headTags[0].tagOpen = "%253Cstyle%253E";
        headTags[0].tagContent = "html%257Bheight%253A100%2525%257Dbody%257Bmin-height%253A100%2525%253Bmargin%253A0%253Bpadding%253A0%257Dcanvas%257Bpadding%253A0%253Bmargin%253Aauto%253Bdisplay%253Ablock%253Bposition%253Aabsolute%253Btop%253A0%253Bbottom%253A0%253Bleft%253A0%253Bright%253A0%257D";
        headTags[0].tagClose = "%253C%252Fstyle%253E";

        HTMLRequest memory htmlRequest;
        htmlRequest.headTags = headTags;
        htmlRequest.bodyTags = bodyTags;

        bytes memory doubleURLEncodedHTMLDataURI = IScriptyBuilderV2(
            scriptyBuilderAddress
        ).getHTMLURLSafe(htmlRequest);

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
