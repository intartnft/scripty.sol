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
//░░░░░░░░░░░░░░░░░░    INLINE HTML    ░░░░░░░░░░░░░░░░░░//
///////////////////////////////////////////////////////////
//
// This module is designed to manage an array of scripts
// that share the same script tags:
//
// eg;
//     <html>
//        <head>
//             <title>Hi</title>
//             <style>[css code]</style>
//         </head>
//         <body>
//             <script>
//                  [SCRIPT_1]
//                  [SCRIPT_2]
//                  [SCRIPT_3]
//             </script>
//         </body>
//     </html>
//
///////////////////////////////////////////////////////////

import "./ScriptyCore.sol";
import "./interfaces/IScriptyHTMLSingleScriptTag.sol";

contract ScriptyHTMLSingleScriptTag is ScriptyCore, IScriptyHTMLSingleScriptTag {
    using DynamicBuffer for bytes;

    // =============================================================
    //                      RAW HTML GETTERS
    // =============================================================

    /**
     * @notice Get requested scripts housed in <body> all wrapped in <script></script>
     * @dev Your requested scripts are returned in the following format:
     *      <html>
     *          <head>
     *              [wrapPrefix[0]]{headTagRequest[0]}[wrapSuffix[0]]
     *              [wrapPrefix[1]]{headTagRequest[1]}[wrapSuffix[1]]
     *              ...
     *              [wrapPrefix[n]]{headTagRequest[n]}[wrapSuffix[n]]
     *          </head>
     *          <body>
     *              <script>
     *                  {request[0]}
     *                  {request[1]}
     *                  ...
     *                  {request[n]}
     *              </script>
     *          </body>
     *      </html>
     * @param htmlRequest - HTMLRequest
     * @return Full html wrapped scripts
     */
    function getHTMLSingleScriptTag(
        HTMLRequest memory htmlRequest
    ) public view returns (bytes memory) {
        (, uint256 scriptBufferSize) = _enrichScriptsForHTMLSingleScriptTag(
            htmlRequest.scriptRequests
        );

        bytes memory htmlFile = DynamicBuffer.allocate(
            _getHTMLSingleScriptTagBufferSize(htmlRequest.headRequests, scriptBufferSize)
        );

        // <html>
        htmlFile.appendSafe(HTML_OPEN_RAW);

        // <head>
        htmlFile.appendSafe(HEAD_OPEN_RAW);
        if (htmlRequest.headRequests.length > 0) {
            _appendHeadTags(htmlFile, htmlRequest.headRequests);
        }
        htmlFile.appendSafe(HEAD_CLOSE_RAW);
        // </head>

        // <body>
        // <script>
        htmlFile.appendSafe(BODY_OPEN_RAW);
        htmlFile.appendSafe(SCRIPT_OPEN_RAW);
        if (htmlRequest.scriptRequests.length > 0) {
            _appendScriptTags(
                htmlFile,
                htmlRequest.scriptRequests,
                false,
                false
            );
        }
        htmlFile.appendSafe(SCRIPT_CLOSE_RAW);
        htmlFile.appendSafe(HTML_BODY_CLOSED_RAW);
        // </script>
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
    function _enrichScriptsForHTMLSingleScriptTag(
        ScriptRequest[] memory requests
    ) private view returns (ScriptRequest[] memory, uint256) {
        if (requests.length == 0) {
            return (requests, 0);
        }

        bytes memory script;

        uint256 totalSize;
        uint256 length = requests.length;
        uint256 i;

        unchecked {
            do {
                script = fetchScript(requests[i]);
                requests[i].scriptContent = script;

                totalSize += script.length;
            } while (++i < length);
        }
        return (requests, totalSize);
    }

    /**
     * @notice Calculates the total buffersize for all elements
     * @param headRequests - HeadRequest
     * @return size - Total buffersize of all elements
     */
    function _getHTMLSingleScriptTagBufferSize(
        HeadRequest[] memory headRequests,
        uint256 scriptSize
    ) private pure returns (uint256 size) {
        unchecked {
            // <html><head></head><body></body></html>
            // <script></script>
            size = URLS_RAW_BYTES + SCRIPT_INLINE_BYTES;
            size += _getBufferSizeForHeadTags(headRequests);
            size += scriptSize;
        }
    }

    // =============================================================
    //                      ENCODED HTML GETTERS
    // =============================================================

    /**
     * @notice Get {getHTMLSingleScriptTag} and base64 encode it
     * @param htmlRequest - HTMLRequest
     * @return Full html wrapped scripts, base64 encoded
     */
    function getEncodedHTMLSingleScriptTag(
        HTMLRequest memory htmlRequest
    ) public view returns (bytes memory) {
        unchecked {
            bytes memory rawHTML = getHTMLSingleScriptTag(htmlRequest);

            uint256 sizeForEncoding = sizeForBase64Encoding(rawHTML.length);
            sizeForEncoding += HTML_BASE64_DATA_URI_BYTES;

            bytes memory htmlFile = DynamicBuffer.allocate(sizeForEncoding);
            htmlFile.appendSafe(DATA_HTML_BASE64_URI_RAW);
            htmlFile.appendSafeBase64(rawHTML, false, false);

            return htmlFile;
        }
    }

    // =============================================================
    //                      STRING UTILITIES
    // =============================================================

    /**
     * @notice Convert {getHTMLSingleScriptTag} output to a string
     * @param htmlRequest - HTMLRequest
     * @return {getHTMLSingleScriptTag} as a string
     */
    function getHTMLSingleScriptTagString(
        HTMLRequest memory htmlRequest
    ) public view returns (string memory) {
        return string(getHTMLSingleScriptTag(htmlRequest));
    }

    /**
     * @notice Convert {getEncodedHTMLSingleScriptTag} output to a string
     * @param htmlRequest - HTMLRequest
     * @return {getEncodedHTMLSingleScriptTag} as a string
     */
    function getEncodedHTMLSingleScriptTagString(
        HTMLRequest memory htmlRequest
    ) public view returns (string memory) {
        return string(getEncodedHTMLSingleScriptTag(htmlRequest));
    }
}
