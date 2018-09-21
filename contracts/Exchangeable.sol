pragma solidity 0.4.24;

import "./UniqueKey.sol";
import "./Owned.sol";

contract Exchangeable is UniqueKey, Owned {

  event LogAddTransaction(address sender, address beneficiary,address exchange,uint amount);

  event LogViewBalance(address sender);
  event LogUpdateBalance(address sender,uint deduction);

  struct Transaction {
    address beneficiary;
    address exchange;
    uint amount;
  }

  mapping (bytes32 => mapping(bytes32 => Transaction)) pendingWithdrawals;
  

  modifier onlyIfDetailsAreCorrect(string passwordOne, string passwordTwo, address beneficiary,address exchange, uint amount)
  {
    require (bytes(passwordOne).length > 0,"Password One cannot be empty");
    require (bytes(passwordTwo).length > 0,"Password Two cannot be empty");
    require (beneficiary != address(0),"Beneficiary address cannot be null");
    require (exchange != address(0),"Exchange address cannot be null");
    require (amount > 0,"Amount cannot be zero");
    _;
  }

  modifier onlyIfContract(string passwordOne, string passwordTwo) 
  {
    require (bytes(passwordOne).length > 0,"Password One cannot be empty");
    require (bytes(passwordTwo).length > 0,"Password Two cannot be empty");
    require (pendingWithdrawals[getUniqueKey(passwordOne)][getUniqueKey(passwordTwo)].beneficiary != address(0),"Cannot find contract.");
    _;
  }

  modifier onlyIfExchange(string passwordOne, string passwordTwo) 
  {
    require (bytes(passwordOne).length > 0,"Password One cannot be empty");
    require (bytes(passwordTwo).length > 0,"Password Two cannot be empty");
    require (pendingWithdrawals[getUniqueKey(passwordOne)][getUniqueKey(passwordTwo)].exchange == msg.sender,"Unauthorized.");
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
    pendingWithdrawals[getUniqueKey(passwordOne)][getUniqueKey(passwordTwo)] = Transaction(beneficiary,exchange,amount);
  }

  function viewBalance(
    string passwordOne, 
    string passwordTwo
  )  internal onlyIfContract(passwordOne, passwordTwo) onlyIfExchange(passwordOne, passwordTwo) returns (uint)
  {
    emit LogViewBalance(msg.sender);
    return (pendingWithdrawals[getUniqueKey(passwordOne)][getUniqueKey(passwordTwo)].amount);
  }

  function updateBalance(
    string passwordOne, 
    string passwordTwo,
    uint deduction
  )  internal onlyIfExchange(passwordOne, passwordTwo)
  {
    emit LogUpdateBalance(msg.sender,deduction);
    require (pendingWithdrawals[getUniqueKey(passwordOne)][getUniqueKey(passwordTwo)].amount >= deduction,"Not enough funds");
    pendingWithdrawals[getUniqueKey(passwordOne)][getUniqueKey(passwordTwo)].amount -= deduction;
  }
}