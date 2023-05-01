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

import "./ScriptyCore.sol";
import "./interfaces/IScriptyInlineHTML.sol";

contract ScriptyInlineHTML is ScriptyCore, IScriptyInlineHTML {
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
     * @param htmlRequest - Array of InlineScriptRequest
     * @return Full html wrapped scripts
     */
    function getHTMLInline(
        HTMLRequest memory htmlRequest
    ) public view returns (bytes memory) {
        (, uint256 scriptBufferSize) = buildInlineScriptsAndGetSize(
            htmlRequest.scriptRequests
        );

        bytes memory htmlFile = DynamicBuffer.allocate(
            getHTMLInlineBufferSize(htmlRequest.headRequests, scriptBufferSize)
        );

        // <html>
        htmlFile.appendSafe(HTML_OPEN_RAW);

        // <head>
        htmlFile.appendSafe(HEAD_OPEN_RAW);
        if (htmlRequest.headRequests.length > 0) {
            _appendHeadRequests(htmlFile, htmlRequest.headRequests);
        }
        htmlFile.appendSafe(HEAD_CLOSE_RAW);
        // </head>

        // <body>
        // <script>
        htmlFile.appendSafe(BODY_OPEN_RAW);
        htmlFile.appendSafe(SCRIPT_OPEN_RAW);
        if (htmlRequest.scriptRequests.length > 0) {
            _appendScriptRequests(
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

    function getHTMLInlineBufferSize(
        HeadRequest[] memory headRequests,
        uint256 scriptSize
    ) public pure returns (uint256 size) {
        unchecked {
            // <html><head></head><body></body></html>
            // <script></script>
            size = URLS_RAW_BYTES + SCRIPT_INLINE_BYTES;
            size += getBufferSizeForHeadTags(headRequests);
            size += scriptSize;
        }
    }

    // =============================================================
    //                      ENCODED HTML GETTERS
    // =============================================================

    /**
     * @notice Get {getHTMLInline} and base64 encode it
     * @param htmlRequest - Array of InlineScriptRequests
     * @return Full html wrapped scripts, base64 encoded
     */
    function getEncodedHTMLInline(
        HTMLRequest memory htmlRequest
    ) public view returns (bytes memory) {
        unchecked {
            bytes memory rawHTML = getHTMLInline(htmlRequest);

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
     * @notice Convert {getHTMLInline} output to a string
     * @param htmlRequest - Array of InlineScriptRequests
     * @return {getHTMLInline} as a string
     */
    function getHTMLInlineString(
        HTMLRequest memory htmlRequest
    ) public view returns (string memory) {
        return string(getHTMLInline(htmlRequest));
    }

    /**
     * @notice Convert {getEncodedHTMLInline} output to a string
     * @param htmlRequest - Array of InlineScriptRequests
     * @return {getEncodedHTMLInline} as a string
     */
    function getEncodedHTMLInlineString(
        HTMLRequest memory htmlRequest
    ) public view returns (string memory) {
        return string(getEncodedHTMLInline(htmlRequest));
    }
}
