// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "forge-std/Test.sol";

import {Ownable2StepUpgradeable} from "../src/Ownable2StepUpgradeable.sol";
import {IOwnable2StepUpgradeable} from "../src/IOwnable2StepUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";


contract OwnableTest is Ownable2StepUpgradeable {
    constructor(address _initialOwner) initializer {
        __Ownable_init(_initialOwner);
    }
}


contract Ownable2StepUpgradableTest is Test {
    Ownable2StepUpgradeable internal ownable;
    address internal owner;

    function setUp() external {
        owner = vm.addr(0x1);
        ownable = new OwnableTest(address(owner));
    }

    function test_init() external {
        assertEq(ownable.owner(), owner);
        assertEq(ownable.pendingOwner(), address(0));
    }

    function test_transferOwnership(address _newOwner) external {
        vm.assume(_newOwner != address(0));

        assertEq(ownable.owner(), owner);

        vm.prank(owner);
        ownable.transferOwnership(_newOwner);

        assertEq(ownable.owner(), _newOwner);
    }

    function test_transferOwnership_revertNotZeroAddress() external {
        vm.prank(owner);
        vm.expectRevert(
            IOwnable2StepUpgradeable.OWNER_CANNOT_BE_ZERO_ADDRESS.selector
        );
        ownable.transferOwnership(address(0));
    }

    function test_transferOwnership_revertOnlyOwner() external {
        vm.expectRevert(IOwnable2StepUpgradeable.ONLY_OWNER.selector);
        ownable.transferOwnership(vm.addr(0x2));
    }

    function test_safeTransferOwnership(address _newOwner) external {
        vm.assume(_newOwner != address(0));

        vm.prank(owner);
        ownable.safeTransferOwnership(_newOwner);

        assertEq(ownable.pendingOwner(), _newOwner);
        assertEq(ownable.owner(), owner);
    }

    function test_safeTransferOwnership_revertNotZeroAddress() external {
        vm.prank(owner);
        vm.expectRevert(
            IOwnable2StepUpgradeable.OWNER_CANNOT_BE_ZERO_ADDRESS.selector
        );
        ownable.safeTransferOwnership(address(0));
    }

    function test_safeTransferOwnership_revertOnlyOwner() external {
        vm.expectRevert(IOwnable2StepUpgradeable.ONLY_OWNER.selector);
        ownable.safeTransferOwnership(vm.addr(0x2));
    }

    function test_acceptOwnership(address _newOwner) external {
        vm.assume(_newOwner != address(0));

        vm.prank(owner);
        ownable.safeTransferOwnership(_newOwner);
        vm.prank(_newOwner);
        ownable.acceptOwnership();

        assertEq(ownable.owner(), _newOwner);
        assertEq(ownable.pendingOwner(), address(0));
    }

    function test_acceptOwnership_revertOnlyPendingOwner() external {
        vm.expectRevert(IOwnable2StepUpgradeable.ONLY_PENDING_OWNER.selector);
        ownable.acceptOwnership();
    }

    function test_cancelOwnershipTransfer() external {
        vm.prank(owner);
        ownable.safeTransferOwnership(vm.addr(0x2));
        vm.prank(owner);
        ownable.cancelOwnershipTransfer();

        assertEq(ownable.owner(), owner);
        assertEq(ownable.pendingOwner(), address(0));
    }

    function test_resignOwnership() external {
        vm.prank(owner);
        ownable.resignOwnership();

        assertEq(ownable.owner(), address(0));
        assertEq(ownable.pendingOwner(), address(0));
    }
}
