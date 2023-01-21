// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "solady/src/utils/Base64.sol";
import "solady/src/utils/LibString.sol";

import {IScriptyBuilder, InlineScriptRequest} from "../../scripty/IScriptyBuilder.sol";

contract LazyDev is ERC721 {
    address public immutable scriptyStorageAddress;
    address public immutable scriptyBuilderAddress;

    constructor(
        address _scriptyStorageAddress,
        address _scriptyBuilderAddress
    ) ERC721("Lazy Dev", "LDEV") {
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

        // For lazy devs that dont want to mess around with buffersize off-chain
        // calculate it here
        IScriptyBuilder scriptyBuilder = IScriptyBuilder(scriptyBuilderAddress);

        uint256 bufferSize = scriptyBuilder.getBufferSizeForHTMLInline(requests);

        bytes memory base64EncodedHTMLDataURI = scriptyBuilder.getEncodedHTMLInline(
            requests,
            bufferSize + controllerScript.length
        );

        bytes memory metadata = abi.encodePacked(
            '{"name":"Lazy Dev", "description":"Assembles two raw scripts that draw shapes on same <canvas></canvas> element with buffer size handled in TokenURI()","animation_url":"',
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
