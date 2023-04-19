//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import {IScriptyBuilder, HeadRequest, InlineScriptRequest, WrappedScriptRequest} from "../scripty/IScriptyBuilder.sol";
import {IScriptyWrappedHTML} from "../scripty/IScriptyWrappedHTML.sol";

contract ScriptyBuilderGasTest {
    address public immutable scriptyWrappedHTMLAddress;

    constructor(address _scriptyWrappedHTMLAddress) {
        scriptyWrappedHTMLAddress = _scriptyWrappedHTMLAddress;
    }

    // // solc-ignore-next-line func-mutability
    // function getEncodedHTMLInline_Few(
    //     InlineScriptRequest[] calldata requests,
    //     uint256 bufferSize
    // ) external {
    //     IScriptyBuilder(scriptyCanvasBuilderAddress).getEncodedHTMLInline(
    //         requests,
    //         bufferSize
    //     );
    // }

    // // solc-ignore-next-line func-mutability
    // function getEncodedHTMLInline_Many(
    //     InlineScriptRequest[] calldata requests,
    //     uint256 bufferSize
    // ) external {
    //     IScriptyBuilder(scriptyCanvasBuilderAddress).getEncodedHTMLInline(
    //         requests,
    //         bufferSize
    //     );
    // }

    // ----------
    // ----------
    // ----------

    // solc-ignore-next-line func-mutability
    function getEncodedHTMLWrapped_WrapType_0_Few(
        HeadRequest[] calldata headRequests,
        WrappedScriptRequest[] calldata requests
    ) external {
        IScriptyWrappedHTML(scriptyWrappedHTMLAddress).getEncodedHTMLWrapped(
            headRequests,
            requests
        );
    }

    // solc-ignore-next-line func-mutability
    function getEncodedHTMLWrapped_WrapType_1_Few(
        HeadRequest[] calldata headRequests,
        WrappedScriptRequest[] calldata requests
    ) external {
        IScriptyWrappedHTML(scriptyWrappedHTMLAddress).getEncodedHTMLWrapped(
            headRequests,
            requests
        );
    }

    // solc-ignore-next-line func-mutability
    function getEncodedHTMLWrapped_WrapType_2_Few(
        HeadRequest[] calldata headRequests,
        WrappedScriptRequest[] calldata requests
    ) external {
        IScriptyWrappedHTML(scriptyWrappedHTMLAddress).getEncodedHTMLWrapped(
            headRequests,
            requests
        );
    }

    // solc-ignore-next-line func-mutability
    function getEncodedHTMLWrapped_WrapType_0_Many(
        HeadRequest[] calldata headRequests,
        WrappedScriptRequest[] calldata requests
    ) external {
        IScriptyWrappedHTML(scriptyWrappedHTMLAddress).getEncodedHTMLWrapped(
            headRequests,
            requests
        );
    }

    // solc-ignore-next-line func-mutability
    function getEncodedHTMLWrapped_WrapType_1_Many(
        HeadRequest[] calldata headRequests,
        WrappedScriptRequest[] calldata requests
    ) external {
        IScriptyWrappedHTML(scriptyWrappedHTMLAddress).getEncodedHTMLWrapped(
            headRequests,
            requests
        );
    }

    // solc-ignore-next-line func-mutability
    function getEncodedHTMLWrapped_WrapType_2_Many(
        HeadRequest[] calldata headRequests,
        WrappedScriptRequest[] calldata requests
    ) external {
        IScriptyWrappedHTML(scriptyWrappedHTMLAddress).getEncodedHTMLWrapped(
            headRequests,
            requests
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
