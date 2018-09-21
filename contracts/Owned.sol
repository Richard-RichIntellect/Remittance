pragma solidity 0.4.24;

contract Owned {
  address public owner;

  constructor () public {
    owner = msg.sender;
  }

  modifier onlyOwner 
  { 
    require(owner == msg.sender,"Unathorized.");
    _;
  }
  
  event LogOwnerChanged(address newOwner, address currentOwner);

  function changeOwner(address newOwner) public onlyOwner
  {
    emit LogOwnerChanged(newOwner, msg.sender);
    owner = newOwner;
  }

}
