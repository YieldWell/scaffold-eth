pragma solidity >=0.8.0 <0.9.0;
//SPDX-License-Identifier: MIT

import "hardhat/console.sol";
//import "@openzeppelin/contracts/access/Ownable.sol"; //https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

// is Strat, assume it's approved
contract ExampleStrat {
  function deposit() payable public {
    // nop
  }
  function harvest() public {
    // only pool members can do this
  }
  function withdraw() public {
    // only pool members but then what?
  }
}
contract YourContract is ERC721, ERC721URIStorage, Pausable, Ownable {
  using Counters for Counters.Counter;

  Counters.Counter private _tokenIdCounter;

  // will go into contract WhiteList
  struct Strat {
    address addr;
    string name; // if Strat is just address of an ERC721 then name can be inferred and struct isn't needed
  }
  // mapping(uint256 => Strat) public approvedStratsMap; // not clear yet how we need to retrieve
  Strat[] approvedStrats;

  //mapping(uint256 => string) public poolNames;
  string[] public poolNames;
  uint32 public poolCount;

  event SetPurpose(address sender, string purpose);
  event CreatePool(address sender, string name);

  string public purpose = "Yield farmers helping real farmers";

  error EmptyPurposeError(uint code, string message);

  //constructor() {
  constructor() ERC721("YourContractToken", "YCT") {
    // what should we do on deploy?
  }

  function setPurpose(string memory newPurpose) public {
      if(bytes(newPurpose).length == 0){
          revert EmptyPurposeError({
              code: 1,
              message: "Purpose can not be empty"
          });
      }

      purpose = newPurpose;
      console.log(msg.sender,"set purpose to",purpose);
      emit SetPurpose(msg.sender, purpose);
  }

  function createPool(string calldata name) public payable {
    // TODO require payment for DAO operations
    uint256 newTokenId = _tokenIdCounter.current();
    _safeMint(msg.sender, newTokenId);
    // when a map: poolNames[newTokenId] = name;
    // TODO set an approved Strat
    poolNames.push(name);
    poolCount++;
    _tokenIdCounter.increment();
    emit CreatePool(msg.sender, name);
  }
  function depositPool(uint256 poolId) public payable {
    require(poolId < _tokenIdCounter.current());
    // TODO move the funds around
  }
  function harvestPool(uint256 poolId) public onlyOwner {
    require(poolId < _tokenIdCounter.current());
    // TODO move the funds around
  }
  function approveStrat(address addr, string calldata name) public onlyOwner {
    // string name = "Whats My Name";
    Strat memory s = Strat(addr, name);
    approvedStrats.push(s);
  }

  // Copied ERC721 stuff
  function pause() public onlyOwner {
    _pause();
  }

  function unpause() public onlyOwner {
    _unpause();
  }

  function _beforeTokenTransfer(address from, address to, uint256 tokenId)
    internal
    whenNotPaused
    override(ERC721)
  {
    super._beforeTokenTransfer(from, to, tokenId);
  }

  function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
    super._burn(tokenId);
  }

  function tokenURI(uint256 tokenId)
    public
    view
    override(ERC721, ERC721URIStorage)
    returns (string memory)
  {
    return super.tokenURI(tokenId);
  }

  function supportsInterface(bytes4 interfaceId)
    public
    view
    override(ERC721)
    returns (bool)
  {
    return super.supportsInterface(interfaceId);
  }
}
