var Remittance = artifacts.require("../contracts/Remittance.sol");

contract('Remittance', function (accounts) {
  let instance;
  let passwordHash;

  const owner = accounts[0];
  const recepient = accounts[1]
  const exchange = accounts[2]

  let ownerBalance;
  let recipientBalance;
  let exchangeBalance;

  const emptyAddress = /^0x0+$/

  beforeEach(function () {
    return Remittance.new({ from: owner })
      .then(function (_instance) {
        instance = _instance;
        ownerBalance = web3.eth.getBalance(owner);
        recipientBalance = web3.eth.getBalance(recepient);
        exchangeBalance = web3.eth.getBalance(exchange);
        return instance.returnPassword(exchange, "PasswordOne")
        .then(result => {
          passwordHash = result;
        });  
      });
  });

  it("should not be able to create remittance if password hash is empty", function () {
    return instance.createRemittance(emptyAddress, emptyAddress,   { from: owner, value: web3.toWei('0.1', 'ether') })
      .then(result => {
        assert.isTrue(false);
      })
      .catch(result => {
        assert.isTrue(true);
      })
  });


  it("should not be able to create remittance if exchange is empty", function () {
    return instance.createRemittance(passwordHash, emptyAddress, { from: owner, value: web3.toWei('0.1', 'ether') })
      .then(result => {
        console.log(result);
        assert.isTrue(false);
      })
      .catch(result => {
        assert.isTrue(true);
      })
  });

  it("should not be able to create remittance if amount == 0 is empty", function () {
    return instance.createRemittance(passwordHash, exchange,  { from: owner, value: web3.toWei('0.1', 'ether') })
      .then(result => {
        console.log(result);
        assert.isTrue(false);
      })
      .catch(result => {
        assert.isTrue(true);
      })
  });

  it("should  be able to create remittance", function () {
    return instance.createRemittance(recepient, exchange,  { from: owner, value: web3.toWei('0.1', 'ether') })
      .then(result => {
        assert.isTrue(true);
      })
      .catch(result => {
        console.log(result);
        assert.isTrue(true);
      })
  });

  it("should not be able to create a remittance with the same password hash", function () {
    return instance.createRemittance(passwordHash, exchange, { from: owner, value: web3.toWei('0.1', 'ether') })
      .then(result => {
        return instance.createRemittance(passwordHash, exchange,  { from: owner, value: web3.toWei('0.1', 'ether') })
        .then(result => {
          console.log(result)
          assert.isTrue(false);
        })
        .catch(result => {
          console.log(result);
          assert.isTrue(true);
        })

      })
      .catch(result => {
        console.log(result);
        assert.isTrue(false);
      })
  });

  it("should not transfer funds if you are the owner", function () {
    return instance.createRemittance(passwordHash, exchange,  { from: owner, value: web3.toWei('0.1', 'ether') })
      .then(result => {
        return instance.claimRemittance("PasswordOne",  { from: owner })
          .then(result => {
            assert.isTrue(false);
          })
          .catch(result => {
            console.log(result);
            assert.isTrue(true);
          })
      })
  });

  it("should not transfer funds if you are recipients", function () {
    return instance.createRemittance(passwordHash, exchange,  { from: owner, value: web3.toWei('0.1', 'ether') })
      .then(result => {
        return instance.claimRemittance("PasswordOne",  { from: recepient })
          .then(result => {
            assert.isTrue(false);
          })
          .catch(result => {
            console.log(result);
            assert.isTrue(true);
          })
      })
  });

  it("should not be able to get balance if not owner", function () {
    return instance.createRemittance(passwordHash, exchange,  { from: owner, value: web3.toWei('0.1', 'ether') })
      .then(result => {
        return instance.readBalance(passwordHash,  { from: recepient })
          .then(result => {
            assert.isTrue(false);
          })
          .catch(result => {
            console.log(result);
            assert.isTrue(true);
          })
      })
  });

  let resultRemittance;


  it("should be able to view balance", function () {
   
    return instance.createRemittance(passwordHash, exchange,  { from: owner, value: web3.toWei('0.1', 'ether') })
      .then(result => {
        
        resultRemittance = result;
        console.log(passwordHash);
        return instance.readBalance(passwordHash, { from: owner })
          .then(result => {
            let tx1 = web3.eth.getTransaction(resultRemittance.tx);
            let ownerNewBalance = web3.eth.getBalance(owner)
              .plus(tx1.gasPrice.mul(resultRemittance.receipt.gasUsed))
              .plus(web3.toWei('0.1', 'ether'));
              console.log(ownerNewBalance.toNumber());
              console.log(ownerBalance.toNumber());
            assert.isTrue(ownerNewBalance.toNumber() == ownerBalance.toNumber())

          })
          .catch(result => {
            console.log(result);
            assert.isTrue(false);
          })
      }).catch(result => {
        console.log(result);
        assert.isTrue(false);
      })
  });



  it("should  be able to create transfer", function () {
    return instance.createRemittance(passwordHash, exchange,  { from: owner, value: web3.toWei('0.1', 'ether') })
      .then(result => {

        return instance.claimRemittance("PasswordOne",  { from: exchange })
          .then(result => {
            resultTransfer = result;
            let tx1 = web3.eth.getTransaction(resultTransfer.tx);
            let exchangeNewBalance = web3.eth.getBalance(exchange)
              .plus(tx1.gasPrice.mul(resultTransfer.receipt.gasUsed));
              console.log(exchangeNewBalance.toNumber());
              console.log(exchangeBalance.toNumber());
            assert.isTrue(exchangeBalance.plus(web3.toWei('0.1', 'ether')).toNumber() == exchangeNewBalance.toNumber());
          })
          .catch(result => {
            console.log(result);
            assert.isTrue(false);
          })
      })
      .catch(result => {
        console.log(result);
        assert.isTrue(false);
      })
  });

  it("should not be able to create transfer", function () {
    return instance.createRemittance(passwordHash, exchange, { from: owner, value: web3.toWei('0.1', 'ether') })
      .then(result => {

        return instance.transferBalance(passwordHash, web3.toWei('1.05', 'ether'), { from: exchange })
          .then(result => {
            console.log(result);
            assert.isTrue(false);
          })
      })
      .catch(result => {
        console.log(result);
        assert.isTrue(true);
      })
  });

});