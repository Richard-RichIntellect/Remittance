pragma solidity 0.4.24;

contract UniqueKey {

  constructor() public {}

  function getUniqueKey(string text) internal pure returns (bytes32)
  {
    return keccak256(abi.encodePacked(text));
  }
}