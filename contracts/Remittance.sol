pragma solidity 0.4.24;

import "./Pauseable.sol";

contract Remittance is  Pauseable {

  event LogDetailsofEmergencyWithdrawal(address sender);
  event LogAddTransaction(address sender, address beneficiary,address exchange,uint amount);
  event LogViewBalance(address sender);
  event LogUpdateBalance(address sender,uint deduction);

  modifier onlyIfDetailsAreCorrect(string passwordOne, address beneficiary,address exchange)
  {
    require (bytes(passwordOne).length > 0,"Password One cannot be empty");
    require (beneficiary != address(0),"Beneficiary address cannot be null");
    require (exchange != address(0),"Exchange address cannot be null");
    _;
  }

  constructor () public  {

  }

  struct RemittanceStructs {
    uint balance;
    uint deadline;
    address exchange;
    address owner;
  }

  mapping (bytes32 => bool) public hashUsed;
  mapping (bytes32 => RemittanceStructs) public pendingWithdrawals;


  function returnPassword(address exchange, string beneficiary) public view returns(bytes32) {
    return keccak256(abi.encodePacked(exchange,beneficiary, address(this)));
  }

  function createRemittance(
    address beneficiary, 
    address exchange,
    string passwordOne
  )  public onlyIfDetailsAreCorrect(passwordOne, beneficiary, exchange) payable returns (bool success)
  {
    uint amount = msg.value;
    emit LogAddTransaction(msg.sender,beneficiary, exchange, amount);
    bytes32 passwordHash = returnPassword(exchange,passwordOne);
    require (amount > 0,"Amount cannot be zero");
    require (hashUsed[keccak256(abi.encodePacked(passwordOne,beneficiary,exchange))] == false,"This password has already been used.");

    hashUsed[keccak256(abi.encodePacked(passwordOne,beneficiary,exchange))] = true;
    pendingWithdrawals[passwordHash] = RemittanceStructs(amount, now + 30 days, exchange, msg.sender);
    return (true);
  }

  function transferBalance(
    bytes32 passwordHash,
    uint deduction
  )  public
  {
    emit LogUpdateBalance(msg.sender,deduction);

    require (passwordHash.length > 0,"Password hash cannot be empty");
    require ((pendingWithdrawals[passwordHash].deadline > now), "30 day withdrawal expired");
    require (pendingWithdrawals[passwordHash].balance >= deduction,"Not enough funds");
    require (pendingWithdrawals[passwordHash].exchange == msg.sender,"Unathorized.");
    pendingWithdrawals[passwordHash].balance -= deduction;
    msg.sender.transfer(deduction);
  }

  function refund(bytes32 passwordHash) public 
  {
    require ((pendingWithdrawals[passwordHash].owner == msg.sender),"Unathorized.");
    require ((pendingWithdrawals[passwordHash].deadline <= now), "Unathorized.");
    uint amount = pendingWithdrawals[passwordHash].balance;
    pendingWithdrawals[passwordHash].balance = 0;
    msg.sender.transfer(amount);
  }

  function emergencyWithdraw() public onlyWhenStopped onlyOwner {
    emit LogDetailsofEmergencyWithdrawal(msg.sender);
    msg.sender.transfer(address(this).balance);
  }

  function readBalance(
    bytes32 passwordHash
  )  public view returns (uint)
  {
    require (passwordHash.length > 0,"Password hash cannot be empty");
    return (pendingWithdrawals[passwordHash].balance);
  }
}