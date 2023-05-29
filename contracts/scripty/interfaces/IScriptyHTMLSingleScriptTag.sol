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

import {HTMLRequest, HeadRequest, ScriptRequest} from "./../core/ScriptyCore.sol";

interface IScriptyHTMLSingleScriptTag {
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
     * @param htmlRequest - Array of WrappedScriptRequests
     * @return Full html wrapped scripts
     */
    function getHTMLSingleScriptTag(
        HTMLRequest memory htmlRequest
    ) external view returns (bytes memory);

    // =============================================================
    //                      ENCODED HTML GETTERS
    // =============================================================

    /**
     * @notice Get {getHTMLInline} and base64 encode it
     * @param htmlRequest - Array of InlineScriptRequests
     * @return Full html wrapped scripts, base64 encoded
     */
    function getEncodedHTMLSingleScriptTag(
        HTMLRequest memory htmlRequest
    ) external view returns (bytes memory);

    // =============================================================
    //                      STRING UTILITIES
    // =============================================================

    /**
     * @notice Convert {getHTMLInline} output to a string
     * @param htmlRequest - Array of InlineScriptRequests
     * @return {getHTMLInline} as a string
     */
    function getHTMLSingleScriptTagString(
        HTMLRequest memory htmlRequest
    ) external view returns (string memory);

    /**
     * @notice Convert {getEncodedHTMLInline} output to a string
     * @param htmlRequest - Array of InlineScriptRequests
     * @return {getEncodedHTMLInline} as a string
     */
    function getEncodedHTMLSingleScriptTagString(
        HTMLRequest memory htmlRequest
    ) external view returns (string memory);
}
