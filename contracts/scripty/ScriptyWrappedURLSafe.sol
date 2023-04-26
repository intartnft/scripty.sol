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
import "./interfaces/IScriptyWrappedURLSafe.sol";

import "hardhat/console.sol";

contract ScriptyWrappedURLSafe is ScriptyCore, IScriptyWrappedURLSafe {
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
     * @param htmlRequest - Array of WrappedScriptRequests
     * @return Full URL Safe wrapped scripts
     */
    function getHTMLWrappedURLSafe(
        HTMLRequest memory htmlRequest
    ) public view returns (bytes memory) {
        uint256 scriptBufferSize = buildWrappedURLSafeScriptsAndGetSize(
            htmlRequest.scriptRequests
        );

        console.log("buffer size", scriptBufferSize);

        bytes memory htmlFile = DynamicBuffer.allocate(
            getHTMLWrappedURLSafeBufferSize(
                htmlRequest.headRequests,
                scriptBufferSize
            )
        );

        // <html>
        htmlFile.appendSafe(HTML_OPEN_URL_SAFE);

        // <head>
        htmlFile.appendSafe(HEAD_OPEN_URL_SAFE);
        if (htmlRequest.headRequests.length > 0) {
            _appendHeadRequests(htmlFile, htmlRequest.headRequests);
        }
        htmlFile.appendSafe(HEAD_CLOSE_URL_SAFE);
        // </head>

        // <body>
        htmlFile.appendSafe(BODY_OPEN_URL_SAFE);
        if (htmlRequest.scriptRequests.length > 0) {
            _appendHTMLWrappedURLSafeBody(htmlFile, htmlRequest.scriptRequests);
        }
        htmlFile.appendSafe(HTML_BODY_CLOSED_URL_SAFE);
        // </body>
        // </html>

        return htmlFile;
    }

    function buildWrappedURLSafeScriptsAndGetSize(
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
                uint256 scriptSize = script.length;

                // When wrapType = 0, script will be base64 encoded.
                // script size should account that change as well.
                if (requests[i].wrapType == 0) {
                    scriptSize = _sizeForBase64Encoding(scriptSize);
                }

                (wrapPrefix, wrapSuffix) = _wrapURLSafePrefixAndSuffixFor(
                    requests[i]
                );
                requests[i].wrapPrefix = wrapPrefix;
                requests[i].wrapSuffix = wrapSuffix;

                totalSize += wrapPrefix.length;
                totalSize += scriptSize;
                totalSize += wrapSuffix.length;
            } while (++i < length);
        }
        return totalSize;
    }

    function getHTMLWrappedURLSafeBufferSize(
        HeadRequest[] memory headRequests,
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
    ) internal pure {
        ScriptRequest memory request;
        uint256 i;
        unchecked {
            do {
                request = requests[i];
                (request.wrapType == 0)
                    ? _appendScriptRequest(htmlFile, request, true, true)
                    : _appendScriptRequest(htmlFile, request, true, false);
            } while (++i < requests.length);
        }
    }

    // =============================================================
    //                      STRING UTILITIES
    // =============================================================

    /**
     * @notice Convert {getHTMLWrappedURLSafe} output to a string
     * @param htmlRequest - Array of WrappedScriptRequests
     * @return {getHTMLWrappedURLSafe} as a string
     */
    function getHTMLWrappedURLSafeString(
        HTMLRequest memory htmlRequest
    ) public view returns (string memory) {
        return string(getHTMLWrappedURLSafe(htmlRequest));
    }
}
