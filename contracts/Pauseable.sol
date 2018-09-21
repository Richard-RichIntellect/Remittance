pragma solidity 0.4.24;

import "./Owned.sol";

contract Pauseable is Owned {
  bool isStopped = false;
  
  event LogContractStopped(address account);
  event LogContractResumed(address account);

  constructor () public  {
  }


  function stopContract() public onlyOwner {
    emit LogContractStopped(msg.sender);
    isStopped = true;
  }

  function resumeContract() public onlyOwner {
    emit LogContractResumed(msg.sender);
    isStopped = false;
  }

  modifier onlyIfRunning {
    require(!isStopped,"Contract Stopped.");
    _;
  }

  modifier onlyWhenStopped {
    require(isStopped,"Contract still active.");
    _;
  }

}