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

interface IScriptyStorage {
    // =============================================================
    //                            STRUCTS
    // =============================================================

    struct Content {
        bool isFrozen;
        address owner;
        uint256 size;
        bytes details;
        address[] chunks;
    }

    // =============================================================
    //                            ERRORS
    // =============================================================

    /**
     * @notice Error for, The content you are trying to create already exists
     */
    error ContentExists();

    /**
     * @notice Error for, You dont have permissions to perform this action
     */
    error NotContentOwner();

    /**
     * @notice Error for, The content you are trying to edit is frozen
     */
    error ContentIsFrozen(string name);

    // =============================================================
    //                            EVENTS
    // =============================================================

    /**
     * @notice Event for, Successful freezing of a content
     * @param name - Name given to the content. Eg: threejs.min.js_r148
     */
    event ContentFrozen(string indexed name);

    /**
     * @notice Event for, Successful creation of a content
     * @param name - Name given to the content. Eg: threejs.min.js_r148
     * @param details - Custom details of the content
     */
    event ContentCreated(string indexed name, bytes details);

    /**
     * @notice Event for, Successful addition of content chunk
     * @param name - Name given to the content. Eg: threejs.min.js_r148
     * @param size - Bytes size of the chunk
     */
    event ChunkStored(string indexed name, uint256 size);

    /**
     * @notice Event for, Successful update of custom details
     * @param name - Name given to the content. Eg: threejs.min.js_r148
     * @param details - Custom details of the content
     */
    event ContentDetailsUpdated(string indexed name, bytes details);

    /**
     * @notice Event for, submitting content to EthFS FileStore
     * @param name - Name given to the content. Eg: threejs.min.js_r148
     * @param fileName - Name given to the file in File Store.
     */
    event ContentSubmittedToEthFSFileStore(string indexed name, string indexed fileName);

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
    ) external;

    /**
     * @notice Add a content chunk to the content
     * @param name - Name given to the content. Eg: threejs.min.js_r148
     * @param chunk - Next sequential content chunk
     *
     * Emits an {ChunkStored} event.
     */
    function addChunkToContent(
        string calldata name,
        bytes calldata chunk
    ) external;

    /**
     * @notice Submit content to EthFS V2 FileStore
     * @param name - Name given to the content. Eg: threejs.min.js_r148
     * @param metadata - metadata for EthFS V2 File
     *
     * Uses name as file name.
     * Emits an {ContentSubmittedToFileStore} event.
     */
    function submitToEthFSFileStore(
        string calldata name,
        bytes memory metadata
    ) external;

    /**
     * @notice Submit content to EthFS V2 FileStore
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
    ) external;
}
