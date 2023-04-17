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
//░░░░░░░░░░░░░░░░░░░░░░    CORE    ░░░░░░░░░░░░░░░░░░░░░//
///////////////////////////////////////////////////////////

/**
  @title A generic HTML builder that fetches and assembles given JS requests.
  @author @0xthedude
  @author @xtremetom

  Special thanks to @cxkoda, @frolic and @dhof
*/

import {DynamicBuffer} from "./utils/DynamicBuffer.sol";
import {HeadRequest, InlineScriptRequest, WrappedScriptRequest} from "./IScriptyBuilder.sol";
import {IScriptyStorage} from "./IScriptyStorage.sol";
import {IContractScript} from "./IContractScript.sol";

contract ScriptyCore {
    using DynamicBuffer for bytes;

    error InvalidRequestsLength();

    // =============================================================
    //                        TAG CONSTANTS
    // =============================================================

    // <html>,
    // raw
    // 6 bytes
    bytes public constant HTML_OPEN_RAW = "<html>";
    // url encoded
    // 10 bytes
    bytes public constant HTML_OPEN_URL_SAFE = "%3Chtml%3E";

    // <head>,
    // raw
    // 6 bytes
    bytes public constant HEAD_OPEN_RAW = "<head>";
    // url encoded
    // 10 bytes
    bytes public constant HEAD_OPEN_URL_SAFE = "%3Chead%3E";

    // </head>,
    // raw
    // 7 bytes
    bytes public constant HEAD_CLOSE_RAW = "</head>";
    // url encoded
    // 13 bytes
    bytes public constant HEAD_CLOSE_URL_SAFE = "%3C%2Fhead%3E";

    // <body>
    // 6 bytes
    bytes public constant BODY_OPEN_RAW = "<body>";
    // url encoded
    // 10 bytes
    bytes public constant BODY_OPEN_URL_SAFE = "%3Cbody%3E";

    // </body></html>
    // 14 bytes
    bytes public constant HTML_BODY_CLOSED_RAW = "</body></html>";
    // 26 bytes
    bytes public constant HTML_BODY_CLOSED_URL_SAFE =
        "%3C%2Fbody%3E%3C%2Fhtml%3E";

    // <script>,
    // raw
    // 8 bytes
    bytes public constant SCRIPT_OPEN_RAW = "<script>";
    // url encoded
    // 12 bytes
    bytes public constant SCRIPT_OPEN_URL_SAFE = "%3Cscript%3E";

    // </script>,
    // raw
    // 9 bytes
    bytes public constant SCRIPT_CLOSE_RAW = "</script>";
    // url encoded
    // 15 bytes
    bytes public constant SCRIPT_CLOSE_URL_SAFE = "%3C%2Fscript%3E";

    // [RAW]
    // HTML_OPEN + HEAD_OPEN + HEAD_CLOSE + BODY_OPEN + HTML_BODY_CLOSED
    uint256 public constant URLS_RAW_BYTES = 39;

    // [URL_SAFE]
    // HTML_OPEN + HEAD_OPEN + HEAD_CLOSE + BODY_OPEN + HTML_BODY_CLOSED
    uint256 public constant URLS_SAFE_BYTES = 69;

    // [RAW]
    // HTML_OPEN + HTML_CLOSE
    uint256 public constant HTML_RAW_BYTES = 13;

    // [RAW]
    // HEAD_OPEN + HEAD_CLOSE
    uint256 public constant HEAD_RAW_BYTES = 13;

    // [RAW]
    // BODY_OPEN + BODY_CLOSE
    uint256 public constant BODY_RAW_BYTES = 13;

    // All raw
    // HTML_RAW_BYTES + HEAD_RAW_BYTES + BODY_RAW_BYTES
    uint256 public constant RAW_BYTES = 39;

    // [URL_SAFE]
    // HTML_OPEN + HTML_CLOSE
    uint256 public constant HTML_URL_SAFE_BYTES = 23;

    // [URL_SAFE]
    // HEAD_OPEN + HEAD_CLOSE
    uint256 public constant HEAD_URL_SAFE_BYTES = 23;

    // [URL_SAFE]
    // BODY_OPEN + BODY_CLOSE
    uint256 public constant BODY_SAFE_BYTES = 23;

    // All url safe
    // HTML_URL_SAFE_BYTES + HEAD_URL_SAFE_BYTES + BODY_URL_SAFE_BYTES
    // %3Chtml%3E%3Chead%3E%3C%2Fhead%3E%3Cbody%3E%3C%2Fbody%3E%3C%2Fhtml%3E
    uint256 public constant URL_SAFE_BYTES = 69;

    // <script></script>
    uint256 public constant SCRIPT_INLINE_BYTES = 17;

    // data:text/html;base64,
    uint256 public constant HTML_BASE64_DATA_URI_BYTES = 22;

    // =============================================================
    //                           INTERNAL
    // =============================================================

    /**
     * @notice Grab script wrapping based on script type
     * @dev
     *      wrapType: 0:
     *          <script>[SCRIPT]</script>
     *
     *      wrapType: 1:
     *          <script src="data:text/javascript;base64,[SCRIPT]"></script>
     *
     *      wrapType: 2:
     *          <script type="text/javascript+gzip" src="data:text/javascript;base64,[SCRIPT]"></script>
     *
     *      wrapType: 3
     *          <script type="text/javascript+png" name="[NAME]" src="data:text/javascript;base64,[SCRIPT]"></script>
     *
     *      wrapType: 4 or any other:
     *          [wrapPrefix][scriptContent or scriptFromContract][wrapSuffix]
     *
     *      [IMPORTANT NOTE]: The tags `text/javascript+gzip` and `text/javascript+png` are used to identify scripts
     *      during decompression
     *
     * @param request - WrappedScriptRequest data for code
     * @return (prefix, suffix) - Type specific prefix and suffix as a tuple
     */
    function _wrapPrefixAndSuffixFor(
        WrappedScriptRequest memory request
    ) internal pure returns (bytes memory, bytes memory) {
        if (request.wrapType == 0) {
            return ("<script>", "</script>");
        } else if (request.wrapType == 1) {
            return ('<script src="data:text/javascript;base64,', '"></script>');
        } else if (request.wrapType == 2) {
            return (
                '<script type="text/javascript+gzip" src="data:text/javascript;base64,',
                '"></script>'
            );
        } else if (request.wrapType == 3) {
            return (
                '<script type="text/javascript+png" src="data:text/javascript;base64,',
                '"></script>'
            );
        }
        return (request.wrapPrefix, request.wrapSuffix);
    }

    /**
     * @notice Grab URL safe script wrapping based on script type
     * @dev
     *      wrapType: 0:
     *      wrapType: 1:
     *          <script src="data:text/javascript;base64,[SCRIPT]"></script>
     *
     *      wrapType: 2:
     *          <script type="text/javascript+gzip" src="data:text/javascript;base64,[SCRIPT]"></script>
     *
     *      wrapType: 3
     *          <script type="text/javascript+png" name="[NAME]" src="data:text/javascript;base64,[SCRIPT]"></script>
     *
     *      wrapType: 4 or any other:
     *          [wrapPrefix][scriptContent or scriptFromContract][wrapSuffix]
     *
     *      [IMPORTANT NOTE]: The tags `text/javascript+gzip` and `text/javascript+png` are used to identify scripts
     *      during decompression
     *
     * @param request - WrappedScriptRequest data for code
     * @return (prefix, suffix) - Type specific prefix and suffix as a tuple
     */
    function _wrapURLSafePrefixAndSuffixFor(
        WrappedScriptRequest memory request
    ) internal pure returns (bytes memory, bytes memory) {
        if (request.wrapType <= 1) {
            // <script src="data:text/javascript;base64,
            // "></script>
            return (
                "%253Cscript%2520src%253D%2522data%253Atext%252Fjavascript%253Bbase64%252C",
                "%2522%253E%253C%252Fscript%253E"
            );
        } else if (request.wrapType == 2) {
            // <script type="text/javascript+gzip" src="data:text/javascript;base64,
            // "></script>
            return (
                "%253Cscript%2520type%253D%2522text%252Fjavascript%252Bgzip%2522%2520src%253D%2522data%253Atext%252Fjavascript%253Bbase64%252C",
                "%2522%253E%253C%252Fscript%253E"
            );
        } else if (request.wrapType == 3) {
            // <script type="text/javascript+png" src="data:text/javascript;base64,
            // "></script>
            return (
                "%253Cscript%2520type%253D%2522text%252Fjavascript%252Bpng%2522%2520src%253D%2522data%253Atext%252Fjavascript%253Bbase64%252C",
                "%2522%253E%253C%252Fscript%253E"
            );
        }
        return (request.wrapPrefix, request.wrapSuffix);
    }

    function fetchInlineScripts(
        InlineScriptRequest[] memory requests
    ) internal view returns (InlineScriptRequest[] memory, uint256) {
        if (requests.length == 0) {
            return (requests, 0);
        }
        uint256 i;
        uint256 length = requests.length;
        uint256 totalSize;
        unchecked {
            do {
                bytes memory script = IContractScript(
                    requests[i].contractAddress
                ).getScript(requests[i].name, requests[i].contractData);
                requests[i].scriptContent = script;
                totalSize += script.length;
            } while (++i < length);
        }
        return (requests, totalSize);
    }

    function fetchWrappedScripts(
        WrappedScriptRequest[] memory requests
    ) internal view returns (WrappedScriptRequest[] memory, uint256) {
        if (requests.length == 0) {
            return (requests, 0);
        }
        uint256 i;
        uint256 length = requests.length;
        uint256 totalSize;
        unchecked {
            do {
                bytes memory script = IContractScript(
                    requests[i].contractAddress
                ).getScript(requests[i].name, requests[i].contractData);
                requests[i].scriptContent = script;
                totalSize += script.length;
            } while (++i < length);
        }
        return (requests, totalSize);
    }

    /**
     * @notice Grabs requested script from storage
     * @param scriptName - Name given to the script. Eg: threejs.min.js_r148
     * @param storageAddress - Address of scripty storage contract
     * @param contractData - Arbitrary data to be passed to storage
     * @param scriptContent - Small custom script to inject
     * @return Requested script as bytes
     */
    function _fetchScript(
        string memory scriptName,
        address storageAddress,
        bytes memory contractData,
        bytes memory scriptContent
    ) internal view returns (bytes memory) {
        if (scriptContent.length > 0) {
            return scriptContent;
        }

        return
            IContractScript(storageAddress).getScript(scriptName, contractData);
    }

    /**
     * @notice Append HTML requests to the html buffer
     * @param htmlFile - bytes buffer
     * @param request - Request being added to buffer
     * @param isSafeBase64 - Should we use the appendSafeBase64 method
     * @return buffer with new appended request
     */
    function _appendWrappedHTMLRequests(
        bytes memory htmlFile,
        WrappedScriptRequest memory request,
        bool isSafeBase64
    ) internal view returns (bytes memory) {
        htmlFile.appendSafe(request.wrapPrefix);
        if (isSafeBase64) {
            htmlFile.appendSafeBase64(request.scriptContent, false, false);
        } else {
            htmlFile.appendSafe(request.scriptContent);
        }
        htmlFile.appendSafe(request.wrapSuffix);

        return htmlFile;
    }

    /**
     * @notice Append requests to the html buffer for head tags
     * @param htmlFile - bytes buffer
     * @param headRequests - Request being added to buffer
     * @return buffer with new appended request
     */
    function _appendHeadRequests(
        bytes memory htmlFile,
        HeadRequest[] calldata headRequests
    ) internal pure returns (bytes memory) {
        HeadRequest memory headRequest;
        uint256 i;
        unchecked {
            do {
                headRequest = headRequests[i];
                htmlFile.appendSafe(headRequest.wrapPrefix);
                htmlFile.appendSafe(headRequest.scriptContent);
                htmlFile.appendSafe(headRequest.wrapSuffix);
            } while (++i < headRequests.length);
        }

        return htmlFile;
    }

    /**
     * @notice Get the total buffer size for the head tags
     * @param headRequests - Request being added to buffer
     * @return size - buffer size for head tags
     */
    function getBufferSizeForHeadTags(
        HeadRequest[] calldata headRequests
    ) public pure returns (uint256 size) {
        HeadRequest memory headRequest;
        uint256 i;
        unchecked {
            do {
                headRequest = headRequests[i];
                size += headRequest.scriptContent.length;
                size += headRequest.wrapPrefix.length;
                size += headRequest.wrapSuffix.length;
            } while (++i < headRequests.length);
        }
    }

    /**
     * @notice Calculate the buffer size post base64 encoding
     * @param value - Starting buffer size
     * @return Final buffer size as uint256
     */
    function _sizeForBase64Encoding(
        uint256 value
    ) internal pure returns (uint256) {
        unchecked {
            return 4 * ((value + 2) / 3);
        }
    }
}
