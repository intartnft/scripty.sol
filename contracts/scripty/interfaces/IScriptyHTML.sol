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

interface IScriptyHTML {
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
    function getHTML(
        HTMLRequest memory htmlRequest
    ) external view returns (bytes memory);

    // =============================================================
    //                      ENCODED HTML GETTERS
    // =============================================================

    /**
     * @notice Get {getHTMLWrapped} and base64 encode it
     * @param htmlRequest - Array of WrappedScriptRequests
     * @return Full html wrapped scripts, base64 encoded
     */
    function getEncodedHTML(
        HTMLRequest memory htmlRequest
    ) external view returns (bytes memory);

    // =============================================================
    //                      STRING UTILITIES
    // =============================================================

    /**
     * @notice Convert {getHTMLWrapped} output to a string
     * @param htmlRequest - Array of WrappedScriptRequests
     * @return {getHTMLWrapped} as a string
     */
    function getHTMLString(
        HTMLRequest memory htmlRequest
    ) external view returns (string memory);

    /**
     * @notice Convert {getEncodedHTMLWrapped} output to a string
     * @param htmlRequest - Array of WrappedScriptRequests
     * @return {getEncodedHTMLWrapped} as a string
     */
    function getEncodedHTMLString(
        HTMLRequest memory htmlRequest
    ) external view returns (string memory);
}
