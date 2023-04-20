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
     * @param scriptRequests - Array of WrappedScriptRequests
     * @return Full URL Safe wrapped scripts
     */
    function getHTMLWrappedURLSafe(
        HeadRequest[] calldata headRequests,
        ScriptRequest[] memory scriptRequests
    ) public view returns (bytes memory) {
        uint256 scriptBufferSize = buildWrappedScriptsAndGetSize(
            scriptRequests
        );

        bytes memory htmlFile = DynamicBuffer.allocate(
            getHTMLWrappedURLSafeBufferSize(headRequests, scriptBufferSize)
        );

        // <html>
        htmlFile.appendSafe(HTML_OPEN_URL_SAFE);

        // <head>
        htmlFile.appendSafe(HEAD_OPEN_URL_SAFE);
        if (headRequests.length > 0) {
            _appendHeadRequests(htmlFile, headRequests);
        }
        htmlFile.appendSafe(HEAD_CLOSE_URL_SAFE);
        // </head>

        // <body>
        htmlFile.appendSafe(BODY_OPEN_URL_SAFE);
        if (scriptRequests.length > 0) {
            _appendHTMLWrappedURLSafeBody(htmlFile, scriptRequests);
        }
        htmlFile.appendSafe(HTML_BODY_CLOSED_URL_SAFE);
        // </body>
        // </html>

        return htmlFile;
    }

    function getHTMLWrappedURLSafeBufferSize(
        HeadRequest[] calldata headRequests,
        uint256 scriptSize
    ) public pure returns (uint256 size) {
        unchecked {
            // urlencode(<html><head></head><body></body></html>)
            size = URLS_SAFE_BYTES;
            size += getBufferSizeForHeadTags(headRequests);
            size += scriptSize;
        }
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
     */
    function _appendHTMLWrappedURLSafeBody(
        bytes memory htmlFile,
        ScriptRequest[] memory requests
    ) internal view {
        ScriptRequest memory request;
        uint256 i;
        unchecked {
            do {
                request = requests[i];
                (request.wrapType == 0)
                    ? _appendScriptRequest(
                        htmlFile,
                        request,
                        true,
                        true
                    )
                    : _appendScriptRequest(
                        htmlFile,
                        request,
                        true,
                        false
                    );
            } while (++i < requests.length);
        }
    }

    // =============================================================
    //                      STRING UTILITIES
    // =============================================================

    /**
     * @notice Convert {getHTMLWrappedURLSafe} output to a string
     * @param scriptRequests - Array of WrappedScriptRequests
     * @return {getHTMLWrappedURLSafe} as a string
     */
    function getHTMLWrappedURLSafeString(
        HeadRequest[] calldata headRequests,
        ScriptRequest[] calldata scriptRequests
    ) public view returns (string memory) {
        return string(getHTMLWrappedURLSafe(headRequests, scriptRequests));
    }
}
