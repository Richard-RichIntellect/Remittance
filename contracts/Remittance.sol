pragma solidity 0.4.24;

import "./Pauseable.sol";

contract Remittance is  Pauseable {

  event LogDetailsofEmergencyWithdrawal(address indexed sender);
  event LogAddTransaction(bytes32 indexed passwordHash, address indexed exchange,uint amount);
  event LogUpdateBalance(address sender);
  event LogWithdrawalDetails(address sender, uint amountReceived, address thisContract);


  constructor () public  {

  }

  uint duration = 30 days;

  struct RemittanceStruct {
    uint balance;
    uint deadline;
    address exchange;
    address owner;
  }

  mapping (bytes32 => bool) public hashUsed;
  mapping (bytes32 => RemittanceStruct) public pendingWithdrawals;

  function returnPassword(address exchangeAddr, string beneficiarySecret) public view returns(bytes32) {
    require (bytes(beneficiarySecret).length > 0,"Password cannot be empty");
    require (exchangeAddr != address(0),"Exchange address required");

    return keccak256(abi.encodePacked(exchangeAddr,beneficiarySecret, address(this)));
  }

  function createRemittance(
    bytes32 passwordHash, 
    address exchangeAddr
  )  public payable returns (bool success)
  {
    emit LogAddTransaction(passwordHash, exchangeAddr, msg.value);
    require (msg.value > 0,"Amount cannot be zero");
    require (passwordHash != 0,"Password hash required");
    require (exchangeAddr != address(0),"Exchange address required");
    require (pendingWithdrawals[passwordHash].owner == address(0),"This remittance already exists.");

    hashUsed[passwordHash] = true;
    pendingWithdrawals[passwordHash] = RemittanceStruct(msg.value, now + duration, exchangeAddr, msg.sender);
    return (true);
  }

  function claimRemittance(
    string beneficiarySecret
  )  public
  {
    emit LogUpdateBalance(msg.sender);
    bytes32 passwordHash = returnPassword(msg.sender,beneficiarySecret);
    require (pendingWithdrawals[passwordHash].exchange != address(0) , "Remittance not found.");
    require (pendingWithdrawals[passwordHash].deadline > now, "30 day withdrawal expired");
    require (pendingWithdrawals[passwordHash].balance > 0,"Not enough funds");
    require (pendingWithdrawals[passwordHash].exchange == msg.sender,"Unathorized.");
    
    uint balance = pendingWithdrawals[passwordHash].balance;
    emit LogWithdrawalDetails(msg.sender, balance, address(this));
    
    pendingWithdrawals[passwordHash].balance = 0;
    pendingWithdrawals[passwordHash].exchange.transfer(balance);
  }

  function refund(bytes32 passwordHash) public 
  {
    require (pendingWithdrawals[passwordHash].exchange != address(0) , "Remittance not found.");
    require ((pendingWithdrawals[passwordHash].owner == msg.sender),"Unathorized.");
    require ((pendingWithdrawals[passwordHash].deadline <= now), "Unathorized.");
    uint balance = pendingWithdrawals[passwordHash].balance;
    emit LogWithdrawalDetails(msg.sender, balance, address(this));
    pendingWithdrawals[passwordHash].balance = 0;
    msg.sender.transfer(balance);
  }

  function emergencyWithdraw() public onlyWhenStopped onlyOwner {
    emit LogDetailsofEmergencyWithdrawal(msg.sender);
    msg.sender.transfer(address(this).balance);
  }

  function readBalance(
    bytes32 passwordHash
  )  public view returns (uint)
  {
    return (pendingWithdrawals[passwordHash].balance);
  }
}