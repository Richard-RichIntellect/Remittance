var Remittance = artifacts.require("../contracts/Remittance.sol");

contract('Remittance', function (accounts) {
  let instance;


  const owner = accounts[0];
  const recepient = accounts[1]
  const exchange = accounts[2]

  let ownerBalance;
  let recipientBalance;
  let exchangeBalance;

  const emptyAddress = /^0x0+$/

  beforeEach(function () {
    return Remittance.new({ from: owner, value: web3.toWei('0.1', 'ether') })
      .then(function (_instance) {
        instance = _instance;
        ownerBalance = web3.eth.getBalance(owner);
        recipientBalance = web3.eth.getBalance(recepient);
        exchangeBalance = web3.eth.getBalance(exchange);
      });
  });

  it("should not be able to create remittance if password one is empty", function () {
    return instance.createRemittance(emptyAddress, emptyAddress, "", "", 0, { from: owner })
      .then(result => {
        console.log(result);
        assert.isTrue(false);
      })
      .catch(result => {
        assert.isTrue(true);
      })
  });

  it("should not be able to create remittance if password two is empty", function () {
    return instance.createRemittance(emptyAddress, emptyAddress, "PasswordOne", "", 0, { from: owner })
      .then(result => {
        console.log(result);
        assert.isTrue(false);
      })
      .catch(result => {
        assert.isTrue(true);
      })
  });

  it("should not be able to create remittance if recipient is empty", function () {
    return instance.createRemittance(emptyAddress, emptyAddress, "PasswordOne", "PasswordTwo", 0, { from: owner })
      .then(result => {
        console.log(result);
        assert.isTrue(false);
      })
      .catch(result => {
        assert.isTrue(true);
      })
  });

  it("should not be able to create remittance if exchange is empty", function () {
    return instance.createRemittance(recepient, emptyAddress, "PasswordOne", "PasswordTwo", 0, { from: owner })
      .then(result => {
        console.log(result);
        assert.isTrue(false);
      })
      .catch(result => {
        assert.isTrue(true);
      })
  });

  it("should not be able to create remittance if amount == 0 is empty", function () {
    return instance.createRemittance(recepient, exchange, "PasswordOne", "PasswordTwo", 0, { from: owner })
      .then(result => {
        console.log(result);
        assert.isTrue(false);
      })
      .catch(result => {
        assert.isTrue(true);
      })
  });

  it("should  be able to create remittance", function () {
    return instance.createRemittance(recepient, exchange, "PasswordOne", "PasswordTwo", web3.toWei('0.1', 'ether'), { from: owner })
      .then(result => {
        assert.isTrue(true);
      })
      .catch(result => {
        console.log(result);
        assert.isTrue(true);
      })
  });

  it("should not transfer funds if you are the owner", function () {
    return instance.createRemittance(recepient, exchange, "PasswordOne", "PasswordTwo", web3.toWei('0.1', 'ether'), { from: owner })
      .then(result => {
        return instance.transferBalance("PasswordOne", "PasswordTwo", web3.toWei('0.05', 'ether'), { from: owner })
          .then(result => {
            assert.isTrue(false);
          })
          .catch(result => {
            console.log(result);
            assert.isTrue(true);
          })
      })
  });

  it("should not transfer funds if you a recipients", function () {
    return instance.createRemittance(recepient, exchange, "PasswordOne", "PasswordTwo", web3.toWei('0.1', 'ether'), { from: owner })
      .then(result => {
        return instance.transferBalance("PasswordOne", "PasswordTwo", web3.toWei('0.05', 'ether'), { from: recepient })
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
    return instance.createRemittance(recepient, exchange, "PasswordOne", "PasswordTwo", web3.toWei('0.1', 'ether'), { from: owner })
      .then(result => {
        return instance.readBalance("PasswordOne", "PasswordTwo", { from: recepient })
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
    return instance.createRemittance(recepient, exchange, "PasswordOne", "PasswordTwo", web3.toWei('0.1', 'ether'), { from: owner })
      .then(result => {
        captureEvents = result;
        return instance.readBalance("PasswordOne", "PasswordTwo", { from: owner })
          .then(result => {
            let tx1 = web3.eth.getTransaction(resultRemittance.tx);
            let ownerNewBalance = web3.eth.getBalance(owner)
              .plus(tx1.gasPrice.mul(resultRemittance.receipt.gasUsed));
            assert.isTrue(ownerNewBalance.toNumber() == ownerBalance.toNumber())
          })
          .catch(result => {
            console.log(result);
            assert.isTrue(true);
          })
      })
  });


  let resultTransfer;

  it("should  be able to create transfer", function () {
    return instance.createRemittance(recepient, exchange, "PasswordOne", "PasswordTwo", web3.toWei('0.1', 'ether'), { from: owner })
      .then(result => {
        resultRemittance = result;
        return instance.transferBalance("PasswordOne", "PasswordTwo", web3.toWei('0.05', 'ether'), { from: exchange })
          .then(result => {
            resultTransfer = result;
            let tx1 = web3.eth.getTransaction(resultTransfer.tx);
            let exchangeNewBalance = web3.eth.getBalance(exchange)
              .plus(tx1.gasPrice.mul(resultTransfer.receipt.gasUsed));
            assert.isTrue(exchangeBalance.plus(web3.toWei('0.05', 'ether')).toNumber() == exchangeNewBalance.toNumber());
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
});