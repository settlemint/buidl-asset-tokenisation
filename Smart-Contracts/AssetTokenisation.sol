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

contract AssetTokenisation is Initializable, UUPSUpgradeable, ERC1155SupplyUpgradeable, OwnableUpgradeable {
  using StringsUpgradeable for uint256;

  struct Asset {
    uint256 assetId;
    uint256 maxSupply;
    uint256 faceValue;
    uint256 maturityTimestamp;
  }

  string public name;
  string public symbol;

  mapping(uint256 => Asset) public assetToDetails;

  event AssetTransferEvent(
    address operator,
    address from,
    address to,
    uint256[] assetIds,
    uint256[] amounts,
    bytes data
  );

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

  function burn(uint256 assetId, uint256 amounts) external {
    require(assetToDetails[assetId].assetId == assetId, "Asset does not exist");

    _burn(msg.sender, assetId, amounts);
  }

  function burnBatch(uint256[] memory assetId, uint256[] memory amounts) external {
    for (uint256 i = 0; i < assetId.length; i++) {
      require(assetToDetails[assetId[i]].assetId == assetId[i], "Asset does not exist");
    }

    _burnBatch(msg.sender, assetId, amounts);
  }

  function setURI(string memory newuri) external onlyOwner {
    _setURI(newuri);
  }

  function uri(uint256 id) public view override returns (string memory) {
    return string(abi.encodePacked(super.uri(id), id.toString(), ".json"));
  }

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
  function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}
}
