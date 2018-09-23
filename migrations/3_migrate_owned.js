var Owned = artifacts.require("Remittance");

module.exports = function(deployer) {
  // deployment steps
  deployer.deploy(Owned);
};