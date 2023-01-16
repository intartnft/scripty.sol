// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "solady/src/utils/Base64.sol";

import {IScriptyBuilder, WrappedScriptRequest} from "../../scripty/IScriptyBuilder.sol";

contract Stacked3DObjects_Cubes is ERC721 {
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
        WrappedScriptRequest[] memory requests = new WrappedScriptRequest[](4);
        requests[0].name = "scriptyBase";
        requests[0].wrapType = 0; // <script>[script]</script>
        requests[0].contractAddress = scriptyStorageAddress;

        requests[1].name = "three.min.js.gz";
        requests[1].wrapType = 2; // <script type="text/javascript+gzip" src="data:text/javascript;base64,[script]"></script>
        requests[1].contractAddress = scriptyStorageAddress;

        requests[2].name = "gunzipScripts-0.0.1";
        requests[2].wrapType = 0; // <script>[script]</script>
        requests[2].contractAddress = scriptyStorageAddress;

        requests[3].name = "stacked3DObjects1";
        requests[3].wrapType = 0; // <script>[script]</script>
        requests[3].contractAddress = scriptyStorageAddress;

        // For easier testing, bufferSize is injected in the constructor
        // of this contract.

        bytes memory base64EncodedHTMLDataURI = IScriptyBuilder(scriptyBuilderAddress).getEncodedHTMLWrapped(
            requests,
            bufferSize
        );

        bytes memory metadata = abi.encodePacked(
            '{"name":"Stacked 3D Objects - Cubes", "description":"Assembles PNG compressed base64 encoded three.js with an uncompressed demo scene. Script that generates cubes is registered to base scripty script so that others can manipluate this scene.","animation_url":"',
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
