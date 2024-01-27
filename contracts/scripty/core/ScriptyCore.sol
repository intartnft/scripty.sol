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

import {HTMLRequest, HTMLTagType, HTMLTag} from "./ScriptyStructs.sol";
import {DynamicBuffer} from "./../utils/DynamicBuffer.sol";
import {IScriptyContractStorage} from "./../interfaces/IScriptyContractStorage.sol";

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

    // data:text/html;base64,
    uint256 public constant HTML_BASE64_DATA_URI_BYTES = 22;

    // =============================================================
    //                    TAG OPEN CLOSE TEMPLATES
    // =============================================================

    /**
     * @notice Grab tag open and close depending on tag type
     * @dev
     *      tagType: 0/HTMLTagType.useTagOpenAndClose or any other:
     *          [tagOpen][CONTENT][tagClose]
     *
     *      tagType: 1/HTMLTagType.script:
     *          <script>[SCRIPT]</script>
     *
     *      tagType: 2/HTMLTagType.scriptBase64DataURI:
     *          <script src="data:text/javascript;base64,[SCRIPT]"></script>
     *
     *      tagType: 3/HTMLTagType.scriptGZIPBase64DataURI:
     *          <script type="text/javascript+gzip" src="data:text/javascript;base64,[SCRIPT]"></script>
     *
     *      tagType: 4/HTMLTagType.scriptPNGBase64DataURI
     *          <script type="text/javascript+png" name="[NAME]" src="data:text/javascript;base64,[SCRIPT]"></script>
     *
     *      [IMPORTANT NOTE]: The tags `text/javascript+gzip` and `text/javascript+png` are used to identify scripts
     *      during decompression
     *
     * @param htmlTag - HTMLTag data for code
     * @return (tagOpen, tagClose) - Tag open and close as a tuple
     */
    function tagOpenCloseForHTMLTag(
        HTMLTag memory htmlTag
    ) public pure returns (bytes memory, bytes memory) {
        if (htmlTag.tagType == HTMLTagType.script) {
            return ("<script>", "</script>");
        } else if (htmlTag.tagType == HTMLTagType.scriptBase64DataURI) {
            return ('<script src="data:text/javascript;base64,', '"></script>');
        } else if (htmlTag.tagType == HTMLTagType.scriptGZIPBase64DataURI) {
            return (
                '<script type="text/javascript+gzip" src="data:text/javascript;base64,',
                '"></script>'
            );
        } else if (htmlTag.tagType == HTMLTagType.scriptPNGBase64DataURI) {
            return (
                '<script type="text/javascript+png" src="data:text/javascript;base64,',
                '"></script>'
            );
        }
        return (htmlTag.tagOpen, htmlTag.tagClose);
    }

    /**
     * @notice Grab URL safe tag open and close depending on tag type
     * @dev
     *      tagType: 0/HTMLTagType.useTagOpenAndClose or any other:
     *          [tagOpen][scriptContent or scriptFromContract][tagClose]
     *
     *      tagType: 1/HTMLTagType.script:
     *      tagType: 2/HTMLTagType.scriptBase64DataURI:
     *          <script src="data:text/javascript;base64,[SCRIPT]"></script>
     *
     *      tagType: 3/HTMLTagType.scriptGZIPBase64DataURI:
     *          <script type="text/javascript+gzip" src="data:text/javascript;base64,[SCRIPT]"></script>
     *
     *      tagType: 4/HTMLTagType.scriptPNGBase64DataURI
     *          <script type="text/javascript+png" name="[NAME]" src="data:text/javascript;base64,[SCRIPT]"></script>
     *
     *      [IMPORTANT NOTE]: The tags `text/javascript+gzip` and `text/javascript+png` are used to identify scripts
     *      during decompression
     *
     * @param htmlTag - HTMLTag data for code
     * @return (tagOpen, tagClose) - Tag open and close as a tuple
     */
    function tagOpenCloseForHTMLTagURLSafe(
        HTMLTag memory htmlTag
    ) public pure returns (bytes memory, bytes memory) {
        if (
            htmlTag.tagType == HTMLTagType.script ||
            htmlTag.tagType == HTMLTagType.scriptBase64DataURI
        ) {
            // <script src="data:text/javascript;base64,
            // "></script>
            return (
                "%253Cscript%2520src%253D%2522data%253Atext%252Fjavascript%253Bbase64%252C",
                "%2522%253E%253C%252Fscript%253E"
            );
        } else if (htmlTag.tagType == HTMLTagType.scriptGZIPBase64DataURI) {
            // <script type="text/javascript+gzip" src="data:text/javascript;base64,
            // "></script>
            return (
                "%253Cscript%2520type%253D%2522text%252Fjavascript%252Bgzip%2522%2520src%253D%2522data%253Atext%252Fjavascript%253Bbase64%252C",
                "%2522%253E%253C%252Fscript%253E"
            );
        } else if (htmlTag.tagType == HTMLTagType.scriptPNGBase64DataURI) {
            // <script type="text/javascript+png" src="data:text/javascript;base64,
            // "></script>
            return (
                "%253Cscript%2520type%253D%2522text%252Fjavascript%252Bpng%2522%2520src%253D%2522data%253Atext%252Fjavascript%253Bbase64%252C",
                "%2522%253E%253C%252Fscript%253E"
            );
        }
        return (htmlTag.tagOpen, htmlTag.tagClose);
    }

    // =============================================================
    //                      TAG CONTENT FETCHER
    // =============================================================

    /**
     * @notice Grabs requested tag content from storage
     * @dev
     *      If given HTMLTag contains non empty contractAddress
     *      this method will fetch the content from given storage
     *      contract. Otherwise, it will return the tagContent
     *      from the given htmlTag.
     *
     * @param htmlTag - HTMLTag
     */
    function fetchTagContent(
        HTMLTag memory htmlTag
    ) public view returns (bytes memory) {
        if (htmlTag.contractAddress != address(0)) {
            return
                IScriptyContractStorage(htmlTag.contractAddress).getContent(
                    htmlTag.name,
                    htmlTag.contractData
                );
        }
        return htmlTag.tagContent;
    }

    // =============================================================
    //                        SIZE OPERATIONS
    // =============================================================

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

    /**
     * @notice Adds the required tag open/close and calculates buffer size of tags
     * @dev Effectively multiple functions bundled into one as this saves gas
     * @param htmlTags - Array of HTMLTag
     * @param isURLSafe - Bool to handle tag content/open/close encoding
     * @return Total buffersize of updated HTMLTags
     */
    function _enrichHTMLTags(
        HTMLTag[] memory htmlTags,
        bool isURLSafe
    ) internal view returns (uint256) {
        if (htmlTags.length == 0) {
            return 0;
        }

        bytes memory tagOpen;
        bytes memory tagClose;
        bytes memory tagContent;

        uint256 totalSize;
        uint256 length = htmlTags.length;
        uint256 i;

        unchecked {
            do {
                tagContent = fetchTagContent(htmlTags[i]);
                htmlTags[i].tagContent = tagContent;

                if (isURLSafe && htmlTags[i].tagType == HTMLTagType.script) {
                    totalSize += sizeForBase64Encoding(tagContent.length);
                } else {
                    totalSize += tagContent.length;
                }

                if (isURLSafe) {
                    (tagOpen, tagClose) = tagOpenCloseForHTMLTagURLSafe(
                        htmlTags[i]
                    );
                } else {
                    (tagOpen, tagClose) = tagOpenCloseForHTMLTag(htmlTags[i]);
                }

                htmlTags[i].tagOpen = tagOpen;
                htmlTags[i].tagClose = tagClose;

                totalSize += tagOpen.length;
                totalSize += tagClose.length;
            } while (++i < length);
        }
        return totalSize;
    }

    // =============================================================
    //                     HTML CONCATENATION
    // =============================================================

    /**
     * @notice Append tags to the html buffer for tags
     * @param htmlFile - bytes buffer
     * @param htmlTags - Tags being added to buffer
     * @param base64EncodeTagContent - Bool to handle tag content encoding
     */
    function _appendHTMLTags(
        bytes memory htmlFile,
        HTMLTag[] memory htmlTags,
        bool base64EncodeTagContent
    ) internal pure {
        uint256 i;
        unchecked {
            do {
                _appendHTMLTag(htmlFile, htmlTags[i], base64EncodeTagContent);
            } while (++i < htmlTags.length);
        }
    }

    /**
     * @notice Append tag to the html buffer
     * @param htmlFile - bytes buffer
     * @param htmlTag - Request being added to buffer
     * @param base64EncodeTagContent - Bool to handle tag content encoding
     */
    function _appendHTMLTag(
        bytes memory htmlFile,
        HTMLTag memory htmlTag,
        bool base64EncodeTagContent
    ) internal pure {
        htmlFile.appendSafe(htmlTag.tagOpen);
        if (base64EncodeTagContent) {
            htmlFile.appendSafeBase64(htmlTag.tagContent, false, false);
        } else {
            htmlFile.appendSafe(htmlTag.tagContent);
        }
        htmlFile.appendSafe(htmlTag.tagClose);
    }
}
