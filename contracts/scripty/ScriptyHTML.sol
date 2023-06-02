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
//░░░░░░░░░░░░░░░░░    WRAPPED HTML    ░░░░░░░░░░░░░░░░░░//
///////////////////////////////////////////////////////////
//
// This module is designed to manage arrays of scripts where
// each script might require a custom wrapper:
//
// eg;
//     <html>
//        <head>
//             <title>Hi</title>
//             <style>[css code]</style>
//         </head>
//         <body>
//             <script>[SCRIPT]</script>
//             <script type="text/javascript+gzip" src="data:text/javascript;base64,[SCRIPT]"></script>
//         </body>
//     </html>
//
// [NOTE]
// If this is your first time using Scripty and you have a
// fairly standard JS structure, this is probably the module
// you will be using.
//
///////////////////////////////////////////////////////////

import "./ScriptyCore.sol";
import "./interfaces/IScriptyHTML.sol";

contract ScriptyHTML is ScriptyCore, IScriptyHTML {
    using DynamicBuffer for bytes;

    // =============================================================
    //                      RAW HTML GETTERS
    // =============================================================

    /**
     * @notice Get requested scripts housed in <body> with custom wrappers
     * @dev Your requested scripts are returned in the following format:
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
     * @return Full html wrapped scripts
     */
    function getHTML(
        HTMLRequest memory htmlRequest
    ) public view returns (bytes memory) {
        (, uint256 scriptBufferSize) = _enrichScripts(
            htmlRequest.scriptRequests
        );

        bytes memory htmlFile = DynamicBuffer.allocate(
            _getHTMLBufferSize(htmlRequest.headRequests, scriptBufferSize)
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
        htmlFile.appendSafe(BODY_OPEN_RAW);
        if (htmlRequest.scriptRequests.length > 0) {
            _appendScriptTags(
                htmlFile,
                htmlRequest.scriptRequests,
                true,
                false
            );
        }
        htmlFile.appendSafe(HTML_BODY_CLOSED_RAW);
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
    function _enrichScripts(
        ScriptRequest[] memory requests
    ) private view returns (ScriptRequest[] memory, uint256) {
        if (requests.length == 0) {
            return (requests, 0);
        }

        bytes memory tagOpen;
        bytes memory tagClose;
        bytes memory script;

        uint256 totalSize;
        uint256 length = requests.length;
        uint256 i;

        unchecked {
            do {
                script = fetchScript(requests[i]);
                requests[i].scriptContent = script;

                (tagOpen, tagClose) = scriptTagOpenAndCloseFor(requests[i]);
                requests[i].tagOpen = tagOpen;
                requests[i].tagClose = tagClose;

                totalSize += tagOpen.length;
                totalSize += script.length;
                totalSize += tagClose.length;
            } while (++i < length);
        }
        return (requests, totalSize);
    }

    /**
     * @notice Calculates the total buffersize for all elements
     * @param headRequests - HTMLRequest
     * @return size - Total buffersize of all elements
     */
    function _getHTMLBufferSize(
        HeadRequest[] memory headRequests,
        uint256 scriptSize
    ) private pure returns (uint256 size) {
        unchecked {
            // <html><head></head><body></body></html>
            size = URLS_RAW_BYTES;
            size += _getBufferSizeForHeadTags(headRequests);
            size += scriptSize;
        }
    }

    // =============================================================
    //                      ENCODED HTML GETTERS
    // =============================================================

    /**
     * @notice Get {getHTML} and base64 encode it
     * @param htmlRequest - HTMLRequest
     * @return Full html wrapped scripts, base64 encoded
     */
    function getEncodedHTML(
        HTMLRequest memory htmlRequest
    ) public view returns (bytes memory) {
        unchecked {
            bytes memory rawHTML = getHTML(htmlRequest);

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
     * @notice Convert {getHTML} output to a string
     * @param htmlRequest - HTMLRequest
     * @return {getHTMLWrapped} as a string
     */
    function getHTMLString(
        HTMLRequest memory htmlRequest
    ) public view returns (string memory) {
        return string(getHTML(htmlRequest));
    }

    /**
     * @notice Convert {getEncodedHTML} output to a string
     * @param htmlRequest - HTMLRequest
     * @return {getEncodedHTML} as a string
     */
    function getEncodedHTMLString(
        HTMLRequest memory htmlRequest
    ) public view returns (string memory) {
        return string(getEncodedHTML(htmlRequest));
    }
}
