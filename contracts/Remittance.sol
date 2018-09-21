pragma solidity 0.4.24;

import "./Exchangeable.sol";
import "./Pauseable.sol";

contract Remittance is Exchangeable, Pauseable {

  event LogDetailsofEmergencyWithdrawal(address sender);

  constructor() public payable {}

  function createRemittance( 
    address beneficiary, 
    address exchange,
    string passwordOne,
    string passwordTwo, 
    uint amount) public onlyIfRunning
  {
    addTransaction(beneficiary, exchange, passwordOne, passwordTwo, amount);
  }

  
  function transferBalance(
    string passwordOne, 
    string passwordTwo,
    uint amount
  ) public onlyIfRunning
  {
    updateBalance(passwordOne, passwordTwo, amount);
    msg.sender.transfer(amount);
  }

  function emergencyWithdraw() public onlyWhenStopped onlyOwner {
    emit LogDetailsofEmergencyWithdrawal(msg.sender);
    msg.sender.transfer(address(this).balance);
  }

  function readBalance(string passwordOne, string passwordTwo) public onlyIfRunning onlyOwner returns (uint) {
    return viewBalance(passwordOne, passwordTwo);
  }
}