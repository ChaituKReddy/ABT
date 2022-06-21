// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override
        returns (bool)
    {
        return interfaceId == type(IERC165).interfaceId;
    }
}

abstract contract ERC165Storage is ERC165 {
    mapping(bytes4 => bool) private _supportsInterface;

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override
        returns (bool)
    {
        return
            super.supportsInterface(interfaceId) ||
            _supportsInterface[interfaceId];
    }

    function _registerInterface(bytes4 interfaceId) internal {
        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportsInterface[interfaceId] = true;
    }
}

interface IERC721Metadata {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function tokenURI(uint256 _tokenId) external view returns (string memory);
}

interface IERC4973 {
    event Attest(address indexed _to, uint256 indexed _tokenId);
    event Revoke(address indexed _to, uint256 indexed _tokenId);

    function ownerOf(uint256 _tokenId) external view returns (address);

    function burn(uint256 _tokenId) external;
}

contract SFT is ERC165Storage, IERC721Metadata, IERC4973 {
    string public name;
    string public symbol;
    uint256 public tokenId;
    address public admin;

    mapping(uint256 => address) private _owners;
    mapping(uint256 => string) private _tokenURI;

    event AdminChanged(address newAdmin, uint256 timestamp);

    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
        admin = msg.sender;
        _registerInterface(type(IERC721Metadata).interfaceId);
        _registerInterface(type(IERC4973).interfaceId);
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin");
        _;
    }

    function changeAdmin(address newAdmin) external onlyAdmin {
        require(newAdmin != address(0), "Zero admin address");
        admin = newAdmin;
        emit AdminChanged(newAdmin, block.timestamp);
    }

    function mint(address _to, string memory _uri) external onlyAdmin {
        require(_to != address(0), "Zero receiver address");
        tokenId++;
        _owners[tokenId] = _to;
        _tokenURI[tokenId] = _uri;
        emit Attest(_to, tokenId);
    }

    function burn(uint256 _tokenId) external {
        require(
            ownerOf(_tokenId) == msg.sender || msg.sender == admin,
            "Not the owner or admin"
        );
        address _to = _owners[_tokenId];
        delete _owners[_tokenId];
        delete _tokenURI[_tokenId];
        emit Revoke(_to, _tokenId);
    }

    function ownerOf(uint256 _tokenId) public view returns (address) {
        address owner = _owners[_tokenId];
        require(owner != address(0), "ownerOf: token doesn't exist");
        return owner;
    }

    function tokenURI(uint256 _tokenId) external view returns (string memory) {
        address owner = _owners[_tokenId];
        require(owner != address(0), "tokenURI: token doesn't exist");
        return _tokenURI[_tokenId];
    }
}
