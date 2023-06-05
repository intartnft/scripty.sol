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

import {HTMLRequest, HTMLTagType, HTMLTag} from "./../core/ScriptyCore.sol";

interface IScriptyHTMLURLSafe {
    // =============================================================
    //                      RAW HTML GETTERS
    // =============================================================

    /**
     * @notice  Get URL safe HTML with requested head tags and scripts housed
     *          in single <script> tag
     * @dev Any tag type 0 scripts are converted to base64 and wrapped
     *      with <script src="data:text/javascript;base64,[SCRIPT]"></script>
     *
     *      [WARNING]: Large non-base64 libraries that need base64 encoding
     *      carry a high risk of causing a gas out. Highly advised the use
     *      of base64 encoded scripts where possible
     *
     *      Your HTML is returned in the following format:
     *      <html>
     *          <head>
     *              [tagOpen[0]][tagContent[0]][tagClose[0]]
     *              [tagOpen[1]][tagContent[1]][tagClose[1]]
     *              ...
     *              [tagOpen[n]][tagContent[n]][tagClose[n]]
     *          </head>
     *          <body>
     *              [tagOpen[0]]{request[0]}[tagClose[0]]
     *              [tagOpen[1]]{request[1]}[tagClose[1]]
     *              ...
     *              [tagOpen[n]]{request[n]}[tagClose[n]]
     *          </body>
     *      </html>
     * @param htmlRequest - HTMLRequest
     * @return Full URL safe HTML with head and script tags
     */
    function getHTMLURLSafe(
        HTMLRequest memory htmlRequest
    ) external view returns (bytes memory);

    // =============================================================
    //                      STRING UTILITIES
    // =============================================================

    /**
     * @notice Convert {getHTMLURLSafe} output to a string
     * @param htmlRequest - HTMLRequest
     * @return {getHTMLURLSafe} as a string
     */
    function getHTMLURLSafeString(
        HTMLRequest memory htmlRequest
    ) external view returns (string memory);
}
