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

import "./../core/ScriptyCore.sol";
import "./../interfaces/IScriptyHTMLSingleScriptTag.sol";

/**
  @title Generates HTML with single <script> tag after fetching and assembling given script and head requests.
  @author @0xthedude
  @author @xtremetom
*/

contract ScriptyHTMLSingleScriptTag is ScriptyCore, IScriptyHTMLSingleScriptTag {
    using DynamicBuffer for bytes;

    // =============================================================
    //                      RAW HTML GETTERS
    // =============================================================

    /**
     * @notice  Get HTML with requested head tags and scripts housed in 
     *          single <script> tag
     * @dev Your requested scripts are returned in the following format:
     *      <html>
     *          <head>
     *              [tagOpen[0]][tagContent[0]][tagClose[0]]
     *              [tagOpen[1]][tagContent[1]][tagClose[1]]
     *              ...
     *              [tagOpen[n]][tagContent[n]][tagClose[n]]
     *          </head>
     *          <body>
     *              [tagOpen[0]]{request[0]}[tagClose[0]]
     *              [tagOpen[1]]{request[1]}[tagClose[1]]
     *              ...
     *              [tagOpen[n]]{request[n]}[tagClose[n]]
     *          </body>
     *      </html>
     * @param htmlRequest - A struct that contains head and script requests
     * @return Full html with head and single script tag
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
    /* @dev Fetches the script and calculates final buffer 
     *      size of all scripts and their tags.
     * @param requests - Array of ScriptRequest
     * @return Enriched script requests and the final buffer size
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
    /* @notice Calculates the final buffer size of HTML
     * @param headRequests - Array of HeadRequest
     * @param scriptSize - Buffer size of all scripts and their tags
     * @return size - Final buffer size of HTML
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
     * @param htmlRequest - A struct that contains head and script requests
     * @return Full html with head and single script tag, base64 encoded
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
     * @param htmlRequest - A struct that contains head and script requests
     * @return {getHTMLSingleScriptTag} as a string
     */
    function getHTMLSingleScriptTagString(
        HTMLRequest memory htmlRequest
    ) public view returns (string memory) {
        return string(getHTMLSingleScriptTag(htmlRequest));
    }

    /**
     * @notice Convert {getEncodedHTMLSingleScriptTag} output to a string
     * @param htmlRequest - A struct that contains head and script requests
     * @return {getEncodedHTMLSingleScriptTag} as a string
     */
    function getEncodedHTMLSingleScriptTagString(
        HTMLRequest memory htmlRequest
    ) public view returns (string memory) {
        return string(getEncodedHTMLSingleScriptTag(htmlRequest));
    }
}
