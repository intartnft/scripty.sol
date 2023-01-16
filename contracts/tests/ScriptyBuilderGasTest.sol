//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import {IScriptyBuilder, InlineScriptRequest, WrappedScriptRequest} from "../scripty/IScriptyBuilder.sol";

contract ScriptyBuilderGasTest {
    address public immutable scriptyCanvasBuilderAddress;

    constructor(address _scriptyCanvasBuilderAddress) {
        scriptyCanvasBuilderAddress = _scriptyCanvasBuilderAddress;
    }

    // solc-ignore-next-line func-mutability
    function getEncodedHTMLInline_Few(
        InlineScriptRequest[] calldata requests,
        uint256 bufferSize
    ) external {
        IScriptyBuilder(scriptyCanvasBuilderAddress).getEncodedHTMLInline(
            requests,
            bufferSize
        );
    }

    // solc-ignore-next-line func-mutability
    function getEncodedHTMLInline_Many(
        InlineScriptRequest[] calldata requests,
        uint256 bufferSize
    ) external {
        IScriptyBuilder(scriptyCanvasBuilderAddress).getEncodedHTMLInline(
            requests,
            bufferSize
        );
    }

    // ----------
    // ----------
    // ----------

    // solc-ignore-next-line func-mutability
    function getEncodedHTMLWrapped_WrapType_0_Few(
        WrappedScriptRequest[] calldata requests,
        uint256 bufferSize
    ) external {
        IScriptyBuilder(scriptyCanvasBuilderAddress).getEncodedHTMLWrapped(
            requests,
            bufferSize
        );
    }

    // solc-ignore-next-line func-mutability
    function getEncodedHTMLWrapped_WrapType_1_Few(
        WrappedScriptRequest[] calldata requests,
        uint256 bufferSize
    ) external {
        IScriptyBuilder(scriptyCanvasBuilderAddress).getEncodedHTMLWrapped(
            requests,
            bufferSize
        );
    }

    // solc-ignore-next-line func-mutability
    function getEncodedHTMLWrapped_WrapType_2_Few(
        WrappedScriptRequest[] calldata requests,
        uint256 bufferSize
    ) external {
        IScriptyBuilder(scriptyCanvasBuilderAddress).getEncodedHTMLWrapped(
            requests,
            bufferSize
        );
    }

    // solc-ignore-next-line func-mutability
    function getEncodedHTMLWrapped_WrapType_0_Many(
        WrappedScriptRequest[] calldata requests,
        uint256 bufferSize
    ) external {
        IScriptyBuilder(scriptyCanvasBuilderAddress).getEncodedHTMLWrapped(
            requests,
            bufferSize
        );
    }

    // solc-ignore-next-line func-mutability
    function getEncodedHTMLWrapped_WrapType_1_Many(
        WrappedScriptRequest[] calldata requests,
        uint256 bufferSize
    ) external {
        IScriptyBuilder(scriptyCanvasBuilderAddress).getEncodedHTMLWrapped(
            requests,
            bufferSize
        );
    }

    // solc-ignore-next-line func-mutability
    function getEncodedHTMLWrapped_WrapType_2_Many(
        WrappedScriptRequest[] calldata requests,
        uint256 bufferSize
    ) external {
        IScriptyBuilder(scriptyCanvasBuilderAddress).getEncodedHTMLWrapped(
            requests,
            bufferSize
        );
    }

    // solc-ignore-next-line func-mutability
    function getHTMLWrappedURLSafe_PNG_URLSAFE(
        WrappedScriptRequest[] calldata requests,
        uint256 bufferSize
    ) external {
        IScriptyBuilder(scriptyCanvasBuilderAddress).getHTMLWrappedURLSafe(
            requests,
            bufferSize
        );
    }

    // solc-ignore-next-line func-mutability
    function getEncodedHTMLWrapped_GZIP_BASE64(
        WrappedScriptRequest[] calldata requests,
        uint256 bufferSize
    ) external {
        IScriptyBuilder(scriptyCanvasBuilderAddress).getEncodedHTMLWrapped(
            requests,
            bufferSize
        );
    }

    // solc-ignore-next-line func-mutability
    function getHTMLWrappedURLSafe_GZIP_URLSAFE(
        WrappedScriptRequest[] calldata requests,
        uint256 bufferSize
    ) external {
        IScriptyBuilder(scriptyCanvasBuilderAddress).getHTMLWrappedURLSafe(
            requests,
            bufferSize
        );
    }
}
