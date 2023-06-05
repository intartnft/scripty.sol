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

/**
  @title Generates HTML with multiple <script> tags after fetching and assembling given script and head requests.
  @author @0xthedude
  @author @xtremetom

  Special thanks to @cxkoda, @frolic and @dhof
*/

import "./../core/ScriptyCore.sol";
import "./../interfaces/IScriptyHTML.sol";

contract ScriptyHTML is ScriptyCore, IScriptyHTML {
    using DynamicBuffer for bytes;

    // =============================================================
    //                      RAW HTML GETTERS
    // =============================================================

    /**
     * @notice  Get HTML with requested head tags and scripts housed in
     *          multiple <script> tags
     * @dev @dev Your HTML is returned in the following format:
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
     * @param htmlRequest - HTMLRequest
     * @return Full HTML with head and script tags
     */
    function getHTML(
        HTMLRequest memory htmlRequest
    ) public view returns (bytes memory) {
        (, uint256 headBufferSize) = _enrichHTMLTags(htmlRequest.headTags, true, false);

        (, uint256 bodyBufferSize) = _enrichHTMLTags(htmlRequest.bodyTags, true, false);

        bytes memory htmlFile = DynamicBuffer.allocate(
            _getHTMLBufferSize(headBufferSize, bodyBufferSize)
        );

        // <html>
        htmlFile.appendSafe(HTML_OPEN_RAW);

        // <head>
        htmlFile.appendSafe(HEAD_OPEN_RAW);
        if (htmlRequest.headTags.length > 0) {
            _appendHTMLTags(
                htmlFile, 
                htmlRequest.headTags, 
                true, 
                false
            );
        }
        htmlFile.appendSafe(HEAD_CLOSE_RAW);
        // </head>

        // <body>
        htmlFile.appendSafe(BODY_OPEN_RAW);
        if (htmlRequest.bodyTags.length > 0) {
            _appendHTMLTags(
                htmlFile,
                htmlRequest.bodyTags,
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
     * @notice Calculates the total buffersize for all elements
     * @param headBufferSize - HTMLRequest
     * @param bodyBufferSize - HTMLRequest
     * @return size - Total buffersize of all elements
     */
    function _getHTMLBufferSize(
        uint256 headBufferSize,
        uint256 bodyBufferSize
    ) private pure returns (uint256 size) {
        unchecked {
            // <html><head></head><body></body></html>
            size = URLS_RAW_BYTES;
            size += headBufferSize;
            size += bodyBufferSize;
        }
    }

    // =============================================================
    //                      ENCODED HTML GETTERS
    // =============================================================

    /**
     * @notice Get {getHTML} and base64 encode it
     * @param htmlRequest - HTMLRequest
     * @return Full HTML with head and script tags, base64 encoded
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
