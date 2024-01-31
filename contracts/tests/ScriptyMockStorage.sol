// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

///////////////////////////////////////////////////////////
// ░██████╗░█████╗░██████╗░██╗██████╗░████████╗██╗░░░██╗ //
// ██╔════╝██╔══██╗██╔══██╗██║██╔══██╗╚══██╔══╝╚██╗░██╔╝ //
// ╚█████╗░██║░░╚═╝██████╔╝██║██████╔╝░░░██║░░░░╚████╔╝░ //
// ░╚═══██╗██║░░██╗██╔══██╗██║██╔═══╝░░░░██║░░░░░╚██╔╝░░ //
// ██████╔╝╚█████╔╝██║░░██║██║██║░░░░░░░░██║░░░░░░██║░░░ //
// ╚═════╝░░╚════╝░╚═╝░░╚═╝╚═╝╚═╝░░░░░░░░╚═╝░░░░░░╚═╝░░░ //
///////////////////////////////////////////////////////////

/**
  USED ONLY FOR TESTS
*/

import {IScriptyContractStorage} from "./../scripty/interfaces/IScriptyContractStorage.sol";
import {AddressChunks} from "./../scripty/utils/AddressChunks.sol";
import {SSTORE2} from "solady/src/utils/SSTORE2.sol";

contract ScriptyMockStorage is IScriptyContractStorage {
    mapping(string => address[]) contents;

    function addChunkToContent(
        string calldata name,
        bytes calldata chunk
    ) public {
        address pointer = SSTORE2.write(chunk);
        contents[name].push(pointer);
    }

    function getContent(
        string memory name,
        bytes memory data
    ) public view returns (bytes memory content) {
        return AddressChunks.mergeChunks(contents[name]);
    }
}
