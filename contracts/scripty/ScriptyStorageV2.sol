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
//░░░░░░░░░░░░░░░░░░░░    STORAGE    ░░░░░░░░░░░░░░░░░░░░//
///////////////////////////////////////////////////////////

/**
  @title A generic data storage contract
  @author @xtremetom
  @author @0xthedude

  Built on top FileStore from EthFS V2. Chunk pointers
  are deterministic and using the EthFS's salt.

  Special thanks to @frolic, @cxkoda and @dhof.
*/

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IFileStore} from "./dependencies/ethfs/IFileStore.sol";
import "./dependencies/ethfs/common.sol";
import {AddressChunks} from "./utils/AddressChunks.sol";

import {IScriptyStorage} from "./interfaces/IScriptyStorage.sol";
import {IScriptyContractStorage} from "./interfaces/IScriptyContractStorage.sol";

contract ScriptyStorageV2 is Ownable, IScriptyStorage, IScriptyContractStorage {
    IFileStore public immutable ethfsFileStore;
    mapping(string => Content) public contents;

    constructor(IFileStore ethfsFileStore_) {
        ethfsFileStore = IFileStore(ethfsFileStore_);
    }

    // =============================================================
    //                           MODIFIERS
    // =============================================================

    /**
     * @notice Check if the msg.sender is the owner of the content
     * @param name - Name given to the content. Eg: threejs.min.js_r148
     */
    modifier isContentOwner(string calldata name) {
        if (msg.sender != contents[name].owner) revert NotContentOwner();
        _;
    }

    /**
     * @notice Check if a content can be created by checking if it already exists
     * @param name - Name given to the content. Eg: threejs.min.js_r148
     */
    modifier canCreate(string calldata name) {
        if (contents[name].owner != address(0)) revert ContentExists();
        _;
    }

    /**
     * @notice Check if a content is frozen
     * @param name - Name given to the content. Eg: threejs.min.js_r148
     */
    modifier isFrozen(string calldata name) {
        if (contents[name].isFrozen) revert ContentIsFrozen(name);
        _;
    }

    // =============================================================
    //                      MANAGEMENT OPERATIONS
    // =============================================================

    /**
     * @notice Create a new content
     * @param name - Name given to the content. Eg: threejs.min.js_r148
     * @param details - Any details the owner wishes to store about the content
     *
     * Emits an {ContentCreated} event.
     */
    function createContent(
        string calldata name,
        bytes calldata details
    ) public canCreate(name) {
        contents[name] = Content(
            false,
            msg.sender,
            0,
            details,
            new address[](0)
        );
        emit ContentCreated(name, details);
    }

    /**
     * @notice Add a code chunk to the content
     * @param name - Name given to the content. Eg: threejs.min.js_r148
     * @param chunk - Next sequential code chunk
     *
     * Emits an {ChunkStored} event.
     */
    function addChunkToContent(
        string calldata name,
        bytes calldata chunk
    ) public isFrozen(name) isContentOwner(name) {
        address pointer = addContent(ethfsFileStore.deployer(), chunk);
        contents[name].chunks.push(pointer);
        contents[name].size += chunk.length;
        emit ChunkStored(name, chunk.length);
    }

    /**
     * @notice Edit the content details
     * @param name - Name given to the content. Eg: threejs.min.js_r148
     * @param details - Any details the owner wishes to store about the content
     *
     * Emits an {ContentDetailsUpdated} event.
     */
    function updateDetails(
        string calldata name,
        bytes calldata details
    ) public isFrozen(name) isContentOwner(name) {
        contents[name].details = details;
        emit ContentDetailsUpdated(name, details);
    }

    /**
     * @notice Update the frozen status of the content
     * @dev [WARNING] Once a content it frozen is can no longer be edited
     * @param name - Name given to the content. Eg: threejs.min.js_r148
     *
     * Emits an {ContentFrozen} event.
     */
    function freezeContent(
        string calldata name
    ) public isFrozen(name) isContentOwner(name) {
        contents[name].isFrozen = true;
        emit ContentFrozen(name);
    }

    /**
     * @notice Add a code chunk to the content
     * @param name - Name given to the content. Eg: threejs.min.js_r148
     * @param metadata - metadata for EthFS V2 File
     *
     * Emits an {ContentSubmittedToFileStore} event.
     */
    function submitToEthFSFileStore(
        string calldata name,
        bytes memory metadata
    ) public isContentOwner(name) {
        Content memory content = contents[name];
        ethfsFileStore.createFileFromPointers(
            name,
            content.chunks,
            metadata
        );
        contents[name].isFrozen = true;
        emit ContentSubmittedToEthFSFileStore(name, name);
    }

    /**
     * @notice Add a code chunk to the content
     * @param name - Name given to the content. Eg: threejs.min.js_r148
     * @param fileName - Name given to the File in FileStore
     * @param metadata - metadata for EthFS V2 File
     *
     * Emits an {ContentSubmittedToFileStore} event.
     */
    function submitToEthFSFileStoreWithFileName(
        string calldata name,
        string calldata fileName,
        bytes memory metadata
    ) public isContentOwner(name) {
        Content memory content = contents[name];
        ethfsFileStore.createFileFromPointers(
            fileName,
            content.chunks,
            metadata
        );
        contents[name].isFrozen = true;
        emit ContentSubmittedToEthFSFileStore(name, name);
    }

    // =============================================================
    //                            GETTERS
    // =============================================================

    /**
     * @notice Get the full content
     * @param name - Name given to the content. Eg: threejs.min.js_r148
     * @param data - Arbitrary data. Not used by this contract.
     * @return content - Full content from merged chunks
     */
    function getContent(
        string memory name,
        bytes memory data
    ) public view returns (bytes memory content) {
        return AddressChunks.mergeChunks(contents[name].chunks);
    }

    /**
     * @notice Get content's chunk pointer list
     * @param name - Name given to the content. Eg: threejs.min.js_r148
     * @return pointers - List of pointers
     */
    function getContentChunkPointers(
        string memory name
    ) public view returns (address[] memory pointers) {
        return contents[name].chunks;
    }
}
