pragma solidity 0.4.24;

import "./Pauseable.sol";

contract Remittance is  Pauseable {

  event LogDetailsofEmergencyWithdrawal(address sender);
  event LogAddTransaction(address sender, address beneficiary,address exchange,uint amount);
  event LogViewBalance(address sender);
  event LogUpdateBalance(address sender,uint deduction);

  modifier onlyIfDetailsAreCorrect(bool hashBeingUsed, string passwordOne, address beneficiary,address exchange, uint amount)
  {
    require (bytes(passwordOne).length > 0,"Password One cannot be empty");
    require (hashBeingUsed == false,"This password has already been used.");
    require (beneficiary != address(0),"Beneficiary address cannot be null");
    require (exchange != address(0),"Exchange address cannot be null");
    require (amount > 0,"Amount cannot be zero");
    _;
  }

  modifier onlyIfExchange(address exchange, uint timestampContractCreated, bytes32 passwordHash) 
  {
    require (passwordHash.length > 0,"Password hash cannot be empty");
    require (exchange == msg.sender,"Unauthorized!");
    require ((((timestampContractCreated - now) / 60 / 60 / 24 ) < 30), "30 day withdrawal expired");
    _;
  }

  constructor () public payable {}

  struct RemittanceStruct {
    address exchange;
    uint amount;
    uint timestamp;
  }

  mapping (bytes32 => bool) public hashUsed;
  mapping (bytes32 => RemittanceStruct) internal pendingWithdrawals;

  function returnPassword(address exchange, string beneficiary) public onlyOwner view returns(bytes32) {
    return keccak256(abi.encodePacked(exchange, keccak256(abi.encodePacked(beneficiary)), address(this)));
  }

  function createRemittance(
    address beneficiary, 
    address exchange,
    string passwordOne,
    uint amount
  )  public onlyIfDetailsAreCorrect(hashUsed[keccak256(abi.encodePacked(passwordOne))], passwordOne, beneficiary, exchange,amount) onlyOwner
  {
    emit LogAddTransaction(msg.sender,beneficiary, exchange, amount);
    hashUsed[keccak256(abi.encodePacked(passwordOne))] = true;
    bytes32 passwordHash = returnPassword(exchange,passwordOne);
    pendingWithdrawals[passwordHash] = RemittanceStruct(exchange,amount,now);
  }

  function transferBalance(
    bytes32 passwordHash,
    uint deduction
  )  public onlyIfExchange(pendingWithdrawals[passwordHash].exchange, pendingWithdrawals[passwordHash].timestamp, passwordHash)
  {
    emit LogUpdateBalance(msg.sender,deduction);
    require (pendingWithdrawals[passwordHash].amount >= deduction,"Not enough funds");
    pendingWithdrawals[passwordHash].amount -= deduction;
    msg.sender.transfer(deduction);
  }

  function emergencyWithdraw() public onlyWhenStopped onlyOwner {
    emit LogDetailsofEmergencyWithdrawal(msg.sender);
    msg.sender.transfer(address(this).balance);
  }

  function readBalance(
    bytes32 passwordHash
  )  public onlyIfExchange(pendingWithdrawals[passwordHash].exchange, pendingWithdrawals[passwordHash].timestamp,passwordHash) returns (uint)
  {
    emit LogViewBalance(msg.sender);
    return (pendingWithdrawals[passwordHash].amount);
  }
}