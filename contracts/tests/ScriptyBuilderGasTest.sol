//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import {HTMLRequest, HeadRequest, ScriptRequest} from "../scripty/core/ScriptyCore.sol";
import {IScriptyBuilderV2} from "../scripty/interfaces/IScriptyBuilderV2.sol";

contract ScriptyBuilderGasTest {
    address public immutable scriptyBuilderAddress;

    constructor(
        address _scriptyBuilderAddress
    ) {
        scriptyBuilderAddress = _scriptyBuilderAddress;
    }

    // solc-ignore-next-line func-mutability
    function getEncodedHTMLSingleScriptTag_Few(
        HTMLRequest memory htmlRequest
    ) external {
        IScriptyBuilderV2(scriptyBuilderAddress).getEncodedHTMLSingleScriptTag(
            htmlRequest
        );
    }

    // solc-ignore-next-line func-mutability
    function getEncodedHTMLSingleScriptTag_Many(
        HTMLRequest memory htmlRequest
    ) external {
        IScriptyBuilderV2(scriptyBuilderAddress).getEncodedHTMLSingleScriptTag(
            htmlRequest
        );
    }

    // solc-ignore-next-line func-mutability
    function getEncodedHTML_TagType_0_Few(
        HTMLRequest memory htmlRequest
    ) external {
        IScriptyBuilderV2(scriptyBuilderAddress).getEncodedHTML(
            htmlRequest
        );
    }

    // solc-ignore-next-line func-mutability
    function getEncodedHTML_TagType_1_Few(
        HTMLRequest memory htmlRequest
    ) external {
        IScriptyBuilderV2(scriptyBuilderAddress).getEncodedHTML(
            htmlRequest
        );
    }

    // solc-ignore-next-line func-mutability
    function getEncodedHTML_TagType_2_Few(
        HTMLRequest memory htmlRequest
    ) external {
        IScriptyBuilderV2(scriptyBuilderAddress).getEncodedHTML(
            htmlRequest
        );
    }

    // solc-ignore-next-line func-mutability
    function getEncodedHTML_TagType_0_Many(
        HTMLRequest memory htmlRequest
    ) external {
        IScriptyBuilderV2(scriptyBuilderAddress).getEncodedHTML(
            htmlRequest
        );
    }

    // solc-ignore-next-line func-mutability
    function getEncodedHTML_TagType_1_Many(
        HTMLRequest memory htmlRequest
    ) external {
        IScriptyBuilderV2(scriptyBuilderAddress).getEncodedHTML(
            htmlRequest
        );
    }

    // solc-ignore-next-line func-mutability
    function getEncodedHTML_TagType_2_Many(
        HTMLRequest memory htmlRequest
    ) external {
        IScriptyBuilderV2(scriptyBuilderAddress).getEncodedHTML(
            htmlRequest
        );
    }

    // solc-ignore-next-line func-mutability
    function getHTMLURLSafe_Few(
        HTMLRequest memory htmlRequest
    ) external {
        IScriptyBuilderV2(scriptyBuilderAddress).getHTMLURLSafe(
            htmlRequest
        );
    }

    // solc-ignore-next-line func-mutability
    function getHTMLURLSafe_Many(
        HTMLRequest memory htmlRequest
    ) external {
        IScriptyBuilderV2(scriptyBuilderAddress).getHTMLURLSafe(
            htmlRequest
        );
    }
}
