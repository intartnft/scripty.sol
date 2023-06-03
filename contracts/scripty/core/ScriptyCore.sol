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

import {HeadRequest, ScriptRequest, HTMLRequest} from "./ScriptyRequests.sol";
import {DynamicBuffer} from "./../utils/DynamicBuffer.sol";
import {IScriptyStorage} from "./../interfaces/IScriptyStorage.sol";
import {IContractScript} from "./../interfaces/IContractScript.sol";

contract ScriptyCore {
    using DynamicBuffer for bytes;

    // =============================================================
    //                        TAG CONSTANTS
    // =============================================================

    // data:text/html;base64,
    // raw
    // 22 bytes
    bytes public constant DATA_HTML_BASE64_URI_RAW = "data:text/html;base64,";
    // url encoded
    // 21 bytes
    bytes public constant DATA_HTML_URL_SAFE = "data%3Atext%2Fhtml%2C";

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
    // DATA_HTML_URL_SAFE + HTML_OPEN + HEAD_OPEN + HEAD_CLOSE + BODY_OPEN + HTML_BODY_CLOSED
    uint256 public constant URLS_SAFE_BYTES = 90;

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
    //                        SCRIPT TAG TYPES
    // =============================================================

    /**
     * @notice Grab script tag open and close depending on request tag type
     * @dev
     *      tagType: 0:
     *          <script>[SCRIPT]</script>
     *
     *      tagType: 1:
     *          <script src="data:text/javascript;base64,[SCRIPT]"></script>
     *
     *      tagType: 2:
     *          <script type="text/javascript+gzip" src="data:text/javascript;base64,[SCRIPT]"></script>
     *
     *      tagType: 3
     *          <script type="text/javascript+png" name="[NAME]" src="data:text/javascript;base64,[SCRIPT]"></script>
     *
     *      tagType: 4 or any other:
     *          [tagOpen][scriptContent or scriptFromContract][tagClose]
     *
     *      [IMPORTANT NOTE]: The tags `text/javascript+gzip` and `text/javascript+png` are used to identify scripts
     *      during decompression
     *
     * @param request - ScriptRequest data for code
     * @return (tagOpen, tagClose) - Tag open and close as a tuple
     */
    function scriptTagOpenAndCloseFor(
        ScriptRequest memory request
    ) public pure returns (bytes memory, bytes memory) {
        if (request.tagType == 0) {
            return ("<script>", "</script>");
        } else if (request.tagType == 1) {
            return ('<script src="data:text/javascript;base64,', '"></script>');
        } else if (request.tagType == 2) {
            return (
                '<script type="text/javascript+gzip" src="data:text/javascript;base64,',
                '"></script>'
            );
        } else if (request.tagType == 3) {
            return (
                '<script type="text/javascript+png" src="data:text/javascript;base64,',
                '"></script>'
            );
        }
        return (request.tagOpen, request.tagClose);
    }

    /**
     * @notice Grab URL safe script tag open and close depending on request tag type
     * @dev
     *      tagType: 0:
     *      tagType: 1:
     *          <script src="data:text/javascript;base64,[SCRIPT]"></script>
     *
     *      tagType: 2:
     *          <script type="text/javascript+gzip" src="data:text/javascript;base64,[SCRIPT]"></script>
     *
     *      tagType: 3
     *          <script type="text/javascript+png" name="[NAME]" src="data:text/javascript;base64,[SCRIPT]"></script>
     *
     *      tagType: 4 or any other:
     *          [wrapPrefix][scriptContent or scriptFromContract][wrapSuffix]
     *
     *      [IMPORTANT NOTE]: The tags `text/javascript+gzip` and `text/javascript+png` are used to identify scripts
     *      during decompression
     *
     * @param request - ScriptRequest data for code
     * @return (tagOpen, tagClose) - Tag open and close as a tuple
     */
    function urlSafeScriptTagOpenAndCloseFor(
        ScriptRequest memory request
    ) public pure returns (bytes memory, bytes memory) {
        if (request.tagType <= 1) {
            // <script src="data:text/javascript;base64,
            // "></script>
            return (
                "%253Cscript%2520src%253D%2522data%253Atext%252Fjavascript%253Bbase64%252C",
                "%2522%253E%253C%252Fscript%253E"
            );
        } else if (request.tagType == 2) {
            // <script type="text/javascript+gzip" src="data:text/javascript;base64,
            // "></script>
            return (
                "%253Cscript%2520type%253D%2522text%252Fjavascript%252Bgzip%2522%2520src%253D%2522data%253Atext%252Fjavascript%253Bbase64%252C",
                "%2522%253E%253C%252Fscript%253E"
            );
        } else if (request.tagType == 3) {
            // <script type="text/javascript+png" src="data:text/javascript;base64,
            // "></script>
            return (
                "%253Cscript%2520type%253D%2522text%252Fjavascript%252Bpng%2522%2520src%253D%2522data%253Atext%252Fjavascript%253Bbase64%252C",
                "%2522%253E%253C%252Fscript%253E"
            );
        }
        return (request.tagOpen, request.tagClose);
    }

    // =============================================================
    //                       SCRIPT FETCHER
    // =============================================================

    /**
     * @notice Grabs requested script from storage
     * @dev
     *      If given ScriptRequest contains non empty scriptContent
     *      method will return scriptContent. Otherwise, method will
     *      fetch it from the given storage contract
     *   
     * @param scriptRequest - ScriptRequest that contains 
     */
    function fetchScript(
        ScriptRequest memory scriptRequest
    ) public view returns (bytes memory) {
        if (scriptRequest.scriptContent.length > 0) {
            return scriptRequest.scriptContent;
        }
        return
            IContractScript(scriptRequest.contractAddress).getScript(
                scriptRequest.name,
                scriptRequest.contractData
            );
    }

    // =============================================================
    //                        SIZE OPERATIONS
    // =============================================================

    /**
     * @notice Get the total buffer size for the head tags
     * @param headRequests - Request being added to buffer
     * @return size - buffer size for head tags
     */
    function _getBufferSizeForHeadTags(
        HeadRequest[] memory headRequests
    ) internal pure returns (uint256 size) {
        if (headRequests.length == 0) {
            return 0;
        }

        HeadRequest memory headRequest;
        uint256 i;

        unchecked {
            do {
                headRequest = headRequests[i];
                size += headRequest.tagOpen.length;
                size += headRequest.tagContent.length;
                size += headRequest.tagClose.length;
            } while (++i < headRequests.length);
        }
    }

    /**
     * @notice Calculate the buffer size post base64 encoding
     * @param value - Starting buffer size
     * @return Final buffer size as uint256
     */
    function sizeForBase64Encoding(
        uint256 value
    ) public pure returns (uint256) {
        unchecked {
            return 4 * ((value + 2) / 3);
        }
    }

    // =============================================================
    //                     HTML CONCATENATION
    // =============================================================

    /**
     * @notice Append requests to the html buffer for head tags
     * @param htmlFile - bytes buffer
     * @param headRequests - Request being added to buffer
     */
    function _appendHeadTags(
        bytes memory htmlFile,
        HeadRequest[] memory headRequests
    ) internal pure {
        HeadRequest memory headRequest;
        uint256 i;
        unchecked {
            do {
                headRequest = headRequests[i];
                htmlFile.appendSafe(headRequest.tagOpen);
                htmlFile.appendSafe(headRequest.tagContent);
                htmlFile.appendSafe(headRequest.tagClose);
            } while (++i < headRequests.length);
        }
    }

    /**
     * @notice Append requests to the html buffer for script tags
     * @param htmlFile - bytes buffer
     * @param scriptRequests - Requests being added to buffer
     * @param includeTags - Bool to handle tag inclusion
     * @param encodeScripts - Bool to handle script encoding
     */
    function _appendScriptTags(
        bytes memory htmlFile,
        ScriptRequest[] memory scriptRequests,
        bool includeTags,
        bool encodeScripts
    ) internal pure {
        uint256 i;
        unchecked {
            do {
                _appendScriptTag(
                    htmlFile,
                    scriptRequests[i],
                    includeTags,
                    encodeScripts
                );
            } while (++i < scriptRequests.length);
        }
    }

    /**
     * @notice Append request to the html buffer for script tags
     * @param htmlFile - bytes buffer
     * @param scriptRequest - Request being added to buffer
     * @param includeTags - Bool to handle tag inclusion
     * @param encodeScripts - Bool to handle script encoding
     */
    function _appendScriptTag(
        bytes memory htmlFile,
        ScriptRequest memory scriptRequest,
        bool includeTags,
        bool encodeScripts
    ) internal pure {
        if (includeTags) {
            htmlFile.appendSafe(scriptRequest.tagOpen);
        }
        if (encodeScripts) {
            htmlFile.appendSafeBase64(
                scriptRequest.scriptContent,
                false,
                false
            );
        } else {
            htmlFile.appendSafe(scriptRequest.scriptContent);
        }
        if (includeTags) {
            htmlFile.appendSafe(scriptRequest.tagClose);
        }
    }
}
