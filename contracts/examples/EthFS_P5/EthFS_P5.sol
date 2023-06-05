// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "solady/src/utils/Base64.sol";

import {IScriptyBuilderV2, HTMLRequest, HTMLTagType, HTMLTag} from "../../scripty/interfaces/IScriptyBuilderV2.sol";

contract EthFS_P5 is ERC721 {
    address public immutable ethfsFileStorageAddress;
    address public immutable scriptyStorageAddress;
    address public immutable scriptyBuilderAddress;

    constructor(
        address _ethfsFileStorageAddress,
        address _scriptyStorageAddress,
        address _scriptyBuilderAddress
    ) ERC721("example", "EXP") {
        ethfsFileStorageAddress = _ethfsFileStorageAddress;
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
        HTMLTag[] memory bodyTags = new HTMLTag[](4);
        bodyTags[0].name = "scriptyBase";
        bodyTags[0].tagType = HTMLTagType.script; // <script>[script]</script>
        bodyTags[0].contractAddress = scriptyStorageAddress;

        bodyTags[1].name = "p5-v1.5.0.min.js.gz";
        bodyTags[1].tagType = HTMLTagType.scriptGZIPBase64DataURI; // <script type="text/javascript+gzip" src="data:text/javascript;base64,[script]"></script>
        bodyTags[1].contractAddress = ethfsFileStorageAddress;

        bodyTags[2].name = "gunzipScripts-0.0.1.js";
        bodyTags[2].tagType = HTMLTagType.scriptBase64DataURI; // <script src="data:text/javascript;base64,[script]"></script>
        bodyTags[2].contractAddress = ethfsFileStorageAddress;

        bodyTags[3].name = "pointsAndLines";
        bodyTags[3].tagType = HTMLTagType.script; // <script>[script]</script>
        bodyTags[3].contractAddress = scriptyStorageAddress;
        
        HTMLTag[] memory headTags = new HTMLTag[](1);
        headTags[0].tagOpen = "<style>";
        headTags[0].tagContent = "html{height:100%}body{min-height:100%;margin:0;padding:0}canvas{padding:0;margin:auto;display:block;position:absolute;top:0;bottom:0;left:0;right:0}";
        headTags[0].tagClose = "</style>";

        HTMLRequest memory htmlRequest;
        htmlRequest.headTags = headTags;
        htmlRequest.bodyTags = bodyTags;

        bytes memory base64EncodedHTMLDataURI = IScriptyBuilderV2(
            scriptyBuilderAddress
        ).getEncodedHTML(htmlRequest);

        bytes memory metadata = abi.encodePacked(
            '{"name":"p5.js Example - GZIP - Base64", "description":"Assembles GZIP compressed base64 encoded p5.js stored in ethfs FileStore contract with a demo scene. Metadata and animation URL are both base64 encoded.","animation_url":"',
            base64EncodedHTMLDataURI,
            '"}'
        );

        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(metadata)
                )
            );
    }
}
