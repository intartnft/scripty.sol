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

interface IScriptyHTMLSingleScriptTag {
    // // =============================================================
    // //                      RAW HTML GETTERS
    // // =============================================================

    // /**
    //  * @notice  Get HTML with requested head tags and scripts housed in 
    //  *          single <script> tag
    //  * @dev Your HTML is returned in the following format:
    //  *      <html>
    //  *          <head>
    //  *              [tagOpen[0]][tagContent[0]][tagClose[0]]
    //  *              [tagOpen[1]][tagContent[1]][tagClose[1]]
    //  *              ...
    //  *              [tagOpen[n]][tagContent[n]][tagClose[n]]
    //  *          </head>
    //  *          <body>
    //  *              <script>
    //  *                  {request[0]}
    //  *                  {request[1]}
    //  *                  ...
    //  *                  {request[n]}
    //  *              </script>
    //  *          </body>
    //  *      </html>
    //  * @param htmlRequest - HTMLRequest
    //  * @return Full HTML with head and script tags
    //  */
    // function getHTMLSingleScriptTag(
    //     HTMLRequest memory htmlRequest
    // ) external view returns (bytes memory);

    // // =============================================================
    // //                      ENCODED HTML GETTERS
    // // =============================================================

    // /**
    //  * @notice Get {getHTMLSingleScriptTag} and base64 encode it
    //  * @param htmlRequest - HTMLRequest
    //  * @return Full HTML with head and script tags, base64 encoded
    //  */
    // function getEncodedHTMLSingleScriptTag(
    //     HTMLRequest memory htmlRequest
    // ) external view returns (bytes memory);

    // // =============================================================
    // //                      STRING UTILITIES
    // // =============================================================

    // /**
    //  * @notice Convert {getHTMLSingleScriptTag} output to a string
    //  * @param htmlRequest - HTMLRequest
    //  * @return {getHTMLSingleScriptTag} as a string
    //  */
    // function getHTMLSingleScriptTagString(
    //     HTMLRequest memory htmlRequest
    // ) external view returns (string memory);

    // /**
    //  * @notice Convert {getEncodedHTMLSingleScriptTag} output to a string
    //  * @param htmlRequest - HTMLRequest
    //  * @return {getEncodedHTMLSingleScriptTag} as a string
    //  */
    // function getEncodedHTMLSingleScriptTagString(
    //     HTMLRequest memory htmlRequest
    // ) external view returns (string memory);
}
