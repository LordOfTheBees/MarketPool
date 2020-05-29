const DataTest = artifacts.require("./fortest/DataTest.sol");
const FunctionsTest = artifacts.require("./fortest/FunctionsTest.sol");

module.exports = function(deployer) {
    deployer.deploy(DataTest);
    deployer.deploy(FunctionsTest);
};