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

contract ScriptyInlineHTML is ScriptyCore {
    using DynamicBuffer for bytes;
    // =============================================================
    //                      RAW HTML GETTERS
    // =============================================================

    /**
     * @notice Get requested scripts housed in <body> all wrapped in <script></script>
     * @dev Your requested scripts are returned in the following format:
     *      <html>
     *          <head></head>
     *          <body>
     *              <script>
     *                  {request[0]}
     *                  {request[1]}
     *                  ...
     *                  {request[n]}
     *              </script>
     *          </body>
     *      </html>
     * @param requests - Array of InlineScriptRequest
     * @param bufferSize - Total buffer size of all requested scripts
     * @return Full html wrapped scripts
     */
    function getHTMLInline(
        InlineScriptRequest[] calldata requests,
        uint256 bufferSize
    ) public view returns (bytes memory) {
        uint256 length = requests.length;
        if (length == 0) revert InvalidRequestsLength();

        bytes memory htmlFile = DynamicBuffer.allocate(bufferSize);

        // <html>
        htmlFile.appendSafe(HTML_OPEN_RAW);

        // <body>
        htmlFile.appendSafe(BODY_OPEN_RAW);

        // <script>
        htmlFile.appendSafe(SCRIPT_OPEN_RAW);

        InlineScriptRequest memory request;
        uint256 i;

        unchecked {
            do {
                request = requests[i];
                htmlFile.appendSafe(
                    _fetchScript(
                        request.name,
                        request.contractAddress,
                        request.contractData,
                        request.scriptContent
                    )
                );
            } while (++i < length);
        }

        htmlFile.appendSafe(SCRIPT_CLOSE_RAW);
        // </script>

        htmlFile.appendSafe(HTML_BODY_CLOSED_RAW);
        // </body>
        // </html>

        return htmlFile;
    }

    // =============================================================
    //                      ENCODED HTML GETTERS
    // =============================================================

    /**
     * @notice Get {getHTMLInline} and base64 encode it
     * @param requests - Array of InlineScriptRequests
     * @param bufferSize - Total buffer size of all requested scripts
     * @return Full html wrapped scripts, base64 encoded
     */
    function getEncodedHTMLInline(
        InlineScriptRequest[] calldata requests,
        uint256 bufferSize
    ) public view returns (bytes memory) {
        unchecked {
            bytes memory rawHTML = getHTMLInline(requests, bufferSize);

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
     * @notice Convert {getHTMLInline} output to a string
     * @param requests - Array of InlineScriptRequests
     * @param bufferSize - Total buffer size of all requested scripts
     * @return {getHTMLInline} as a string
     */
    function getHTMLInlineString(
        InlineScriptRequest[] calldata requests,
        uint256 bufferSize
    ) public view returns (string memory) {
        return string(getHTMLInline(requests, bufferSize));
    }

    /**
     * @notice Convert {getEncodedHTMLInline} output to a string
     * @param requests - Array of InlineScriptRequests
     * @param bufferSize - Total buffer size of all requested scripts
     * @return {getEncodedHTMLInline} as a string
     */
    function getEncodedHTMLInlineString(
        InlineScriptRequest[] calldata requests,
        uint256 bufferSize
    ) public view returns (string memory) {
        return string(getEncodedHTMLInline(requests, bufferSize));
    }

    // =============================================================
    //                      OFF-CHAIN UTILITIES
    // =============================================================

    /**
     * @notice Get the buffer size of a single inline requested code
     * @param request - InlineScriptRequest data for code
     * @return Buffer size as an unit256
     */
    function getInlineScriptSize(InlineScriptRequest memory request)
        public
        view
        returns (uint256)
    {
        return
        _fetchScript(
            request.name,
            request.contractAddress,
            request.contractData,
            request.scriptContent
        ).length;
    }

    /**
     * @notice Get the buffer size of an array of html wrapped inline scripts
     * @param requests - InlineScriptRequests data for code
     * @return Buffer size as an unit256
     */
    function getBufferSizeForHTMLInline(InlineScriptRequest[] calldata requests)
        public
        view
        returns (uint256)
    {
        uint256 size;
        uint256 i;
        uint256 length = requests.length;
        InlineScriptRequest memory request;

        unchecked {
            if (length > 0) {
                do {
                    request = requests[i];
                    size += getInlineScriptSize(request);
                } while (++i < length);
            }
            return size + URLS_RAW_BYTES + SCRIPT_INLINE_BYTES;
        }
    }

    /**
     * @notice Get the buffer size for encoded HTML inline scripts
     * @param requests - InlineScriptRequests data for code
     * @return Buffer size as an unit256
     */
    function getBufferSizeForEncodedHTMLInline(
        InlineScriptRequest[] calldata requests
    ) public view returns (uint256) {
        unchecked {
            uint256 size = getBufferSizeForHTMLInline(requests);
            return HTML_BASE64_DATA_URI_BYTES + _sizeForBase64Encoding(size);
        }
    }
}
