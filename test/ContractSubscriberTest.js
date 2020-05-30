const DataTestContract = artifacts.require("./fortest/DataTest.sol");
const FunctionsTestContract = artifacts.require("./fortest/FunctionsTest.sol");

const truffleAssert = require('truffle-assertions');
const assert = require('assert').strict;

const testHelper = require('./libs/TestHelper');
const contractSubscriber = require('./libs/ContractSubscriber');

const dataTest = require('./libs/ContractSubscriberTest/DataTest');
const functionsTest = require('./libs/ContractSubscriberTest/FunctionsTest');

contract("ContractSubscriber Test", async accounts => {
    let instanceData;
    let instanceFunctions;
    let initialSavedData;

    
    beforeEach(async () => {
        instanceData = await DataTestContract.deployed();
        initialSavedData = await dataTest.getDataAddress(instanceData);

        instanceFunctions = await FunctionsTestContract.deployed();
        await functionsTest.initData(instanceFunctions, instanceData.address, accounts[0]);
    });


    it("ContractSubscriber. Ошибочные вызовы", async () => {
        await testHelper.throws(async () => {
            await contractSubscriber.subscribe(instanceData, accounts[1], accounts[0]);
        }, "Подписываемый адрес не является контрактом");
        await testHelper.throws(async () => {
            await contractSubscriber.subscribe(instanceData, instanceFunctions.address, accounts[1]);
        }, "Подписка успешна, при вызове ее не создателем контракта");

        assert.ok(
            !(await contractSubscriber.isSubscriber(instanceData, instanceFunctions.address)),
            "При наличии ошибок подписка все равно совершилась"
        );
    });


    it("ContractSubscriber. Проверка подписки и отписки контракта", async () => {
        assert.ok(
            !(await contractSubscriber.isSubscriber(instanceData, instanceFunctions.address)),
            "Контракт изначально подписан"
        );

        await contractSubscriber.subscribe(instanceData, instanceFunctions.address, accounts[0]);
        assert.ok(
            await contractSubscriber.isSubscriber(instanceData, instanceFunctions.address),
            "Контракт не подписан после проведения подписи"
        );
        
        await contractSubscriber.unsubscribe(instanceData, instanceFunctions.address, accounts[0]);
        assert.ok(
            !(await contractSubscriber.isSubscriber(instanceData, instanceFunctions.address)),
            "Контракт подписан после отписки"
        );
    });


    it("DataTest. Ошибочные вызовы функции защищенной OnlySubscriber", async () => {
        await testHelper.throws(
            async () => {
                await dataTest.saveDataAddress(instanceData, accounts[1], accounts[0]);
            },
            "Функция выполнилась от лица аккаунта не являющимся контрактом"
        );

        await testHelper.throws(
            async () => {
                await functionsTest.saveDataAddress(instanceFunctions, accounts[1], accounts[0]);
            },
            "Функция выполнилась от лица контракта, который не является подписчиком"
        );
        
        assert.equal(
            await dataTest.getDataAddress(instanceData),
            initialSavedData,
            "Сохраненные данные отличаются от текущих"
        );
    });


    it("FunctionsTest. Использование функции с защитой OnlySubscriber", async () => {
        await testHelper.throws(
            async () => {
                await functionsTest.saveDataAddress(instanceFunctions, accounts[1], accounts[0]);
            },
            "errr"
        );
        assert.equal(
            await dataTest.getDataAddress(instanceData),
            initialSavedData,
            "Данные изменились после неверного вызова"
        );
        
        assert.notEqual(
            initialSavedData,
            accounts[1],
            "Дальнейшее тестирование невозможно"
        );
        await contractSubscriber.subscribe(instanceData, instanceFunctions.address, accounts[0]);
        await functionsTest.saveDataAddress(instanceFunctions, accounts[1], accounts[0]);

        assert.equal(
            await dataTest.getDataAddress(instanceData),
            accounts[1],
            "Сохраненные данные неверны"
        );
    });
});