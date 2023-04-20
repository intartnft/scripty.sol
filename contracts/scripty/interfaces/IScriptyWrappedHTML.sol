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

import {HeadRequest, ScriptRequest} from "./../ScriptyCore.sol";

interface IScriptyWrappedHTML {
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
     * @param scriptRequests - Array of WrappedScriptRequests
     * @return Full html wrapped scripts
     */
    function getHTMLWrapped(
        HeadRequest[] calldata headRequests,
        ScriptRequest[] calldata scriptRequests
    ) external view returns (bytes memory);

    // =============================================================
    //                      ENCODED HTML GETTERS
    // =============================================================

    /**
     * @notice Get {getHTMLWrapped} and base64 encode it
     * @param scriptRequests - Array of WrappedScriptRequests
     * @return Full html wrapped scripts, base64 encoded
     */
    function getEncodedHTMLWrapped(
        HeadRequest[] calldata headRequests,
        ScriptRequest[] calldata scriptRequests
    ) external view returns (bytes memory);

    // =============================================================
    //                      STRING UTILITIES
    // =============================================================

    /**
     * @notice Convert {getHTMLWrapped} output to a string
     * @param scriptRequests - Array of WrappedScriptRequests
     * @return {getHTMLWrapped} as a string
     */
    function getHTMLWrappedString(
        HeadRequest[] calldata headRequests,
        ScriptRequest[] calldata scriptRequests
    ) external view returns (string memory);

    /**
     * @notice Convert {getEncodedHTMLWrapped} output to a string
     * @param scriptRequests - Array of WrappedScriptRequests
     * @return {getEncodedHTMLWrapped} as a string
     */
    function getEncodedHTMLWrappedString(
        HeadRequest[] calldata headRequests,
        ScriptRequest[] calldata scriptRequests
    ) external view returns (string memory);
}
