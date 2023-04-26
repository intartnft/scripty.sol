// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "solady/src/utils/Base64.sol";
import "solady/src/utils/LibString.sol";

import {HTMLRequest, ScriptRequest} from "../../scripty/ScriptyCore.sol";
import {IScriptyBuilderV2, HTMLRequest} from "../../scripty/IScriptyBuilderV2.sol";

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
        ScriptRequest[] memory scriptRequests = new ScriptRequest[](5);
        scriptRequests[0].name = "scriptyBase";
        scriptRequests[0].contractAddress = scriptyStorageAddress;

        scriptRequests[1].name = "drawCircles";
        scriptRequests[1].contractAddress = scriptyStorageAddress;

        scriptRequests[2].name = "drawRectangles";
        scriptRequests[2].contractAddress = scriptyStorageAddress;

        scriptRequests[3].name = "drawShapes";
        scriptRequests[3].contractAddress = scriptyStorageAddress;

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
        scriptRequests[4].scriptContent = controllerScript;

        HTMLRequest memory htmlRequest;
        htmlRequest.scriptRequests = scriptRequests;

        bytes memory base64EncodedHTMLDataURI = IScriptyBuilderV2(
            scriptyBuilderAddress
        ).getEncodedHTMLInline(htmlRequest);

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
