// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.28;

import "forge-std/Test.sol";
import "../src/ChainGuardRegistry.sol";
import "@openzeppelin/contracts/access/IAccessControl.sol";

contract ChainGuardRegistryTest is Test {
    ChainGuardRegistry chainGuardRegistry;
    address admin;
    address auditor;
    address nonAuditor;

    event AuditPublished(
        uint256 indexed auditId,
        address indexed contractAddress,
        address indexed auditor,
        bytes32 reportHash,
        uint8 score
    );

    function setUp() public {
        admin = makeAddr("admin");
        auditor = makeAddr("auditor");
        nonAuditor = makeAddr("nonAuditor");

        vm.prank(admin);

        chainGuardRegistry = new ChainGuardRegistry();
    }

    function testAdminHasDefaultAdminRole() public view {
        assertTrue(
            chainGuardRegistry.hasRole(chainGuardRegistry.DEFAULT_ADMIN_ROLE(), admin)
        );
    }

    function testAdminCanGrantAuditorRole() public {
        bytes32 auditor_role = chainGuardRegistry.AUDITOR_ROLE();
        
        vm.prank(admin);

        chainGuardRegistry.grantRole(auditor_role, auditor);

        assertTrue(
            chainGuardRegistry.hasRole(auditor_role, auditor)
        );
    }

    function testAuditorCanPublishAudit() public {
        bytes32 auditor_role = chainGuardRegistry.AUDITOR_ROLE();
        
        vm.prank(admin);

        chainGuardRegistry.grantRole(auditor_role, auditor);

        address dummyAddress = makeAddr("dummy address");

        vm.prank(auditor);

        chainGuardRegistry.publishAudit(keccak256("dummy report"), dummyAddress, 80);

        (bytes32 reportHash, address contractAddress, uint8 score, address auditorAddr, uint256 timestamp) = chainGuardRegistry.audits(1);

        assertEq(chainGuardRegistry.auditCount(), 1);
        assertEq(reportHash, keccak256("dummy report"));
        assertEq(contractAddress, dummyAddress);
        assertEq(score, 80);
        assertEq(auditorAddr, auditor);
        assertGt(timestamp, 0);
    }

    function testNonAuditorCannotPublishAudit() public {
        bytes32 auditorRole = chainGuardRegistry.AUDITOR_ROLE();
        address dummyAddress = makeAddr("dummy address");

        vm.expectRevert(
            abi.encodeWithSelector(
                IAccessControl.AccessControlUnauthorizedAccount.selector,
                nonAuditor,
                auditorRole
            )
        );

        vm.prank(nonAuditor);
        chainGuardRegistry.publishAudit(keccak256("dummy report"), dummyAddress, 80);
    }

    function testPublishAuditEmitsEvent() public {
        bytes32 auditorRole = chainGuardRegistry.AUDITOR_ROLE();
        vm.prank(admin);
        chainGuardRegistry.grantRole(auditorRole, auditor);

        address dummyAddress = makeAddr("dummy address");
        bytes32 reportHash = keccak256("dummy report");
        uint8 score = 80;

        vm.expectEmit(true, true, true, true, address(chainGuardRegistry));
        emit ChainGuardRegistry.AuditPublished(1, dummyAddress, auditor, reportHash, score);

        vm.prank(auditor);
        chainGuardRegistry.publishAudit(reportHash, dummyAddress, score);
    }
}