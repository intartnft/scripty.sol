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

contract ScriptyWrappedHTML is ScriptyCore {
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
     * @param requests - Array of WrappedScriptRequests
     * @param bufferSize - Total buffer size of all requested scripts
     * @return Full html wrapped scripts
     */
    function getHTMLWrapped(
        HeadRequest[] calldata headRequests,
        WrappedScriptRequest[] memory requests,
        uint256 bufferSize
    ) public view returns (bytes memory) {
        (
            WrappedScriptRequest[] memory fetchedRequests,
            uint256 totalSize
        ) = fetchWrappedScripts(requests);

        bytes memory htmlFile = DynamicBuffer.allocate(totalSize);

        // <html>
        htmlFile.appendSafe(HTML_OPEN_RAW);

        // <head>
        htmlFile.appendSafe(HEAD_OPEN_RAW);
        if (headRequests.length > 0) {
            htmlFile = _appendHeadRequests(htmlFile, headRequests);
        }
        htmlFile.appendSafe(HEAD_CLOSE_RAW);
        // </head>

        // <body>
        htmlFile.appendSafe(BODY_OPEN_RAW);
        if (requests.length > 0) {
            htmlFile = _appendWrappedBody(htmlFile, fetchedRequests);
        }
        htmlFile.appendSafe(HTML_BODY_CLOSED_RAW);
        // </body>
        // </html>

        return htmlFile;
    }

    /**
     * @notice Append wrapped HTML requests to the buffer
     * @param htmlFile - Final buffer holding all requests
     * @param requests - Array of WrappedScriptRequests
     * @return buffer holding requests
     */
    function _appendWrappedBody(
        bytes memory htmlFile,
        WrappedScriptRequest[] memory requests
    ) internal view returns (bytes memory) {
        bytes memory wrapPrefix;
        bytes memory wrapSuffix;
        WrappedScriptRequest memory request;
        uint256 i;

        unchecked {
            do {
                request = requests[i];
                (wrapPrefix, wrapSuffix) = _wrapPrefixAndSuffixFor(request);
                request.wrapPrefix = wrapPrefix;
                request.wrapSuffix = wrapSuffix;

                htmlFile = _appendWrappedHTMLRequests(htmlFile, request, false);
            } while (++i < requests.length);
        }

        return htmlFile;
    }

    // =============================================================
    //                      ENCODED HTML GETTERS
    // =============================================================

    /**
     * @notice Get {getHTMLWrapped} and base64 encode it
     * @param requests - Array of WrappedScriptRequests
     * @param bufferSize - Total buffer size of all requested scripts
     * @return Full html wrapped scripts, base64 encoded
     */
    function getEncodedHTMLWrapped(
        HeadRequest[] calldata headRequests,
        WrappedScriptRequest[] calldata requests,
        uint256 bufferSize
    ) public view returns (bytes memory) {
        unchecked {
            bytes memory rawHTML = getHTMLWrapped(
                headRequests,
                requests,
                bufferSize
            );

            uint256 sizeForEncoding = _sizeForBase64Encoding(rawHTML.length);
            sizeForEncoding += HTML_BASE64_DATA_URI_BYTES;

            bytes memory htmlFile = DynamicBuffer.allocate(sizeForEncoding);
            htmlFile.appendSafe("data:text/html;base64,");
            htmlFile.appendSafeBase64(rawHTML, false, false);
            return htmlFile;
        }
    }

    // =============================================================
    //                      STRING UTILITIES
    // =============================================================

    /**
     * @notice Convert {getHTMLWrapped} output to a string
     * @param requests - Array of WrappedScriptRequests
     * @param bufferSize - Total buffer size of all requested scripts
     * @return {getHTMLWrapped} as a string
     */
    function getHTMLWrappedString(
        HeadRequest[] calldata headRequests,
        WrappedScriptRequest[] calldata requests,
        uint256 bufferSize
    ) public view returns (string memory) {
        return string(getHTMLWrapped(headRequests, requests, bufferSize));
    }

    /**
     * @notice Convert {getEncodedHTMLWrapped} output to a string
     * @param requests - Array of WrappedScriptRequests
     * @param bufferSize - Total buffer size of all requested scripts
     * @return {getEncodedHTMLWrapped} as a string
     */
    function getEncodedHTMLWrappedString(
        HeadRequest[] calldata headRequests,
        WrappedScriptRequest[] calldata requests,
        uint256 bufferSize
    ) public view returns (string memory) {
        return
            string(getEncodedHTMLWrapped(headRequests, requests, bufferSize));
    }

    // =============================================================
    //                      OFF-CHAIN UTILITIES
    // =============================================================

    /**
     * @notice Get final buffer size for HTML wrapped
     * @param headRequests - Array of head tags
     * @param requests - Array of wrapped script requests
     * @return size - Final buffer size
     */
    function getBufferSizeForHTMLWrapped(
        HeadRequest[] calldata headRequests,
        WrappedScriptRequest[] calldata requests
    ) public view returns (uint256 size) {
        unchecked {
            // <html><head></head><body></body></html>
            size = URLS_RAW_BYTES;

            size += getBufferSizeForHeadTags(headRequests);

            size += getBufferSizeForHTMLWrappedBody(requests);
        }
    }

    /**
     * @notice Get final buffer size for HTML wrapped body
     * @param requests - Array of wrapped script requests
     * @return size - Final buffer size
     */
    function getBufferSizeForHTMLWrappedBody(
        WrappedScriptRequest[] calldata requests
    ) public view returns (uint256 size) {
        uint256 i;
        uint256 length = requests.length;
        WrappedScriptRequest memory request;

        unchecked {
            do {
                request = requests[i];
                size += getWrappedScriptSize(request);
            } while (++i < length);
        }
    }

    /**
     * @notice Get buffer size for a single wrapped request
     * @param request - Wrapped script request
     * @return size - Final buffer size
     */
    function getWrappedScriptSize(
        WrappedScriptRequest memory request
    ) public view returns (uint256 size) {
        unchecked {
            (
                bytes memory wrapPrefix,
                bytes memory wrapSuffix
            ) = _wrapPrefixAndSuffixFor(request);

            uint256 scriptSize = _fetchScript(
                request.name,
                request.contractAddress,
                request.contractData,
                request.scriptContent
            ).length;

            return wrapPrefix.length + wrapSuffix.length + scriptSize;
        }
    }

    /**
     * @notice Get buffer size for encoded HTML wrapped
     * @param headRequests - Array of head tags
     * @param requests - Array of wrapped script requests
     * @return size - Final buffer size
     */
    function getBufferSizeForEncodedHTMLWrapped(
        HeadRequest[] calldata headRequests,
        WrappedScriptRequest[] calldata requests
    ) public view returns (uint256 size) {
        return
            _sizeForBase64Encoding(
                getBufferSizeForHTMLWrapped(headRequests, requests)
            );
    }
}
