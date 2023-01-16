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

/**
  @title A generic HTML builder that fetches and assembles given JS requests.
  @author @0xthedude
  @author @xtremetom

  Special thanks to @cxkoda and @frolic
*/

import {DynamicBuffer} from "./utils/DynamicBuffer.sol";
import {AddressChunks} from "./utils/AddressChunks.sol";

import {IScriptyBuilder, InlineScriptRequest, WrappedScriptRequest} from "./IScriptyBuilder.sol";
import {IScriptyStorage} from "./IScriptyStorage.sol";
import {IContractScript} from "./IContractScript.sol";

contract ScriptyBuilder is IScriptyBuilder {
    using DynamicBuffer for bytes;

    // <html>,
    // raw
    // 6 bytes
    bytes public constant HTML_TAG_RAW = "<html>";
    // url encoded
    // 21 bytes
    bytes public constant HTML_TAG_URL_SAFE = "data%3Atext%2Fhtml%2C";

    // <body style='margin:0;'>
    // 24 bytes
    bytes public constant HTML_BODY_OPEN_RAW = "<body style='margin:0;'>";
    // url encoded
    // 56 bytes
    bytes public constant HTML_BODY_OPEN_URL_SAFE =
        "%253Cbody%2520style%253D%2527margin%253A0%253B%2527%253E";

    // </body></html>
    // 14 bytes
    bytes public constant HTML_BODY_CLOSED_RAW = "</body></html>";
    // 19 bytes
    bytes public constant HTML_BODY_CLOSED_URL_SAFE = "%253C%252Fbody%253E";

    // HTML_TAG_RAW + HTML_BODY_OPEN_RAW + HTML_BODY_CLOSED_RAW
    uint256 public constant URLS_RAW_BYTES = 44;

    // HTML_TAG_URL_SAFE + HTML_BODY_OPEN_URL_SAFE + HTML_BODY_CLOSED_URL_SAFE
    uint256 public constant URLS_SAFE_BYTES = 96;

    // <script></script>
    uint256 public constant SCRIPT_INLINE_BYTES = 17;

    // data:text/html;base64,
    uint256 public constant HTML_BASE64_DATA_URI_BYTES = 22;

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
        htmlFile.appendSafe(HTML_TAG_RAW);
        htmlFile.appendSafe(HTML_BODY_OPEN_RAW);

        bytes memory wrapPrefix;
        bytes memory wrapSuffix;
        WrappedScriptRequest memory request;
        uint256 i;

        unchecked {
            do {
                request = requests[i];
                (wrapPrefix, wrapSuffix) = wrapPrefixAndSuffixFor(request);
                htmlFile.appendSafe(wrapPrefix);

                htmlFile.appendSafe(
                    fetchScript(
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
        return htmlFile;
    }

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
     * @return Full URL Safe wrapped scripts
     */
    function getHTMLWrappedURLSafe(
        WrappedScriptRequest[] calldata requests,
        uint256 bufferSize
    ) public view returns (bytes memory) {
        uint256 length = requests.length;
        if (length == 0) revert InvalidRequestsLength();

        bytes memory htmlFile = DynamicBuffer.allocate(bufferSize);
        htmlFile.appendSafe(HTML_TAG_URL_SAFE);
        htmlFile.appendSafe(HTML_BODY_OPEN_URL_SAFE);

        bytes memory wrapPrefix;
        bytes memory wrapSuffix;
        WrappedScriptRequest memory request;
        uint256 i;

        // Iterate through scripts and convert any non base64 into base64
        // Dont touch any existing base64
        // Wrap code in appropriate urlencoded tags
        unchecked {
            do {
                request = requests[i];
                (wrapPrefix, wrapSuffix) = wrapURLSafePrefixAndSuffixFor(
                    request
                );
                htmlFile.appendSafe(wrapPrefix);

                // convert raw code into base64
                if (request.wrapType == 0) {
                    htmlFile.appendSafeBase64(
                        fetchScript(
                            request.name,
                            request.contractAddress,
                            request.contractData,
                            request.scriptContent
                        ),
                        false,
                        false
                    );
                } else {
                    htmlFile.appendSafe(
                        fetchScript(
                            request.name,
                            request.contractAddress,
                            request.contractData,
                            request.scriptContent
                        )
                    );
                }
                htmlFile.appendSafe(wrapSuffix);
            } while (++i < length);
        }

        htmlFile.appendSafe(HTML_BODY_CLOSED_URL_SAFE);
        return htmlFile;
    }

    /**
     * @notice Get requested scripts housed in <body> all wrapped in <script></script>
     * @dev Your requested scripts are returned in the following format:
     *      <html>
     *          <head></head>
     *          <body style='margin:0;'>
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
        htmlFile.appendSafe(HTML_TAG_RAW);
        htmlFile.appendSafe(HTML_BODY_OPEN_RAW);
        htmlFile.appendSafe("<script>");

        InlineScriptRequest memory request;
        uint256 i;

        unchecked {
            do {
                request = requests[i];
                htmlFile.appendSafe(
                    fetchScript(
                        request.name,
                        request.contractAddress,
                        request.contractData,
                        request.scriptContent
                    )
                );
            } while (++i < length);
        }

        htmlFile.appendSafe("</script>");
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
        WrappedScriptRequest[] calldata requests,
        uint256 bufferSize
    ) public view returns (bytes memory) {
        unchecked {
            bytes memory rawHTML = getHTMLWrapped(requests, bufferSize);

            uint256 sizeForEncoding = HTML_BASE64_DATA_URI_BYTES +
                sizeForBase64Encoding(rawHTML.length);

            bytes memory htmlFile = DynamicBuffer.allocate(sizeForEncoding);
            htmlFile.appendSafe("data:text/html;base64,");
            htmlFile.appendSafeBase64(rawHTML, false, false);
            return htmlFile;
        }
    }

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
                sizeForBase64Encoding(rawHTML.length);

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
     * @notice Convert {getHTMLWrappedURLSafe} output to a string
     * @param requests - Array of WrappedScriptRequests
     * @param bufferSize - Total buffer size of all requested scripts
     * @return {getHTMLWrappedURLSafe} as a string
     */
    function getURLSafeHTMLWrappedString(
        WrappedScriptRequest[] calldata requests,
        uint256 bufferSize
    ) public view returns (string memory) {
        return string(getHTMLWrappedURLSafe(requests, bufferSize));
    }

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
            fetchScript(
                request.name,
                request.contractAddress,
                request.contractData,
                request.scriptContent
            ).length;
    }

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
            ) = wrapPrefixAndSuffixFor(request);

            uint256 scriptSize = fetchScript(
                request.name,
                request.contractAddress,
                request.contractData,
                request.scriptContent
            ).length;

            return wrapPrefix.length + wrapSuffix.length + scriptSize;
        }
    }

    /**
     * @notice Get the buffer size of a single wrapped requested code
     * @dev If the script is of wrapper type 0, we get buffer size for
     *      base64 encoded version.
     * @param request - WrappedScriptRequest data for code
     * @return Buffer size as an unit256
     */
    function getURLSafeWrappedScriptSize(WrappedScriptRequest memory request)
        public
        view
        returns (uint256)
    {
        unchecked {
            (
                bytes memory wrapPrefix,
                bytes memory wrapSuffix
            ) = wrapURLSafePrefixAndSuffixFor(request);

            uint256 scriptSize = fetchScript(
                request.name,
                request.contractAddress,
                request.contractData,
                request.scriptContent
            ).length;

            if (request.wrapType == 0) {
                scriptSize = sizeForBase64Encoding(scriptSize);
            }

            return wrapPrefix.length + wrapSuffix.length + scriptSize;
        }
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
     * @notice Get the buffer size of an array of URL safe html wrapped scripts
     * @param requests - WrappedScriptRequests data for code
     * @return Buffer size as an unit256
     */
    function getBufferSizeForURLSafeHTMLWrapped(
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
                    size += getURLSafeWrappedScriptSize(request);
                } while (++i < length);
            }
            return size + URLS_SAFE_BYTES;
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
            return HTML_BASE64_DATA_URI_BYTES + sizeForBase64Encoding(size);
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
            return HTML_BASE64_DATA_URI_BYTES + sizeForBase64Encoding(size);
        }
    }

    // =============================================================
    //                           INTERNAL
    // =============================================================

    /**
     * @notice Grabs requested script from storage
     * @param scriptName - Name given to the script. Eg: threejs.min.js_r148
     * @param storageAddress - Address of scripty storage contract
     * @param contractData - Arbitrary data to be passed to storage
     * @param scriptContent - Small custom script to inject
     * @return Requested script as bytes
     */
    function fetchScript(
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
     *
     *      [IMPORTANT NOTE]: The tags `text/javascript+gzip` and `text/javascript+png` are used to identify scripts
     *      during decompression
     *
     * @param request - WrappedScriptRequest data for code
     * @return (prefix, suffix) - Type specific prefix and suffix as a tuple
     */
    function wrapPrefixAndSuffixFor(WrappedScriptRequest memory request)
    internal
    pure
    returns (bytes memory, bytes memory)
    {
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
     *
     *      [IMPORTANT NOTE]: The tags `text/javascript+gzip` and `text/javascript+png` are used to identify scripts
     *      during decompression
     *
     * @param request - WrappedScriptRequest data for code
     * @return (prefix, suffix) - Type specific prefix and suffix as a tuple
     */
    function wrapURLSafePrefixAndSuffixFor(WrappedScriptRequest memory request)
    internal
    pure
    returns (bytes memory, bytes memory)
    {
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

    /**
     * @notice Calculate the buffer size post base64 encoding
     * @param value - Starting buffer size
     * @return Final buffer size as uint256
     */
    function sizeForBase64Encoding(uint256 value)
        internal
        pure
        returns (uint256)
    {
        unchecked {
            return 4 * ((value + 2) / 3);
        }
    }
}
