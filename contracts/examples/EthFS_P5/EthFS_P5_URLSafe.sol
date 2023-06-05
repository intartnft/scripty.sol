// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.17;

// import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
// import "solady/src/utils/Base64.sol";

// import {
//     IScriptyBuilderV2, 
//     HTMLRequest, 
//     HeadRequest, 
//     ScriptRequest
// } from "../../scripty/interfaces/IScriptyBuilderV2.sol";

// contract EthFS_P5_URLSafe is ERC721 {
//     address public immutable ethfsFileStorageAddress;
//     address public immutable scriptyStorageAddress;
//     address public immutable scriptyBuilderAddress;

//     constructor(
//         address _ethfsFileStorageAddress,
//         address _scriptyStorageAddress,
//         address _scriptyBuilderAddress
//     ) ERC721("example", "EXP") {
//         ethfsFileStorageAddress = _ethfsFileStorageAddress;
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

//         scriptRequests[1].name = "p5-v1.5.0.min.js.gz";
//         scriptRequests[1].tagType = 2; // <script type="text/javascript+gzip" src="data:text/javascript;base64,[script]"></script>
//         scriptRequests[1].contractAddress = ethfsFileStorageAddress;

//         scriptRequests[2].name = "gunzipScripts-0.0.1.js";
//         scriptRequests[2].tagType = 1; // <script src="data:text/javascript;base64,[script]"></script>
//         scriptRequests[2].contractAddress = ethfsFileStorageAddress;

//         scriptRequests[3].name = "pointsAndLines";
//         scriptRequests[3].tagType = 0; // <script>[script]</script>
//         scriptRequests[3].contractAddress = scriptyStorageAddress;

//         // double encoded:
//         // <script>
//         //     html{height:100%}body{min-height:100%;margin:0;padding:0}canvas{padding:0;margin:auto;display:block;position:absolute;top:0;bottom:0;left:0;right:0}
//         // </script>
//         HeadRequest[] memory headRequests = new HeadRequest[](1);
//         headRequests[0].tagOpen = "%253Cstyle%253E";
//         headRequests[0].tagContent = "html%257Bheight%253A100%2525%257Dbody%257Bmin-height%253A100%2525%253Bmargin%253A0%253Bpadding%253A0%257Dcanvas%257Bpadding%253A0%253Bmargin%253Aauto%253Bdisplay%253Ablock%253Bposition%253Aabsolute%253Btop%253A0%253Bbottom%253A0%253Bleft%253A0%253Bright%253A0%257D";
//         headRequests[0].tagClose = "%253C%252Fstyle%253E";

//         HTMLRequest memory htmlRequest;
//         htmlRequest.headRequests = headRequests;
//         htmlRequest.scriptRequests = scriptRequests;

//         bytes memory doubleURLEncodedHTMLDataURI = IScriptyBuilderV2(
//             scriptyBuilderAddress
//         ).getHTMLURLSafe(htmlRequest);

//         return
//             string(
//                 abi.encodePacked(
//                     "data:application/json,",
//                     // url encoded once
//                     // {"name":"p5.js Example - GZIP - Base64 - URL Safe", "description":"Assembles GZIP compressed base64 encoded p5.js that's stored in ethfs's FileStore contract with a demo scene. Metadata and animation URL are both URL encoded.","animation_url":"
//                     "%7B%22name%22%3A%22p5.js%20Example%20-%20GZIP%20-%20Base64%20-%20URL%20Safe%22%2C%20%22description%22%3A%22Assembles%20GZIP%20compressed%20base64%20encoded%20p5.js%20that%27s%20stored%20in%20ethfs%27s%20FileStore%20contract%20with%20a%20demo%20scene.%20Metadata%20and%20animation%20URL%20are%20both%20URL%20encoded.%22%2C%22animation_url%22%3A%22",
//                     doubleURLEncodedHTMLDataURI,
//                     // url encoded once
//                     // "}
//                     "%22%7D"
//                 )
//             );
//     }
// }
