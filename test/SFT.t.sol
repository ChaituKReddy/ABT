// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "src/SFT.sol";

contract ContractTest is Test {
    SFT private SFTInterface;

    event Attest(address indexed _to, uint256 indexed _tokenId);
    event Revoke(address indexed _to, uint256 indexed _tokenId);
    event AdminChanged(address newAdmin, uint256 timestamp);

    function setUp() public {
        //Create new instance for testing
        SFTInterface = new SFT("Test", "TST");
    }

    function testDetails() public {
        string memory name = SFTInterface.name();
        assertEq(name, "Test", "Name not set correctly");
        string memory symbol = SFTInterface.symbol();
        assertEq(symbol, "TST", "Symbol not set correctly");
        address admin = SFTInterface.admin();
        assertEq(admin, address(this), "Admin not set correctly");
        assertEq(0, SFTInterface.tokenId(), "Initial token ID is not zero");
        bytes4 IERC4973Interface = type(IERC4973).interfaceId;
        assertEq(
            true,
            SFTInterface.supportsInterface(IERC4973Interface),
            "Interface setup not done correctly"
        );
        bytes4 IERC721MetadataInterface = type(IERC721Metadata).interfaceId;
        assertEq(
            true,
            SFTInterface.supportsInterface(IERC721MetadataInterface),
            "Interface setup not done correctly"
        );
    }

    function testRevertsAdmin() public {
        vm.expectRevert("Only admin");
        vm.prank(address(1));
        SFTInterface.changeAdmin(address(1));

        vm.expectRevert("Zero admin address");
        SFTInterface.changeAdmin(address(0));
    }

    function testAdmin(address newAdmin) public {
        vm.assume(newAdmin != address(0));
        SFTInterface.changeAdmin(newAdmin);
        vm.expectRevert("Only admin");
        SFTInterface.mint(newAdmin, "Test");

        vm.prank(newAdmin);
        SFTInterface.mint(newAdmin, "Test");
        assertEq(
            "Test",
            SFTInterface.tokenURI(1),
            "Token URI not set correctly"
        );
    }

    function testRevertsMint(string memory _uri) public {
        vm.expectRevert("Zero receiver address");
        SFTInterface.mint(address(0), _uri);

        vm.expectRevert("Only admin");
        vm.prank(address(1));
        SFTInterface.mint(address(0), _uri);
    }

    function testMints(address to, string memory uri) public {
        vm.assume(to != address(0));
        uint256 before = SFTInterface.tokenId();
        vm.expectEmit(true, false, false, true);
        emit Attest(to, 1);
        SFTInterface.mint(to, uri);
        uint256 tokenId = SFTInterface.tokenId();
        assertEq(before + 1, tokenId, "Mint: TokenId not incremented");
        assertEq(
            SFTInterface.ownerOf(tokenId),
            to,
            "Mint: Owner for token not set correctly"
        );
        assertEq(
            SFTInterface.tokenURI(tokenId),
            uri,
            "Mint: URI not set correctly"
        );
    }

    function testRevertsBurn(address to, string memory uri) public {
        testMints(to, uri);
        vm.expectRevert("Not the owner or admin");
        vm.prank(address(2));
        SFTInterface.burn(1);

        vm.expectRevert("ownerOf: token doesn't exist");
        SFTInterface.burn(2);
    }

    function testBurn(address to, string memory uri) public {
        testMints(to, uri);
        vm.expectEmit(true, false, false, false);
        emit Revoke(to, 1);
        SFTInterface.burn(1);

        testMints(to, uri);
        vm.expectEmit(true, false, false, false);
        emit Revoke(to, 2);
        vm.prank(to);
        SFTInterface.burn(2);

        vm.expectRevert("ownerOf: token doesn't exist");
        SFTInterface.ownerOf(2);
        vm.expectRevert("tokenURI: token doesn't exist");
        SFTInterface.tokenURI(2);
    }
}
