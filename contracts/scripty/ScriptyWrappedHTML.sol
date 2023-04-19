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
import {IScriptyWrappedHTML} from "./IScriptyWrappedHTML.sol";

contract ScriptyWrappedHTML is IScriptyWrappedHTML, ScriptyCore {
    using DynamicBuffer for bytes;

    // =============================================================
    //                      RAW HTML GETTERS
    // =============================================================

    /**
     * @notice Get requested scripts housed in <body> with custom wrappers
     * @dev Your requested scripts are returned in the following format:
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
     * @return Full html wrapped scripts
     */
    function getHTMLWrapped(
        HeadRequest[] calldata headRequests,
        WrappedScriptRequest[] memory requests
    ) public view returns (bytes memory) {
        (
            WrappedScriptRequest[] memory fetchedRequests,
            uint256 totalSize
        ) = fetchWrappedScripts(requests);

        bytes memory htmlFile = DynamicBuffer.allocate(
            totalSize + URLS_RAW_BYTES
        );

        // <html>
        htmlFile.appendSafe(HTML_OPEN_RAW);

        // <head>
        htmlFile.appendSafe(HEAD_OPEN_RAW);
        if (headRequests.length > 0) {
            htmlFile = _appendHeadRequests(htmlFile, headRequests);
        }
        htmlFile.appendSafe(HEAD_CLOSE_RAW);
        // </head>

        // <body>
        htmlFile.appendSafe(BODY_OPEN_RAW);
        if (requests.length > 0) {
            htmlFile = _appendWrappedBody(htmlFile, fetchedRequests);
        }
        htmlFile.appendSafe(HTML_BODY_CLOSED_RAW);
        // </body>
        // </html>

        return htmlFile;
    }

    /**
     * @notice Append wrapped HTML requests to the buffer
     * @param htmlFile - Final buffer holding all requests
     * @param requests - Array of WrappedScriptRequests
     * @return buffer holding requests
     */
    function _appendWrappedBody(
        bytes memory htmlFile,
        WrappedScriptRequest[] memory requests
    ) internal pure returns (bytes memory) {
        uint256 i;
        unchecked {
            do {
                htmlFile = _appendWrappedScriptRequests(
                    htmlFile,
                    requests[i],
                    false
                );
            } while (++i < requests.length);
        }

        return htmlFile;
    }

    /**
     * @notice Append HTML requests to the html buffer
     * @param htmlFile - bytes buffer
     * @param request - Request being added to buffer
     * @param isSafeBase64 - Should we use the appendSafeBase64 method
     * @return buffer with new appended request
     */
    function _appendWrappedScriptRequests(
        bytes memory htmlFile,
        WrappedScriptRequest memory request,
        bool isSafeBase64
    ) internal pure returns (bytes memory) {
        htmlFile.appendSafe(request.wrapPrefix);
        if (isSafeBase64) {
            htmlFile.appendSafeBase64(request.scriptContent, false, false);
        } else {
            htmlFile.appendSafe(request.scriptContent);
        }
        htmlFile.appendSafe(request.wrapSuffix);

        return htmlFile;
    }

    // =============================================================
    //                      ENCODED HTML GETTERS
    // =============================================================

    /**
     * @notice Get {getHTMLWrapped} and base64 encode it
     * @param requests - Array of WrappedScriptRequests
     * @return Full html wrapped scripts, base64 encoded
     */
    function getEncodedHTMLWrapped(
        HeadRequest[] calldata headRequests,
        WrappedScriptRequest[] calldata requests
    ) public view returns (bytes memory) {
        unchecked {
            bytes memory rawHTML = getHTMLWrapped(
                headRequests,
                requests
            );

            uint256 sizeForEncoding = _sizeForBase64Encoding(rawHTML.length);
            sizeForEncoding += HTML_BASE64_DATA_URI_BYTES;

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
     * @return {getHTMLWrapped} as a string
     */
    function getHTMLWrappedString(
        HeadRequest[] calldata headRequests,
        WrappedScriptRequest[] calldata requests
    ) public view returns (string memory) {
        return string(getHTMLWrapped(headRequests, requests));
    }

    /**
     * @notice Convert {getEncodedHTMLWrapped} output to a string
     * @param requests - Array of WrappedScriptRequests
     * @return {getEncodedHTMLWrapped} as a string
     */
    function getEncodedHTMLWrappedString(
        HeadRequest[] calldata headRequests,
        WrappedScriptRequest[] calldata requests
    ) public view returns (string memory) {
        return
            string(getEncodedHTMLWrapped(headRequests, requests));
    }
}
