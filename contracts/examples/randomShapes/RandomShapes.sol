// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "solady/src/utils/Base64.sol";
import "solady/src/utils/LibString.sol";

import {IScriptyBuilder, InlineScriptRequest} from "../../scripty/IScriptyBuilder.sol";

contract RandomShapes is ERC721 {
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
        InlineScriptRequest[] memory requests = new InlineScriptRequest[](5);
        requests[0].name = "scriptyBase";
        requests[0].contractAddress = scriptyStorageAddress;

        requests[1].name = "drawCircles";
        requests[1].contractAddress = scriptyStorageAddress;

        requests[2].name = "drawRectangles";
        requests[2].contractAddress = scriptyStorageAddress;

        requests[3].name = "drawShapes";
        requests[3].contractAddress = scriptyStorageAddress;

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

        requests[4].scriptContent = controllerScript;
        
        // For easier testing, bufferSize for statically stored scripts 
        // is injected in the constructor. Then controller script's length
        // is added to that to find the final buffer size.
        
        uint256 finalBufferSize = bufferSize + controllerScript.length;

        bytes memory base64EncodedHTMLDataURI = IScriptyBuilder(scriptyBuilderAddress).getEncodedHTMLInline(
            requests,
            finalBufferSize
        );

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
