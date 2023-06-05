// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.17;

// import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
// import "solady/src/utils/Base64.sol";

// import {IScriptyBuilderV2, HTMLRequest, HeadRequest, ScriptRequest} from "../../scripty/interfaces/IScriptyBuilderV2.sol";

// contract Cube3D_GZIP_BASE64 is ERC721 {
//     address public immutable scriptyStorageAddress;
//     address public immutable scriptyBuilderAddress;

//     constructor(
//         address _scriptyStorageAddress,
//         address _scriptyBuilderAddress
//     ) ERC721("example", "EXP") {
//         scriptyStorageAddress = _scriptyStorageAddress;
//         scriptyBuilderAddress = _scriptyBuilderAddress;
//         mint();
//     }

//     function mint() internal {
//         _safeMint(msg.sender, 0);
//     }

//     function tokenURI(
//         uint256 /*_tokenId*/
//     ) public view virtual override returns (string memory) {
//         ScriptRequest[] memory scriptRequests = new ScriptRequest[](4);
//         scriptRequests[0].name = "scriptyBase";
//         scriptRequests[0].tagType = 0; // <script>[script]</script>
//         scriptRequests[0].contractAddress = scriptyStorageAddress;

//         scriptRequests[1].name = "three.min.js.gz";
//         scriptRequests[1].tagType = 2; // <script type="text/javascript+gzip" src="data:text/javascript;base64,[script]"></script>
//         scriptRequests[1].contractAddress = scriptyStorageAddress;

//         scriptRequests[2].name = "gunzipScripts-0.0.1";
//         scriptRequests[2].tagType = 0; // <script>[script]</script>
//         scriptRequests[2].contractAddress = scriptyStorageAddress;

//         scriptRequests[3].name = "cube3D_GZIP";
//         scriptRequests[3].tagType = 0; // <script>[script]</script>
//         scriptRequests[3].contractAddress = scriptyStorageAddress;

//         HeadRequest[] memory headRequests = new HeadRequest[](1);
//         headRequests[0].tagOpen = "<style>";
//         headRequests[0].tagContent = "html{height:100%}body{min-height:100%;margin:0;padding:0}canvas{padding:0;margin:auto;display:block;position:absolute;top:0;bottom:0;left:0;right:0}";
//         headRequests[0].tagClose = "</style>";

//         HTMLRequest memory htmlRequest;
//         htmlRequest.headRequests = headRequests;
//         htmlRequest.scriptRequests = scriptRequests;

//         bytes memory base64EncodedHTMLDataURI = IScriptyBuilderV2(
//             scriptyBuilderAddress
//         ).getEncodedHTML(htmlRequest);

//         bytes memory metadata = abi.encodePacked(
//             '{"name":"Cube 3D - GZIP - Base64", "description":"Assembles GZIP compressed base64 encoded three.js with a demo scene. Metadata and animation URL are both base64 encoded.","animation_url":"',
//             base64EncodedHTMLDataURI,
//             '"}'
//         );

//         return
//             string(
//                 abi.encodePacked(
//                     "data:application/json;base64,",
//                     Base64.encode(metadata)
//                 )
//             );
//     }

//     // for testing only
//     // solc-ignore-next-line func-mutability
//     function tokenURI_ForGasTest() public returns (string memory) {
//         return tokenURI(0);
//     }
// }
