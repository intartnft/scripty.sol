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
//░░░░░░░░░░░░░    WRAPPED URL SAFE HTML    ░░░░░░░░░░░░░//
///////////////////////////////////////////////////////////

import "./ScriptyCore.sol";

contract ScriptyWrappedURLSafe is ScriptyCore {

    using DynamicBuffer for bytes;

    // =============================================================
    //                      RAW HTML GETTERS
    // =============================================================

    /**
     * @notice Get requested scripts housed in URL Safe wrappers
     * @dev Any wrapper type 0 scripts are converted to base64 and wrapped
     *      with <script src="data:text/javascript;base64,[SCRIPT]"></script>
     *
     *      [WARNING]: Large non-base64 libraries that need base64 encoding
     *      carry a high risk of causing a gas out. Highly advised the use
     *      of base64 encoded scripts where possible
     *
     *      Your requested scripts are returned in the following format:
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
     * @return Full URL Safe wrapped scripts
     */
    function getHTMLWrappedURLSafe(
        HeadRequest[] calldata headRequests,
        WrappedScriptRequest[] calldata requests,
        uint256 bufferSize
    ) public view returns (bytes memory) {

        bytes memory htmlFile = DynamicBuffer.allocate(bufferSize);

        // <html>
        htmlFile.appendSafe(HTML_OPEN_URL_SAFE);

        // <head>
        htmlFile.appendSafe(HEAD_OPEN_URL_SAFE);
        if (headRequests.length > 0) {
            htmlFile = _appendHeadRequests(htmlFile, headRequests);
        }
        htmlFile.appendSafe(HEAD_CLOSE_URL_SAFE);
        // </head>

        // <body>
        htmlFile.appendSafe(BODY_OPEN_URL_SAFE);
        if (requests.length > 0) {
            htmlFile = _appendHTMLWrappedURLSafeBody(htmlFile, requests);
        }
        htmlFile.appendSafe(HTML_BODY_CLOSED_URL_SAFE);
        // </body>
        // </html>

        return htmlFile;
    }

    function getHTMLWrappedURLSafe2(
        HeadRequest[] calldata headRequests,
        WrappedScriptRequest[] calldata requests
    ) public view returns (bytes memory) {
        uint256 bufferSize = getBufferSizeForHTMLWrappedURLSafe(headRequests, requests);
        return getHTMLWrappedURLSafe(headRequests, requests, bufferSize);
    }

    /**
     * @notice Append URL safe HTML wrapped requests to the buffer
     * @dev If you submit a request that uses wrapType = 0, it will undergo a few changes:
     *
     *      Example request with wrapType of 0:
     *      console.log("Hello World")
     *
     *      1. `_wrapURLSafePrefixAndSuffixFor()` will convert the wrap to the following
     *      - <script>  =>  %253Cscript%2520src%253D%2522data%253Atext%252Fjavascript%253Bbase64%252C
     *      - </script> =>  %2522%253E%253C%252Fscript%253E
     *
     *      2. `_appendWrappedHTMLRequests()` will base64 encode the script to the following
     *      - console.log("Hello World") => Y29uc29sZS5sb2coIkhlbGxvIFdvcmxkIik=
     *
     *      Due to the above, it is highly advised that you do not attempt to use `wrapType = 0` in
     *      conjunction with a large JS script. This contract will try to base64 encode it which could
     *      result in a gas out. Instead use a a base64 encoded version of the script and `wrapType = 1`
     *
     * @param htmlFile - Final buffer holding all requests
     * @param requests - Array of WrappedScriptRequests
     * @return buffer holding requests
     */
    function _appendHTMLWrappedURLSafeBody (
        bytes memory htmlFile,
        WrappedScriptRequest[] calldata requests
    ) internal view returns(bytes memory) {
        bytes memory wrapPrefix;
        bytes memory wrapSuffix;
        WrappedScriptRequest memory request;
        uint256 i;

        unchecked {
            do {
                request = requests[i];
                (wrapPrefix, wrapSuffix) = _wrapURLSafePrefixAndSuffixFor(
                    request
                );
                request.wrapPrefix = wrapPrefix;
                request.wrapSuffix = wrapSuffix;

                (request.wrapType == 0)
                ? htmlFile = _appendWrappedHTMLRequests(htmlFile, request, true)
                : htmlFile = _appendWrappedHTMLRequests(htmlFile, request, false);

            } while (++i < requests.length);
        }

        return htmlFile;
    }

    // =============================================================
    //                      STRING UTILITIES
    // =============================================================

    /**
     * @notice Convert {getHTMLWrappedURLSafe} output to a string
     * @param requests - Array of WrappedScriptRequests
     * @param bufferSize - Total buffer size of all requested scripts
     * @return {getHTMLWrappedURLSafe} as a string
     */
    function getHTMLWrappedURLSafeString(
        HeadRequest[] calldata headRequests,
        WrappedScriptRequest[] calldata requests,
        uint256 bufferSize
    ) public view returns (string memory) {
        return string(getHTMLWrappedURLSafe(headRequests, requests, bufferSize));
    }

    // =============================================================
    //                      OFF-CHAIN UTILITIES
    // =============================================================

    /**
     * @notice Get final buffer size for URL safe HTML wrapped
     * @param headRequests - Array of head tags
     * @param requests - Array of wrapped script requests
     * @return size - Final buffer size
     */
    function getBufferSizeForHTMLWrappedURLSafe(
        HeadRequest[] calldata headRequests,
        WrappedScriptRequest[] calldata requests
    ) public view returns (uint256 size) {
        unchecked {
            // urlencode(<html><head></head><body></body></html>)
            size = URLS_SAFE_BYTES;

            size += getBufferSizeForHeadTags(headRequests);

            size += getBufferSizeForHTMLWrappedURLSafeBody(requests);
        }
    }

    /**
     * @notice Get final buffer size for URL safe HTML wrapped body
     * @param requests - Array of wrapped script requests
     * @return size - Final buffer size
     */
    function getBufferSizeForHTMLWrappedURLSafeBody(
        WrappedScriptRequest[] calldata requests
    ) public view returns (uint256 size) {
        uint256 i;
        uint256 length = requests.length;
        WrappedScriptRequest memory request;

        unchecked {
            do {
                request = requests[i];
                size += getHTMLWrappedURLSafeScriptSize(request);
            } while (++i < length);
        }
    }

    /**
     * @notice Get the buffer size of a single wrapped requested code
     * @dev If the script is of wrapper type 0, we get buffer size for
     *      base64 encoded version.
     * @param request - WrappedScriptRequest data for code
     * @return Buffer size as an unit256
     */
    function getHTMLWrappedURLSafeScriptSize(
        WrappedScriptRequest memory request
    ) public view returns (uint256) {
        unchecked {
            (
                bytes memory wrapPrefix,
                bytes memory wrapSuffix
            ) = _wrapURLSafePrefixAndSuffixFor(request);

            uint256 scriptSize = _fetchScript(
                request.name,
                request.contractAddress,
                request.contractData,
                request.scriptContent
            ).length;

            if (request.wrapType == 0) {
                scriptSize = _sizeForBase64Encoding(scriptSize);
            }

            return wrapPrefix.length + wrapSuffix.length + scriptSize;
        }
    }
}
