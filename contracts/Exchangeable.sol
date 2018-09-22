pragma solidity 0.4.24;


import "./Owned.sol";

contract Exchangeable is Owned {

  event LogAddTransaction(address sender, address beneficiary,address exchange,uint amount);

  event LogViewBalance(address sender);
  event LogUpdateBalance(address sender,uint deduction);

  struct RemittanceStruct {
    address beneficiary;
    address exchange;
    uint amount;
  }

  mapping (bytes32 => RemittanceStruct) pendingWithdrawals;
  
  function getUniqueKey(string passwordOne, string passwordTwo) private view returns (bytes32)
  {
    return keccak256(
      abi.encodePacked(
        keccak256(abi.encodePacked(passwordOne)),
        keccak256(abi.encodePacked(passwordTwo)),
    owner));
  }

  modifier onlyIfDetailsAreCorrect(string passwordOne, string passwordTwo, address beneficiary,address exchange, uint amount)
  {
    require (bytes(passwordOne).length > 0,"Password One cannot be empty");
    require (bytes(passwordTwo).length > 0,"Password Two cannot be empty");
    require (beneficiary != address(0),"Beneficiary address cannot be null");
    require (exchange != address(0),"Exchange address cannot be null");
    require (amount > 0,"Amount cannot be zero");
    _;
  }

  modifier onlyIfExchange(string passwordOne, string passwordTwo) 
  {
    require (bytes(passwordOne).length > 0,"Password One cannot be empty");
    require (bytes(passwordTwo).length > 0,"Password Two cannot be empty");
    require (pendingWithdrawals[getUniqueKey(passwordOne,passwordTwo)].exchange == msg.sender,"Unauthorized.");
    _;
  }

  function addTransaction(
    address beneficiary, 
    address exchange,
    string passwordOne,
    string passwordTwo, 
    uint amount
  )  internal onlyIfDetailsAreCorrect(passwordOne, passwordTwo, beneficiary, exchange,amount) onlyOwner 
  {
    emit LogAddTransaction(msg.sender,beneficiary, exchange, amount);
    pendingWithdrawals[getUniqueKey(passwordOne,passwordTwo)] = RemittanceStruct(beneficiary,exchange,amount);
  }

  function viewBalance(
    string passwordOne, 
    string passwordTwo
  )  internal onlyIfExchange(passwordOne, passwordTwo) onlyIfExchange(passwordOne, passwordTwo) returns (uint)
  {
    emit LogViewBalance(msg.sender);
    return (pendingWithdrawals[getUniqueKey(passwordOne,passwordTwo)].amount);
  }

  function updateBalance(
    string passwordOne, 
    string passwordTwo,
    uint deduction
  )  internal onlyIfExchange(passwordOne, passwordTwo)
  {
    emit LogUpdateBalance(msg.sender,deduction);
    require (pendingWithdrawals[getUniqueKey(passwordOne,passwordTwo)].amount >= deduction,"Not enough funds");
    pendingWithdrawals[getUniqueKey(passwordOne,passwordTwo)].amount -= deduction;
  }
}