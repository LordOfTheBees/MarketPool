const DataTestContract = artifacts.require("./fortest/DataTest.sol");
const FunctionsTestContract = artifacts.require("./fortest/FunctionsTest.sol");

const truffleAssert = require('truffle-assertions');

const testHelper = require('./libs/TestHelper');
const contractSubscriber = require('./libs/ContractSubscriber');

const dataTest = require('./libs/ContractSubscriberTest/DataTest');
const functionsTest = require('./libs/ContractSubscriberTest/FunctionsTest');

contract("ContractSubscriber Test", async accounts => {
    let instanceData;
    let instanceFunctions;

    before(async () => {
        instanceData = await DataTestContract.deployed();
        instanceFunctions = await FunctionsTestContract.deployed();
    });

    it("Ошибочные вызовы для ContractSubscriber", async () => {
        await testHelper.testError(async () => {
            await contractSubscriber.subscribe(instanceData, accounts[1], accounts[0]);
        }, "Подписываемый адрес не является контрактом");
        await testHelper.testError(async () => {
            await contractSubscriber.subscribe(instanceData, instanceFunctions.address, accounts[1]);
        }, "Подписка успешна, при вызове ее не создателем контракта");

        assert.isOk(
            !(await contractSubscriber.isSubscriber(instanceData, instanceFunctions.address)),
            "При наличии ошибок подписка все равно совершилась"
        );
    });
});