// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/**
 * @title AddressChunks
 * @author @xtremetom
 * @notice Reads chunk pointers and merges their values
 */
library AddressChunks {
    function mergeChunks(address[] memory chunks)
        internal
        view
        returns (bytes memory o_code)
    {
        unchecked {
            assembly {
                let len := mload(chunks)
                let totalSize := 0x20
                let size := 0
                o_code := mload(0x40)

                // loop through all chunk addresses
                // - get address
                // - get data size
                // - get code and add to o_code
                // - update total size
                let targetChunk := 0
                for {
                    let i := 0
                } lt(i, len) {
                    i := add(i, 1)
                } {
                    targetChunk := mload(add(chunks, add(0x20, mul(i, 0x20))))
                    size := sub(extcodesize(targetChunk), 1)
                    extcodecopy(targetChunk, add(o_code, totalSize), 1, size)
                    totalSize := add(totalSize, size)
                }

                // update o_code size
                mstore(o_code, sub(totalSize, 0x20))
                // store o_code
                mstore(0x40, add(o_code, and(add(totalSize, 0x1f), not(0x1f))))
            }
        }
    }
}
