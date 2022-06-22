# Account Bound Tokens

<p> ABT or Soul Bound tokens are non-transferrable tokens that - once assigned cannot be transferred to any other accounts. The holder of the token can burn the token. These tokens can be used to represent identity.</p>

## Interfaces used:

1.  IERC165
2.  IERC721Metadata
3.  IERC4973

## Functions

### Constructor

| Name     | Type   | Description          |
| -------- | ------ | -------------------- |
| \_name   | string | Name for the token   |
| \_symbol | string | Symbol for the token |

<p> Registers the IERC4973, IERC721Metadata interface ID to the ERC165Storage contract and sets the deployer of the contract as the admin. </p>

### Name

```solidity
function name() public view returns(string memory)
```

Returns the name of the token.

### Symbol

```solidity
function symbol() public view returns(string memory)
```

Returns the symbol of the token.

### TokenId

```solidity
function tokenId() public view returns(uint256)
```

Returns the current tokenId that is minted.

### Admin

```solidity
function admin() public view returns(address)
```

Returns the current admin of the contract.

### ChangeAdmin

```solidity
function changeAdmin(address newAdmin) external onlyAdmin
```

| Name     | Type    | Description               |
| -------- | ------- | ------------------------- |
| newAdmin | address | New address for the admin |

Allows the `admin` of the contract to change the current admin role.

### Mint

```solidity
function mint(address _to, string memory _uri) external onlyAdmin
```

| Name  | Type    | Description                  |
| ----- | ------- | ---------------------------- |
| \_to  | address | Address to mint the token to |
| \_uri | string  | URI for the token            |

Allows the `admin` of the contract to mint new token to the `_to` address.

### Burn

```solidity
function burn(uint256 _tokenId) external
```

| Name      | Type    | Description      |
| --------- | ------- | ---------------- |
| \_tokenId | uint256 | Token Id to burn |

Allows the `admin` of the contract or the owner of the token to burn the token.

### OwnerOf

```solidity
function ownerOf(uint256 _tokenId) public view returns (address)
```

| Name      | Type    | Description |
| --------- | ------- | ----------- |
| \_tokenId | uint256 | Token Id    |

Returns the owner of particular token if it exits.

### OwnerOf

```solidity
function tokenURI(uint256 _tokenId) external view returns (string memory)
```

| Name      | Type    | Description |
| --------- | ------- | ----------- |
| \_tokenId | uint256 | Token Id    |

Returns the uri of particular token if it exits.

# Testing

### Run forge tests

```
forge test
```