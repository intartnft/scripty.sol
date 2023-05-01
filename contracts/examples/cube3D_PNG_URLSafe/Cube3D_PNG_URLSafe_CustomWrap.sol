// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "solady/src/utils/Base64.sol";

import {
    IScriptyBuilderV2, 
    HTMLRequest, 
    HeadRequest, 
    ScriptRequest
} from "../../scripty/interfaces/IScriptyBuilderV2.sol";

contract Cube3D_PNG_URLSafe_CustomWrap is ERC721 {
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
        ScriptRequest[] memory scriptRequests = new ScriptRequest[](4);
        scriptRequests[0].name = "scriptyBase";
        scriptRequests[0].wrapType = 0; // <script>[script]</script>
        scriptRequests[0].contractAddress = scriptyStorageAddress;

        scriptRequests[1].name = "threejs.min.js.png";
        scriptRequests[1].wrapType = 4;
        // double encoded:
        // - <script type="text/javascript+png" src="data:image/png;base64,[script]"></script>
        // - "></script>
        scriptRequests[1]
            .wrapPrefix = "%253Cscript%2520type%253D%2522text%252Fjavascript%252Bpng%2522%2520src%253D%2522data%253Aimage%252Fpng%253Bbase64%252C";
        scriptRequests[1].wrapSuffix = "%2522%253E%253C%252Fscript%253E";
        scriptRequests[1].contractAddress = scriptyStorageAddress;

        scriptRequests[2].name = "injectPNGScripts-0.0.1";
        scriptRequests[2].wrapType = 0; // <script>[script]</script>
        scriptRequests[2].contractAddress = scriptyStorageAddress;

        scriptRequests[3].name = "cube3D";
        scriptRequests[3].wrapType = 0; // <script>[script]</script>
        scriptRequests[3].contractAddress = scriptyStorageAddress;

        // double encoded:
        // <script>
        //     html{height:100%}body{min-height:100%;margin:0;padding:0}canvas{padding:0;margin:auto;display:block;position:absolute;top:0;bottom:0;left:0;right:0}
        // </script>
        HeadRequest[] memory headRequests = new HeadRequest[](1);
        headRequests[0].tagPrefix = "%253Cstyle%253E";
        headRequests[0].tagContent = "html%257Bheight%253A100%2525%257Dbody%257Bmin-height%253A100%2525%253Bmargin%253A0%253Bpadding%253A0%257Dcanvas%257Bpadding%253A0%253Bmargin%253Aauto%253Bdisplay%253Ablock%253Bposition%253Aabsolute%253Btop%253A0%253Bbottom%253A0%253Bleft%253A0%253Bright%253A0%257D";
        headRequests[0].tagSuffix = "%253C%252Fstyle%253E";

        HTMLRequest memory htmlRequest;
        htmlRequest.headRequests = headRequests;
        htmlRequest.scriptRequests = scriptRequests;

        bytes memory doubleURLEncodedHTMLDataURI = IScriptyBuilderV2(
            scriptyBuilderAddress
        ).getHTMLWrappedURLSafe(htmlRequest);

        return
            string(
                abi.encodePacked(
                    "data:application/json,",
                    // url encoded once
                    // {"name":"Cube3D - PNG Compressed - URL Safe", "description":"Assembles PNG compressed base64 encoded three.js with a demo scene. Metadata and animation URL are both URL encoded. Uses custom JS wraps.","animation_url":"
                    "%7B%22name%22%3A%22Cube3D%20-%20PNG%20Compressed%20-%20URL%20Safe%22%2C%20%22description%22%3A%22Assembles%20PNG%20compressed%20base64%20encoded%20three.js%20with%20a%20demo%20scene.%20Metadata%20and%20animation%20URL%20are%20both%20URL%20encoded.%20Uses%20custom%20JS%20wraps.%22%2C%22animation_url%22%3A%22",
                    doubleURLEncodedHTMLDataURI,
                    // url encoded once
                    // "}
                    "%22%7D"
                )
            );
    }
}
