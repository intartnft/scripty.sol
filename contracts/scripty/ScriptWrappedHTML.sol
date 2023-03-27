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

contract ScriptWrappedHTML is ScriptyCore {

    using DynamicBuffer for bytes;

    // =============================================================
    //                      RAW HTML GETTERS
    // =============================================================

    /**
     * @notice Get requested scripts housed in <body> with custom wrappers
     * @dev Your requested scripts are returned in the following format:
     *      <html>
     *          <head></head>
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
        WrappedScriptRequest[] calldata requests,
        uint256 bufferSize
    ) public view returns (bytes memory) {
        uint256 headLength = headRequests.length;
        uint256 length = requests.length;
        if (length == 0 && headLength == 0) revert InvalidRequestsLength();

        bytes memory htmlFile = DynamicBuffer.allocate(bufferSize);

        // <html>
        htmlFile.appendSafe(HTML_OPEN_RAW);

        // <head>
        if (headRequests.length > 0) {
            htmlFile = _appendHeadRequests(htmlFile, headRequests);
        }
        // </head>

        // <body>
        if (length > 0) {
            htmlFile = _appendWrappedBody(htmlFile, requests);
        }
        // </body>
        // </html>

        return htmlFile;
    }

    function _appendWrappedBody(
        bytes memory htmlFile,
        WrappedScriptRequest[] calldata requests
    ) internal view returns(bytes memory) {
        bytes memory wrapPrefix;
        bytes memory wrapSuffix;
        WrappedScriptRequest memory request;
        uint256 i;

        htmlFile.appendSafe(BODY_OPEN_RAW);
        unchecked {
            do {
                request = requests[i];
                (wrapPrefix, wrapSuffix) = _wrapPrefixAndSuffixFor(request);
                request.wrapPrefix = wrapPrefix;
                request.wrapSuffix = wrapSuffix;

                htmlFile = _appendWrappedHTMLRequests(htmlFile, request, false);
            } while (++i < requests.length);
        }
        htmlFile.appendSafe(HTML_BODY_CLOSED_RAW);

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
            bytes memory rawHTML = getHTMLWrapped(headRequests, requests, bufferSize);

            uint256 sizeForEncoding = HTML_BASE64_DATA_URI_BYTES +
            _sizeForBase64Encoding(rawHTML.length);

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
        return string(getEncodedHTMLWrapped(headRequests, requests, bufferSize));
    }

    // =============================================================
    //                      OFF-CHAIN UTILITIES
    // =============================================================

    function getBufferSizeForHTMLWrapped(
        HeadRequest[] calldata headRequests,
        WrappedScriptRequest[] calldata requests
    ) public view returns (uint256 size) {
        unchecked {
            // <html></html>
            size = HTML_RAW_BYTES;

            // get size for head
            // <head>[tags]</head>
            size += getBufferSizeForHeadTags(headRequests);

            // get size for body
            // <body>[scripts]</body>
            size += getBufferSizeForHTMLWrappedBody(requests);
        }
    }

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

            // <body></body>
            size += BODY_RAW_BYTES;
        }
    }

    function getWrappedScriptSize(WrappedScriptRequest memory request)
        public
        view
        returns (uint256 size)
    {
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

    function getBufferSizeForEncodedHTMLWrapped(
        HeadRequest[] calldata headRequests,
        WrappedScriptRequest[] calldata requests
    ) public view returns (uint256 size) {
        return _sizeForBase64Encoding(
            getBufferSizeForHTMLWrapped(headRequests, requests)
        );
    }
}
