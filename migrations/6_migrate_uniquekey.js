var UniqueKey = artifacts.require("Remittance");

module.exports = function(deployer) {
  // deployment steps
  deployer.deploy(UniqueKey);
};