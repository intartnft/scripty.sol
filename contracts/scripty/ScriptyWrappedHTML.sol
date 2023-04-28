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

import "./ScriptyCore.sol";
import "./interfaces/IScriptyWrappedHTML.sol";

contract ScriptyWrappedHTML is ScriptyCore, IScriptyWrappedHTML {
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
     *          <body style='margin:0;'>
     *              [wrapPrefix[0]]{request[0]}[wrapSuffix[0]]
     *              [wrapPrefix[1]]{request[1]}[wrapSuffix[1]]
     *              ...
     *              [wrapPrefix[n]]{request[n]}[wrapSuffix[n]]
     *          </body>
     *      </html>
     * @param htmlRequest - Array of HeadRequests
     * @return Full html wrapped scripts
     */
    function getHTMLWrapped(
        HTMLRequest memory htmlRequest
    ) public view returns (bytes memory) {
        uint256 scriptBufferSize = buildWrappedScriptsAndGetSize(
            htmlRequest.scriptRequests
        );

        bytes memory htmlFile = DynamicBuffer.allocate(
            getHTMLWrappedBufferSize(htmlRequest.headRequests, scriptBufferSize)
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
        htmlFile.appendSafe(BODY_OPEN_RAW);
        if (htmlRequest.scriptRequests.length > 0) {
            _appendScriptRequests(
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

    function buildWrappedScriptsAndGetSize(
        ScriptRequest[] memory requests
    ) public view returns (uint256) {
        if (requests.length == 0) {
            return 0;
        }
        bytes memory wrapPrefix;
        bytes memory wrapSuffix;

        uint256 i;
        uint256 length = requests.length;
        uint256 totalSize;
        unchecked {
            do {
                bytes memory script = _fetchScript(requests[i]);
                requests[i].scriptContent = script;

                (wrapPrefix, wrapSuffix) = _wrapPrefixAndSuffixFor(requests[i]);
                requests[i].wrapPrefix = wrapPrefix;
                requests[i].wrapSuffix = wrapSuffix;

                totalSize += wrapPrefix.length;
                totalSize += script.length;
                totalSize += wrapSuffix.length;
            } while (++i < length);
        }
        return totalSize;
    }

    function getHTMLWrappedBufferSize(
        HeadRequest[] memory headRequests,
        uint256 scriptSize
    ) public pure returns (uint256 size) {
        unchecked {
            // <html><head></head><body></body></html>
            size = URLS_RAW_BYTES;
            size += getBufferSizeForHeadTags(headRequests);
            size += scriptSize;
        }
    }

    // =============================================================
    //                      ENCODED HTML GETTERS
    // =============================================================

    /**
     * @notice Get {getHTMLWrapped} and base64 encode it
     * @param htmlRequest - Array of WrappedScriptRequests
     * @return Full html wrapped scripts, base64 encoded
     */
    function getEncodedHTMLWrapped(
        HTMLRequest memory htmlRequest
    ) public view returns (bytes memory) {
        unchecked {
            bytes memory rawHTML = getHTMLWrapped(htmlRequest);

            uint256 sizeForEncoding = _sizeForBase64Encoding(rawHTML.length);
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
     * @notice Convert {getHTMLWrapped} output to a string
     * @param htmlRequest - Array of WrappedScriptRequests
     * @return {getHTMLWrapped} as a string
     */
    function getHTMLWrappedString(
        HTMLRequest memory htmlRequest
    ) public view returns (string memory) {
        return string(getHTMLWrapped(htmlRequest));
    }

    /**
     * @notice Convert {getEncodedHTMLWrapped} output to a string
     * @param htmlRequest - Array of WrappedScriptRequests
     * @return {getEncodedHTMLWrapped} as a string
     */
    function getEncodedHTMLWrappedString(
        HTMLRequest memory htmlRequest
    ) public view returns (string memory) {
        return string(getEncodedHTMLWrapped(htmlRequest));
    }
}
