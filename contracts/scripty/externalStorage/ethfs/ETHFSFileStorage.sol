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

import {IFileStore} from "./../../dependencies/ethfs/IFileStore.sol";
import {IContractScript} from "./../../IContractScript.sol";

contract ETHFSFileStorage is IContractScript {
    IFileStore public immutable fileStore;

    constructor(address _fileStoreAddress) {
        fileStore = IFileStore(_fileStoreAddress);
    }

    // =============================================================
    //                            GETTERS
    // =============================================================

    /**
     * @notice Get the full script from ethfs's FileStore contract
     * @param name - Name given to the script. Eg: threejs.min.js_r148
     * @param data - Arbitrary data. Not used by this contract.
     * @return script - Full script from merged chunks
     */
    function getScript(
        string calldata name,
        bytes memory data
    ) external view returns (bytes memory script) {
        return bytes(fileStore.getFile(name).read());
    }
}