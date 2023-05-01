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

contract Stacked3DObjects_Cubes is ERC721 {
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

        scriptRequests[1].name = "three.min.js.gz";
        scriptRequests[1].wrapType = 2; // <script type="text/javascript+gzip" src="data:text/javascript;base64,[script]"></script>
        scriptRequests[1].contractAddress = scriptyStorageAddress;

        scriptRequests[2].name = "gunzipScripts-0.0.1";
        scriptRequests[2].wrapType = 0; // <script>[script]</script>
        scriptRequests[2].contractAddress = scriptyStorageAddress;

        scriptRequests[3].name = "stacked3DObjects1";
        scriptRequests[3].wrapType = 0; // <script>[script]</script>
        scriptRequests[3].contractAddress = scriptyStorageAddress;

        HeadRequest[] memory headRequests = new HeadRequest[](1);
        headRequests[0].tagPrefix = "<style>";
        headRequests[0].tagContent = "html{height:100%}body{min-height:100%;margin:0;padding:0}canvas{padding:0;margin:auto;display:block;position:absolute;top:0;bottom:0;left:0;right:0}";
        headRequests[0].tagSuffix = "</style>";

        HTMLRequest memory htmlRequest;
        htmlRequest.headRequests = headRequests;
        htmlRequest.scriptRequests = scriptRequests;

        bytes memory base64EncodedHTMLDataURI = IScriptyBuilderV2(
            scriptyBuilderAddress
        ).getEncodedHTMLWrapped(htmlRequest);

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
