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

/**
  @title Generates HTML with single <script> tag after fetching and assembling given script and head requests.
  @author @0xthedude
  @author @xtremetom

  Special thanks to @cxkoda, @frolic and @dhof
*/

import "./../core/ScriptyCore.sol";
import "./../interfaces/IScriptyHTMLSingleScriptTag.sol";

contract ScriptyHTMLSingleScriptTag is
    ScriptyCore,
    IScriptyHTMLSingleScriptTag
{
    using DynamicBuffer for bytes;

    // =============================================================
    //                      RAW HTML GETTERS
    // =============================================================

    /**
     * @notice  Get HTML with requested head tags and scripts housed in
     *          single <script> tag
     * @dev Your HTML is returned in the following format:
     *      <html>
     *          <head>
     *              [tagOpen[0]][tagContent[0]][tagClose[0]]
     *              [tagOpen[1]][tagContent[1]][tagClose[1]]
     *              ...
     *              [tagOpen[n]][tagContent[n]][tagClose[n]]
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
     * @return Full HTML with head and script tags
     */
    function getHTMLSingleScriptTag(
        HTMLRequest memory htmlRequest
    ) public view returns (bytes memory) {
        (, uint256 headBufferSize) = _enrichHTMLTags(
            htmlRequest.headTags,
            true,
            false
        );

        (, uint256 bodyBufferSize) = _enrichHTMLTags(
            htmlRequest.bodyTags,
            false,
            false
        );

        bytes memory htmlFile = DynamicBuffer.allocate(
            _getHTMLSingleScriptTagBufferSize(headBufferSize, bodyBufferSize)
        );

        // <html>
        htmlFile.appendSafe(HTML_OPEN_RAW);

        // <head>
        htmlFile.appendSafe(HEAD_OPEN_RAW);
        if (htmlRequest.headTags.length > 0) {
            _appendHTMLTags(htmlFile, htmlRequest.headTags, true, false);
        }
        htmlFile.appendSafe(HEAD_CLOSE_RAW);
        // </head>

        // <body>
        // <script>
        htmlFile.appendSafe(BODY_OPEN_RAW);
        htmlFile.appendSafe(SCRIPT_OPEN_RAW);
        if (htmlRequest.bodyTags.length > 0) {
            _appendHTMLTags(htmlFile, htmlRequest.bodyTags, false, false);
        }
        htmlFile.appendSafe(SCRIPT_CLOSE_RAW);
        htmlFile.appendSafe(HTML_BODY_CLOSED_RAW);
        // </script>
        // </body>
        // </html>

        return htmlFile;
    }

    /**
     * @notice Calculates the total buffersize for all elements
     * @param headBufferSize - HTMLRequest
     * @param bodyBufferSize - HTMLRequest
     * @return size - Total buffersize of all elements
     */
    function _getHTMLSingleScriptTagBufferSize(
        uint256 headBufferSize,
        uint256 bodyBufferSize
    ) private pure returns (uint256 size) {
        unchecked {
            // <html><head></head><body></body></html>
            // <script></script>
            size = URLS_RAW_BYTES + SCRIPT_INLINE_BYTES;
            size += headBufferSize;
            size += bodyBufferSize;
        }
    }

    // =============================================================
    //                      ENCODED HTML GETTERS
    // =============================================================

    /**
     * @notice Get {getHTMLSingleScriptTag} and base64 encode it
     * @param htmlRequest - HTMLRequest
     * @return Full HTML with head and script tags, base64 encoded
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
