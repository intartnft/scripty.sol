// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "solady/src/utils/Base64.sol";
import "solady/src/utils/LibString.sol";

import {IScriptyBuilderV2, HTMLRequest, HTMLTagType, HTMLTag} from "../../scripty/interfaces/IScriptyBuilderV2.sol";

contract RandomShapes is ERC721 {
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
        HTMLTag[] memory headTags = new HTMLTag[](1);
        headTags[0].tagOpen = "<style>";
        headTags[0].tagContent = "html{height:100%}body{min-height:100%;margin:0;padding:0}canvas{padding:0;margin:auto;display:block;position:absolute;top:0;bottom:0;left:0;right:0}";
        headTags[0].tagClose = "</style>";


        HTMLTag[] memory bodyTags = new HTMLTag[](5);
        bodyTags[0].name = "scriptyBase";
        bodyTags[0].tagType = HTMLTagType.script; // <script>[script]</script>
        bodyTags[0].contractAddress = scriptyStorageAddress;
        
        bodyTags[1].name = "drawCircles";
        bodyTags[1].tagType = HTMLTagType.script; // <script>[script]</script>
        bodyTags[1].contractAddress = scriptyStorageAddress;

        bodyTags[2].name = "drawRectangles";
        bodyTags[2].tagType = HTMLTagType.script; // <script>[script]</script>
        bodyTags[2].contractAddress = scriptyStorageAddress;

        bodyTags[3].name = "drawShapes";
        bodyTags[3].tagType = HTMLTagType.script; // <script>[script]</script>
        bodyTags[3].contractAddress = scriptyStorageAddress;

        string memory numberOfCircles = LibString.toString(
            (block.timestamp % 300) + 50
        );
        string memory numberOfRectangles = LibString.toString(
            (block.timestamp % 200) + 50
        );

        bytes memory controllerScript = abi.encodePacked(
            "drawShapes(",
            numberOfCircles,
            ",",
            numberOfRectangles,
            ");"
        );
        bodyTags[4].tagType = HTMLTagType.script; // <script>[script]</script>
        bodyTags[4].tagContent = controllerScript;


        HTMLRequest memory htmlRequest;
        htmlRequest.headTags = headTags;
        htmlRequest.bodyTags = bodyTags;

        bytes memory base64EncodedHTMLDataURI = IScriptyBuilderV2(
            scriptyBuilderAddress
        ).getEncodedHTML(htmlRequest);

        bytes memory metadata = abi.encodePacked(
            '{"name":"Random Shapes", "description":"Assembles two raw scripts that draw shapes on same <canvas></canvas> element.","animation_url":"',
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
