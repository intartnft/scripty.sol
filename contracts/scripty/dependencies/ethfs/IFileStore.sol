// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {File, BytecodeSlice} from "./File.sol";

/// @title EthFS FileStore interface
/// @notice Specifies a content-addressable onchain file store
interface IFileStore {
    /**
     * @notice Retrieves a file by its filename
     * @param filename The name of the file
     * @return file The file associated with the filename
     */
    function getFile(
        string memory filename
    ) external view returns (File memory file);
}