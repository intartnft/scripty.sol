//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import {HTMLRequest, HeadRequest, ScriptRequest} from "../scripty/ScriptyCore.sol";
import {IScriptyWrappedHTML} from "../scripty/interfaces/IScriptyWrappedHTML.sol";
import {IScriptyInlineHTML} from "../scripty/interfaces/IScriptyInlineHTML.sol";

contract ScriptyBuilderGasTest {
    address public immutable scriptyWrappedHTMLAddress;
    address public immutable scriptyInlineHTMLAddress;

    constructor(
        address _scriptyWrappedHTMLAddress,
        address _scriptyInlineHTMLAddress
    ) {
        scriptyWrappedHTMLAddress = _scriptyWrappedHTMLAddress;
        scriptyInlineHTMLAddress = _scriptyInlineHTMLAddress;
    }

    // solc-ignore-next-line func-mutability
    function getEncodedHTMLInline_Few(
        HTMLRequest memory htmlRequest
    ) external {
        IScriptyInlineHTML(scriptyInlineHTMLAddress).getEncodedHTMLInline(
            htmlRequest
        );
    }

    // solc-ignore-next-line func-mutability
    function getEncodedHTMLInline_Many(
        HTMLRequest memory htmlRequest
    ) external {
        IScriptyInlineHTML(scriptyInlineHTMLAddress).getEncodedHTMLInline(
            htmlRequest
        );
    }

    // ----------
    // ----------
    // ----------

    // solc-ignore-next-line func-mutability
    function getEncodedHTMLWrapped_WrapType_0_Few(
        HTMLRequest memory htmlRequest
    ) external {
        IScriptyWrappedHTML(scriptyWrappedHTMLAddress).getEncodedHTMLWrapped(
            htmlRequest
        );
    }

    // solc-ignore-next-line func-mutability
    function getEncodedHTMLWrapped_WrapType_1_Few(
        HTMLRequest memory htmlRequest
    ) external {
        IScriptyWrappedHTML(scriptyWrappedHTMLAddress).getEncodedHTMLWrapped(
            htmlRequest
        );
    }

    // solc-ignore-next-line func-mutability
    function getEncodedHTMLWrapped_WrapType_2_Few(
        HTMLRequest memory htmlRequest
    ) external {
        IScriptyWrappedHTML(scriptyWrappedHTMLAddress).getEncodedHTMLWrapped(
            htmlRequest
        );
    }

    // solc-ignore-next-line func-mutability
    function getEncodedHTMLWrapped_WrapType_0_Many(
        HTMLRequest memory htmlRequest
    ) external {
        IScriptyWrappedHTML(scriptyWrappedHTMLAddress).getEncodedHTMLWrapped(
            htmlRequest
        );
    }

    // solc-ignore-next-line func-mutability
    function getEncodedHTMLWrapped_WrapType_1_Many(
        HTMLRequest memory htmlRequest
    ) external {
        IScriptyWrappedHTML(scriptyWrappedHTMLAddress).getEncodedHTMLWrapped(
            htmlRequest
        );
    }

    // solc-ignore-next-line func-mutability
    function getEncodedHTMLWrapped_WrapType_2_Many(
        HTMLRequest memory htmlRequest
    ) external {
        IScriptyWrappedHTML(scriptyWrappedHTMLAddress).getEncodedHTMLWrapped(
            htmlRequest
        );
    }

    // // solc-ignore-next-line func-mutability
    // function getHTMLWrappedURLSafe_PNG_URLSAFE(
    //     WrappedScriptRequest[] calldata requests,
    //     uint256 bufferSize
    // ) external {
    //     IScriptyBuilder(scriptyCanvasBuilderAddress).getHTMLWrappedURLSafe(
    //         requests,
    //         bufferSize
    //     );
    // }

    // // solc-ignore-next-line func-mutability
    // function getEncodedHTMLWrapped_GZIP_BASE64(
    //     WrappedScriptRequest[] calldata requests,
    //     uint256 bufferSize
    // ) external {
    //     IScriptyBuilder(scriptyCanvasBuilderAddress).getEncodedHTMLWrapped(
    //         requests,
    //         bufferSize
    //     );
    // }

    // // solc-ignore-next-line func-mutability
    // function getHTMLWrappedURLSafe_GZIP_URLSAFE(
    //     WrappedScriptRequest[] calldata requests,
    //     uint256 bufferSize
    // ) external {
    //     IScriptyBuilder(scriptyCanvasBuilderAddress).getHTMLWrappedURLSafe(
    //         requests,
    //         bufferSize
    //     );
    // }
}
