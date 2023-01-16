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

    struct Script {
        bool isVerified;
        address owner;
        uint256 size;
        bytes details;
        address[] chunks;
    }

    // =============================================================
    //                            ERRORS
    // =============================================================

    /**
     * @notice Error for, The Script you are trying to create already exists
     */
    error ScriptExists();

    /**
     * @notice Error for, You dont have permissions to perform this action
     */
    error NotScriptOwner();

    // =============================================================
    //                            EVENTS
    // =============================================================

    /**
     * @notice Event for, Successful update of script verification status
     * @param name - Name given to the script. Eg: threejs.min.js_r148
     * @param isVerified - Verification status of the script
     */
    event ScriptVerificationUpdated(string indexed name, bool isVerified);

    /**
     * @notice Event for, Successful creation of a script
     * @param name - Name given to the script. Eg: threejs.min.js_r148
     * @param owner - Address of the script owner
     * @param details - Custom details of the script
     */
    event ScriptCreated(string indexed name, address owner, bytes details);

    /**
     * @notice Event for, Successful addition of script chunk
     * @param name - Name given to the script. Eg: threejs.min.js_r148
     * @param size - Bytes size of the chunk
     */
    event ChunkStored(string indexed name, uint256 size);

    /**
     * @notice Event for, Successful update of custom details
     * @param name - Name given to the script. Eg: threejs.min.js_r148
     * @param owner - Address of the script owner
     * @param details - Custom details of the script
     */
    event ScriptDetailsUpdated(
        string indexed name,
        address owner,
        bytes details
    );

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
        external;

    /**
     * @notice Add a code chunk to the script
     * @param name - Name given to the script. Eg: threejs.min.js_r148
     * @param chunk - Next sequential code chunk
     *
     * Emits an {ChunkStored} event.
     */
    function addChunkToScript(string calldata name, bytes calldata chunk)
        external;

    /**
     * @notice Edit the script details
     * @param name - Name given to the script. Eg: threejs.min.js_r148
     * @param details - Any details the owner wishes to store about the script
     *
     * Emits an {ScriptDetailsUpdated} event.
     */
    function updateDetails(string calldata name, bytes calldata details)
        external;

    /**
     * @notice Update the verification status of the script
     * @param name - Name given to the script. Eg: threejs.min.js_r148
     * @param isVerified - The verification status
     *
     * Emits an {ScriptVerificationUpdated} event.
     */
    function updateScriptVerification(string calldata name, bool isVerified)
        external;
}
