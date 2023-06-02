// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

///////////////////////////////////////////////////////////
// ░██████╗░█████╗░██████╗░██╗██████╗░████████╗██╗░░░██╗ //
// ██╔════╝██╔══██╗██╔══██╗██║██╔══██╗╚══██╔══╝╚██╗░██╔╝ //
// ╚█████╗░██║░░╚═╝██████╔╝██║██████╔╝░░░██║░░░░╚████╔╝░ //
// ░╚═══██╗██║░░██╗██╔══██╗██║██╔═══╝░░░░██║░░░░░╚██╔╝░░ //
// ██████╔╝╚█████╔╝██║░░██║██║██║░░░░░░░░██║░░░░░░██║░░░ //
// ╚═════╝░░╚════╝░╚═╝░░╚═╝╚═╝╚═╝░░░░░░░░╚═╝░░░░░░╚═╝░░░ //
///////////////////////////////////////////////////////////
//░░░░░░░░░░░░░    WRAPPED URL SAFE HTML    ░░░░░░░░░░░░░//
///////////////////////////////////////////////////////////
//
// This module is designed to manage an scripts with custom
// script tags:
//
// eg;
//     <html>
//        <head>
//             <title>Hi</title>
//             <style>[css code]</style>
//         </head>
//         <body>
//              [wrapPrefix[0]]{request[0]}[wrapSuffix[0]]
//              [wrapPrefix[1]]{request[1]}[wrapSuffix[1]]
//              ...
//              [wrapPrefix[n]]{request[n]}[wrapSuffix[n]]
//         </body>
//     </html>
//
///////////////////////////////////////////////////////////

import "./ScriptyCore.sol";
import "./interfaces/IScriptyHTMLURLSafe.sol";

contract ScriptyHTMLURLSafe is ScriptyCore, IScriptyHTMLURLSafe {
    using DynamicBuffer for bytes;

    // =============================================================
    //                      RAW HTML GETTERS
    // =============================================================

    /**
     * @notice Get requested scripts housed in URL Safe wrappers
     * @dev Any wrapper type 0 scripts are converted to base64 and wrapped
     *      with <script src="data:text/javascript;base64,[SCRIPT]"></script>
     *
     *      [WARNING]: Large non-base64 libraries that need base64 encoding
     *      carry a high risk of causing a gas out. Highly advised the use
     *      of base64 encoded scripts where possible
     *
     *      Your requested scripts are returned in the following format:
     *      <html>
     *          <head>
     *              [wrapPrefix[0]]{headTagRequest[0]}[wrapSuffix[0]]
     *              [wrapPrefix[1]]{headTagRequest[1]}[wrapSuffix[1]]
     *              ...
     *              [wrapPrefix[n]]{headTagRequest[n]}[wrapSuffix[n]]
     *          </head>
     *          <body>
     *              [wrapPrefix[0]]{request[0]}[wrapSuffix[0]]
     *              [wrapPrefix[1]]{request[1]}[wrapSuffix[1]]
     *              ...
     *              [wrapPrefix[n]]{request[n]}[wrapSuffix[n]]
     *          </body>
     *      </html>
     * @param htmlRequest - HTMLRequest
     * @return Full URL Safe wrapped scripts
     */
    function getHTMLURLSafe(
        HTMLRequest memory htmlRequest
    ) public view returns (bytes memory) {
        (, uint256 scriptBufferSize) = _enrichScriptsForHTMLURLSafe(
            htmlRequest.scriptRequests
        );

        bytes memory htmlFile = DynamicBuffer.allocate(
            _getHTMLURLSafeBufferSize(
                htmlRequest.headRequests,
                scriptBufferSize
            )
        );

        // data:text/html,
        htmlFile.appendSafe(DATA_HTML_URL_SAFE);

        // <html>
        htmlFile.appendSafe(HTML_OPEN_URL_SAFE);

        // <head>
        htmlFile.appendSafe(HEAD_OPEN_URL_SAFE);
        if (htmlRequest.headRequests.length > 0) {
            _appendHeadTags(htmlFile, htmlRequest.headRequests);
        }
        htmlFile.appendSafe(HEAD_CLOSE_URL_SAFE);
        // </head>

        // <body>
        htmlFile.appendSafe(BODY_OPEN_URL_SAFE);
        if (htmlRequest.scriptRequests.length > 0) {
            _appendHTMLURLSafeBody(htmlFile, htmlRequest.scriptRequests);
        }
        htmlFile.appendSafe(HTML_BODY_CLOSED_URL_SAFE);
        // </body>
        // </html>

        return htmlFile;
    }

    /**
     * @notice Adds the required tags and calculates buffer size of requests
     * @dev Effectively two functions bundled into one as this saves gas
     * @param requests - Array of ScriptRequests
     * @return Updated ScriptRequests
     * @return Total buffersize of updated ScriptRequests
     */
    function _enrichScriptsForHTMLURLSafe(
        ScriptRequest[] memory requests
    ) private view returns (ScriptRequest[] memory, uint256) {
        if (requests.length == 0) {
            return (requests, 0);
        }

        bytes memory tagOpen;
        bytes memory tagClose;
        bytes memory script;

        uint256 scriptSize;
        uint256 totalSize;
        uint256 length = requests.length;
        uint256 i;

        unchecked {
            do {
                script = fetchScript(requests[i]);
                requests[i].scriptContent = script;
                scriptSize = script.length;

                // When wrapType = 0, script will be base64 encoded.
                // script size should account that change as well.
                if (requests[i].tagType == 0) {
                    scriptSize = sizeForBase64Encoding(scriptSize);
                }

                (tagOpen, tagClose) = urlSafeScriptTagOpenAndCloseFor(
                    requests[i]
                );
                requests[i].tagOpen = tagOpen;
                requests[i].tagClose = tagClose;

                totalSize += tagOpen.length;
                totalSize += scriptSize;
                totalSize += tagClose.length;
            } while (++i < length);
        }
        return (requests, totalSize);
    }

    /**
     * @notice Calculates the total buffersize for all elements
     * @param headRequests - HeadRequest
     * @return size - Total buffersize of all elements
     */
    function _getHTMLURLSafeBufferSize(
        HeadRequest[] memory headRequests,
        uint256 scriptSize
    ) private pure returns (uint256 size) {
        unchecked {
            // urlencode(<html><head></head><body></body></html>)
            size = URLS_SAFE_BYTES;
            size += _getBufferSizeForHeadTags(headRequests);
            size += scriptSize;
        }
    }

    /**
     * @notice Append URL safe HTML wrapped requests to the buffer
     * @dev If you submit a request that uses wrapType = 0, it will undergo a few changes:
     *
     *      Example request with wrapType of 0:
     *      console.log("Hello World")
     *
     *      1. `urlSafeScriptTagOpenAndCloseFor()` will convert the wrap to the following
     *      - <script>  =>  %253Cscript%2520src%253D%2522data%253Atext%252Fjavascript%253Bbase64%252C
     *      - </script> =>  %2522%253E%253C%252Fscript%253E
     *
     *      2. `_appendScriptTag()` will base64 encode the script to the following
     *      - console.log("Hello World") => Y29uc29sZS5sb2coIkhlbGxvIFdvcmxkIik=
     *
     *      Due to the above, it is highly advised that you do not attempt to use `wrapType = 0` in
     *      conjunction with a large JS script. This contract will try to base64 encode it which could
     *      result in a gas out. Instead use a a base64 encoded version of the script and `wrapType = 1`
     *
     * @param htmlFile - Final buffer holding all requests
     * @param requests - Array of ScriptRequests
     */
    function _appendHTMLURLSafeBody(
        bytes memory htmlFile,
        ScriptRequest[] memory requests
    ) internal pure {
        ScriptRequest memory request;
        uint256 i;
        unchecked {
            do {
                request = requests[i];
                (request.tagType == 0)
                    ? _appendScriptTag(htmlFile, request, true, true)
                    : _appendScriptTag(htmlFile, request, true, false);
            } while (++i < requests.length);
        }
    }

    // =============================================================
    //                      STRING UTILITIES
    // =============================================================

    /**
     * @notice Convert {getHTMLURLSafe} output to a string
     * @param htmlRequest - HTMLRequest
     * @return {getHTMLURLSafe} as a string
     */
    function getHTMLURLSafeString(
        HTMLRequest memory htmlRequest
    ) public view returns (string memory) {
        return string(getHTMLURLSafe(htmlRequest));
    }
}
