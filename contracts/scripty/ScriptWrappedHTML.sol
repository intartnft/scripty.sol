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
        WrappedScriptRequest[] calldata requests,
        uint256 bufferSize
    ) public view returns (bytes memory) {
        uint256 length = requests.length;
        if (length == 0) revert InvalidRequestsLength();

        bytes memory htmlFile = DynamicBuffer.allocate(bufferSize);

        // <html>
        htmlFile.appendSafe(HTML_OPEN_RAW);

        // <body>
        htmlFile.appendSafe(BODY_OPEN_RAW);

        bytes memory wrapPrefix;
        bytes memory wrapSuffix;
        WrappedScriptRequest memory request;
        uint256 i;

        unchecked {
            do {
                request = requests[i];
                (wrapPrefix, wrapSuffix) = _wrapPrefixAndSuffixFor(request);
                htmlFile.appendSafe(wrapPrefix);

                htmlFile.appendSafe(
                    _fetchScript(
                        request.name,
                        request.contractAddress,
                        request.contractData,
                        request.scriptContent
                    )
                );

                htmlFile.appendSafe(wrapSuffix);
            } while (++i < length);
        }

        htmlFile.appendSafe(HTML_BODY_CLOSED_RAW);
        // </body>
        // </html>

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
        WrappedScriptRequest[] calldata requests,
        uint256 bufferSize
    ) public view returns (bytes memory) {
        unchecked {
            bytes memory rawHTML = getHTMLWrapped(requests, bufferSize);

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
        WrappedScriptRequest[] calldata requests,
        uint256 bufferSize
    ) public view returns (string memory) {
        return string(getHTMLWrapped(requests, bufferSize));
    }

    /**
     * @notice Convert {getEncodedHTMLWrapped} output to a string
     * @param requests - Array of WrappedScriptRequests
     * @param bufferSize - Total buffer size of all requested scripts
     * @return {getEncodedHTMLWrapped} as a string
     */
    function getEncodedHTMLWrappedString(
        WrappedScriptRequest[] calldata requests,
        uint256 bufferSize
    ) public view returns (string memory) {
        return string(getEncodedHTMLWrapped(requests, bufferSize));
    }

    // =============================================================
    //                      OFF-CHAIN UTILITIES
    // =============================================================

    /**
     * @notice Get the buffer size of a single wrapped requested code
     * @param request - WrappedScriptRequest data for code
     * @return Buffer size as an unit256
     */
    function getWrappedScriptSize(WrappedScriptRequest memory request)
        public
        view
        returns (uint256)
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

    /**
     * @notice Get the buffer size of an array of html wrapped, wrapped scripts
     * @param requests - WrappedScriptRequests data for code
     * @return Buffer size as an unit256
     */
    function getBufferSizeForHTMLWrapped(
        WrappedScriptRequest[] calldata requests
    ) public view returns (uint256) {
        uint256 size;
        uint256 i;
        uint256 length = requests.length;
        WrappedScriptRequest memory request;

        unchecked {
            if (length > 0) {
                do {
                    request = requests[i];
                    size += getWrappedScriptSize(request);
                } while (++i < length);
            }
            return size + URLS_RAW_BYTES;
        }
    }

    /**
     * @notice Get the buffer size for encoded HTML inline scripts
     * @param requests - InlineScriptRequests data for code
     * @return Buffer size as an unit256
     */
    function getBufferSizeForEncodedHTMLWrapped(
        WrappedScriptRequest[] calldata requests
    ) public view returns (uint256) {
        unchecked {
            uint256 size = getBufferSizeForHTMLWrapped(requests);
            return HTML_BASE64_DATA_URI_BYTES + _sizeForBase64Encoding(size);
        }
    }
}
