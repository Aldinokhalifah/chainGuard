// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/access/AccessControl.sol";

contract ChainGuardRegistry is AccessControl {
    bytes32 public constant AUDITOR_ROLE = keccak256("AUDITOR_ROLE");
    mapping(uint256 => AuditRecord) public audits;
    uint256 public auditCount;

    struct AuditRecord {
        bytes32 reportHash;
        address contractAddress;
        uint8 score;
        address auditor;
        uint256 timestamp;
    }

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    
}