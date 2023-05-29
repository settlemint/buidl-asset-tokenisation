// SPDX-License-Identifier: MIT
// SettleMint.com
/**
 * Copyright (C) SettleMint NV - All Rights Reserved
 *
 * Use of this file is strictly prohibited without an active license agreement.
 * Distribution of this file, via any medium, is strictly prohibited.
 *
 * For license inquiries, contcontact hello@settlemint.com
 */

pragma solidity ^0.8.13;

import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/ERC1155SupplyUpgradeable.sol";
import "hardhat/console.sol";

contract AssetTokenization is Initializable, UUPSUpgradeable, ERC1155SupplyUpgradeable, OwnableUpgradeable {
  using StringsUpgradeable for uint256;

  struct Asset {
    uint256 assetId;                                    // Unique identifier number
    uint256 maxSupply;                                  // Maximum number of tokens for the asset
    uint256 faceValue;                                  // Initial value of the asset 
    uint256 maturityTimestamp;                          // Maturity date in the value of a unix time stamp
  }

  string public name;                                   // Name of your asset
  string public symbol;                                 // Symbol of your asset 

  mapping(uint256 => Asset) public assetToDetails;      // Array of assets mapped to Asset structure

  // Event to be emitted on asset transfer
  event AssetTransferEvent(       
    address operator,
    address from,
    address to,
    uint256[] assetIds,
    uint256[] amounts,
    bytes data
  );

  /**
  @dev Initializes the contract by setting the initial name, symbol, and URI of the contract.
  @param name_ Name of the asset token
  @param symbol_ Symbol of the asset token
  @param uri_ URI for the asset token
  */
  function initialize(
    string memory name_,
    string memory symbol_,
    string memory uri_
  ) external initializer {
    __ERC1155_init(uri_);
    __Ownable_init();
    name = name_;
    symbol = symbol_;
  }

  /**
  @dev Creates an asset with the specified details
  @param assetId Unique identifier number for the asset
  @param maxSupply Maximum number of tokens for the asset
  @param faceValue Initial value of the asset
  @param maturityTimestamp Unix timestamp for the maturity date of the asset
  */
  function createAsset(
    uint256 assetId,
    uint256 maxSupply,
    uint256 faceValue,
    uint256 maturityTimestamp
  ) external onlyOwner {
    require(assetToDetails[assetId].assetId != assetId, "Assets already exist");

    Asset memory asset = Asset(assetId, maxSupply, faceValue, maturityTimestamp);
    assetToDetails[assetId] = asset;
  }

  /**
  @dev Mints a specified number of tokens for the specified asset and recipient
  @param assetId Unique identifier number for the asset
  @param amounts Number of tokens to mint
  @param recipient Address of the recipient of the minted tokens
  */
  function mint(
    uint256 assetId,
    uint256 amounts,
    address recipient
  ) external onlyOwner {
    require(assetToDetails[assetId].assetId == assetId, "Asset does not exist");
    require(totalSupply(assetId) + amounts <= assetToDetails[assetId].maxSupply, "Max Supply");
    require(assetToDetails[assetId].maturityTimestamp > block.timestamp, "Asset is already matured");

    _mint(recipient, assetId, amounts, "");
  }

  /**
   * @dev Mint multiple assets in a batch
   * @param assetId Array of asset IDs to mint
   * @param amounts Array of corresponding amounts to mint for each asset ID
   * @param recipient Address to receive the minted assets
   */ 
  function mintBatch(
    uint256[] memory assetId,
    uint256[] memory amounts,
    address recipient
  ) public onlyOwner {
    for (uint256 i = 0; i < assetId.length; i++) {
      require(assetToDetails[assetId[i]].assetId == assetId[i], "Asset does not exist");
      require(totalSupply(assetId[i]) + amounts[i] <= assetToDetails[assetId[i]].maxSupply, "Max Supply");
      require(assetToDetails[assetId[i]].maturityTimestamp > block.timestamp, "Asset is already matured");
    }
    _mintBatch(recipient, assetId, amounts, "");
  }

  /**
   * @dev Burn an amount of a specific asset from the sender's balance
   * @param assetId ID of the asset to burn
   * @param amounts Amount to burn
   */
  function burn(uint256 assetId, uint256 amounts) external {
    require(assetToDetails[assetId].assetId == assetId, "Asset does not exist");

    _burn(msg.sender, assetId, amounts);
  }

  /**
   * @dev Burn multiple assets in a batch from the sender's balance
   * @param assetId Array of asset IDs to burn
   * @param amounts Array of corresponding amounts to burn for each asset ID
   */
  function burnBatch(uint256[] memory assetId, uint256[] memory amounts) external {
    for (uint256 i = 0; i < assetId.length; i++) {
      require(assetToDetails[assetId[i]].assetId == assetId[i], "Asset does not exist");
    }

    _burnBatch(msg.sender, assetId, amounts);
  }

  /**
  @dev Sets the URI for all token types.
  @param newuri The new URI.
  */
  function setURI(string memory newuri) external onlyOwner {
    _setURI(newuri);
  }

  /**
  @dev Returns the URI for a given token ID.
  @param id The token ID.
  @return A string representing the URI for the token.
  */
  function uri(uint256 id) public view override returns (string memory) {
    return string(abi.encodePacked(super.uri(id), id.toString(), ".json"));
  }

  /**
  @dev Internal function called after a token transfer.
  @param operator The address that initiated the transfer.
  @param from The address that sent the tokens.
  @param to The address that received the tokens.
  @param assetId An array of token IDs that were transferred.
  @param amounts An array of token amounts that were transferred.
  @param data Additional data with no specified format.
  */
  function _afterTokenTransfer(
    address operator,
    address from,
    address to,
    uint256[] memory assetId,
    uint256[] memory amounts,
    bytes memory data
  ) internal override(ERC1155Upgradeable) {
    emit AssetTransferEvent(operator, from, to, assetId, amounts, data);
  }

  /* ========== RESTRICTED FUNCTIONS ========== */
  /**
  @dev Authorizes a contract upgrade.
  @param newImplementation The address of the new contract implementation.
  */
  function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}
}
