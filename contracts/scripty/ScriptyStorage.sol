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

/**
  @title A generic data storage contract.
  @author @xtremetom
  @author @0xthedude
*/

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IContentStore} from "./dependencies/ethfs/IContentStore.sol";
import {AddressChunks} from "./utils/AddressChunks.sol";

import {IScriptyStorage} from "./IScriptyStorage.sol";
import {IContractScript} from "./IContractScript.sol";

contract ScriptyStorage is Ownable, IScriptyStorage, IContractScript {
    IContentStore public immutable contentStore;
    mapping(string => Script) public scripts;

    constructor(address _contentStoreAddress) {
        contentStore = IContentStore(_contentStoreAddress);
    }

    // =============================================================
    //                           MODIFIERS
    // =============================================================

    /**
     * @notice Check if the msg.sender is the owner of the script
     * @param name - Name given to the script. Eg: threejs.min.js_r148
     */
    modifier scriptOwner(string memory name) {
        if (msg.sender != scripts[name].owner) revert NotScriptOwner();
        _;
    }

    /**
     * @notice Check if a script can be created by checking if it already exists
     * @param name - Name given to the script. Eg: threejs.min.js_r148
     */
    modifier canCreate(string memory name) {
        if (scripts[name].owner != address(0)) revert ScriptExists();
        _;
    }

    // =============================================================
    //                      MANAGEMENT OPERATIONS
    // =============================================================

    /**
     * @notice Create a new script
     * @param name - Name given to the script. Eg: threejs.min.js_r148
     * @param details - Any details the owner wishes to store about the script
     *
     * Emits an {ScriptCreated} event.
     */
    function createScript(string calldata name, bytes calldata details)
        public
        canCreate(name)
    {
        scripts[name] = Script(false, msg.sender, 0, details, new address[](0));
        emit ScriptCreated(name, msg.sender, details);
    }

    /**
     * @notice Add a code chunk to the script
     * @param name - Name given to the script. Eg: threejs.min.js_r148
     * @param chunk - Next sequential code chunk
     *
     * Emits an {ChunkStored} event.
     */
    function addChunkToScript(string calldata name, bytes calldata chunk)
        public
        scriptOwner(name)
    {
        (, address pointer) = contentStore.addContent(chunk);
        scripts[name].chunks.push(pointer);
        scripts[name].size += chunk.length;
        emit ChunkStored(name, chunk.length);
    }

    /**
     * @notice Edit the script details
     * @param name - Name given to the script. Eg: threejs.min.js_r148
     * @param details - Any details the owner wishes to store about the script
     *
     * Emits an {ScriptDetailsUpdated} event.
     */
    function updateDetails(string calldata name, bytes calldata details)
        public
        scriptOwner(name)
    {
        scripts[name].details = details;
        emit ScriptDetailsUpdated(name, msg.sender, details);
    }

    /**
     * @notice Update the verification status of the script
     * @param name - Name given to the script. Eg: threejs.min.js_r148
     * @param isVerified - The verification status
     *
     * Emits an {ScriptVerificationUpdated} event.
     */
    function updateScriptVerification(string calldata name, bool isVerified)
        public
        onlyOwner
    {
        scripts[name].isVerified = isVerified;
        emit ScriptVerificationUpdated(name, isVerified);
    }

    // =============================================================
    //                            GETTERS
    // =============================================================

    /**
     * @notice Get the full script
     * @param name - Name given to the script. Eg: threejs.min.js_r148
     * @param data - Arbitrary data. Not used by this contract.
     * @return script - Full script from merged chunks
     */
    function getScript(string memory name, bytes memory data)
        public
        view
        returns (bytes memory script)
    {
        return AddressChunks.mergeChunks(scripts[name].chunks);
    }


    /**
     * @notice Get script's chunk pointer list
     * @param name - Name given to the script. Eg: threejs.min.js_r148
     * @return pointers - List of pointers
     */
    function getScriptChunkPointers(string memory name)
        public
        view
        returns (address[] memory pointers)
    {
        return scripts[name].chunks;
    }
}
