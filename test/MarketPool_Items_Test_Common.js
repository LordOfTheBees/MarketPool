const MarketPool_Items = artifacts.require("./MarketPool_Items.sol");

const truffleAssert = require('truffle-assertions');
const testHelper = require("../jsmoduls/test-helper.js");

contract("MarketPool_Items Common Test", async accounts => {

    let instance;
    let marketOwner = accounts[1];
    let notMarketOwner = accounts[2];
    let marketId;

    var commonDataToCreateItemType = {
        marketId        :   0,
        name            :   "Common Test Type",
        totalSuply      :   99999999,
        allowSale       :   true,
        allowAuction    :   true,
        allowRent       :   true,
        allowLootbox    :   true
    };

    before(async () => {
        instance = await MarketPool_Items.deployed();
    });

    //Создаём новый магазин перед каждым тестом
    beforeEach(async () => {
        let res = await testHelper.createMarket(instance, {name : "Market Name"}, marketOwner);
        marketId = res.marketId;
        commonDataToCreateItemType.marketId = res.marketId;
    });


    
    it("Create Item Type", async () => {
        let dataToCreateItemType = {
            marketId        :   marketId,
            name            :   "Test Type",
            totalSuply      :   0,
            allowSale       :   false,
            allowAuction    :   true,
            allowRent       :   false,
            allowLootbox    :   true
        };


        let responseCreateItemType = await testHelper.createItemType(instance, dataToCreateItemType, marketOwner);
        checkItemTypeData(dataToCreateItemType, responseCreateItemType.savedData);
        assert.equal(responseCreateItemType.marketId, marketId, "Incorrect returned from event market id");

        await testHelper.testError(
            async () => await testHelper.createItemType(instance, dataToCreateItemType, notMarketOwner),
            "Create Item Type was successfuly from not owner market");
    });

    it("Create item type with not existing market", async () => {
        let dataToCreateItemType = {
            marketId        :   -1,
            name            :   "Test Type",
            totalSuply      :   0,
            allowSale       :   false,
            allowAuction    :   true,
            allowRent       :   false,
            allowLootbox    :   true
        };

        await testHelper.testError(
            async () => await testHelper.createItemType(instance, dataToCreateItemType, accounts[9]),
            "Create Item Type was successfuly");

        dataToCreateItemType.marketId = 100000;
        await testHelper.testError(
            async () => await testHelper.createItemType(instance, dataToCreateItemType, accounts[9]),
            "Create Item Type was successfuly");
    });

    it("Get Item Type Data", async () => {
        let dataToCreateItemType = {
            marketId        :   marketId,
            name            :   "Test Type",
            totalSuply      :   99999999,
            allowSale       :   true,
            allowAuction    :   false,
            allowRent       :   true,
            allowLootbox    :   false
        };

        let responseCreateItemType = await testHelper.createItemType(instance, dataToCreateItemType, marketOwner);
        let responseGetData = await instance.getItemTypeData(marketId, responseCreateItemType.typeId);
        let itemTypeData = responseCreateItemType.savedData;

        assert.equal(responseGetData.name, itemTypeData.name, "Incorrect saved type name");
        assert.equal(responseGetData.totalSuply.toNumber(), itemTypeData.remainingSuply.toNumber(), 
            "Incorrect saved remainingSuply");
        assert.equal(responseGetData.totalSuply.toNumber(), itemTypeData.totalSuply.toNumber(), "Incorrect saved totalSuply");
        assert.equal(responseGetData.allowSale, itemTypeData.allowSale, "Incorrect saved allowSale");
        assert.equal(responseGetData.allowAuction, itemTypeData.allowAuction, "Incorrect saved allowAuction");
        assert.equal(responseGetData.allowRent, itemTypeData.allowRent, "Incorrect saved allowRent");
        assert.equal(responseGetData.allowLootbox, itemTypeData.allowLootbox, "Incorrect saved allowLootbox");

        await testHelper.testError(
            async () => await instance.getItemTypeData(100000, 100000),
            "Get item type was success");
    });

    it("Create Item", async () => {
        let responseCreateItemType = await testHelper.createItemType(instance, commonDataToCreateItemType, marketOwner);
        let dataToCreateItem = {
            marketId    : marketId,
            typeId      : responseCreateItemType.typeId
        };

        let responseCreateItem = await testHelper.createItem(instance, dataToCreateItem, marketOwner);

        assert.equal(dataToCreateItem.marketId, responseCreateItem.marketId, "Incorrect marked Id from event");
        assert.equal(dataToCreateItem.typeId, responseCreateItem.typeId, "Incorrect type id from event");
        assert.equal(dataToCreateItem.typeId, responseCreateItem.savedData.toNumber(), "Incorrect saved typeId in array");
    });
    
    it("Create Item with errors", async () => {
        let responseCreateItemType = await testHelper.createItemType(instance, commonDataToCreateItemType, marketOwner);
        let dataToCreateItem = {
            marketId    : marketId,
            typeId      : responseCreateItemType.typeId
        };
        
        await testHelper.testError(
            async () => await testHelper.createItem(instance, dataToCreateItem, accounts[9]),
            "Create Item was successfuly from not market owner");

        dataToCreateItem.marketId = 100000;
        await testHelper.testError(
            async () => await testHelper.createItem(instance, dataToCreateItem, marketOwner),
            "Create Item was successfuly with not existing market");
        await testHelper.testError(
            async () => await testHelper.createItem(instance, dataToCreateItem, accounts[9]),
            "Create Item was successfuly with not existing market and not from owner");

        dataToCreateItem.marketId = marketId;
        dataToCreateItem.typeId = 100000;
        await testHelper.testError(
            async () => await testHelper.createItem(instance, dataToCreateItem, marketOwner),
            "Create Item was successfuly with not existing ItemType");
        await testHelper.testError(
            async () => await testHelper.createItem(instance, dataToCreateItem, accounts[9]),
            "Create Item was successfuly with not existing ItemType and not from owner");

        dataToCreateItem.marketId = 100000;
        dataToCreateItem.typeId = 100000;
        await testHelper.testError(
            async () => await testHelper.createItem(instance, dataToCreateItem, marketOwner),
            "Create Item was successfuly with not existing market and ItemType");
        await testHelper.testError(
            async () => await testHelper.createItem(instance, dataToCreateItem, accounts[9]),
            "Create Item was successfuly with not existing market and ItemType and not from owner");
    });

    it("Get Item Data", async () => {
        let responseCreateItemType = await testHelper.createItemType(instance, commonDataToCreateItemType, marketOwner);
        let dataToCreateItem = {
            marketId    : marketId,
            typeId      : responseCreateItemType.typeId
        };

        let responseCreateItem = await testHelper.createItem(instance, dataToCreateItem, marketOwner);
        let getData = await instance.getItemData(responseCreateItem.marketId, responseCreateItem.itemId);
        assert.equal(getData.toNumber(), responseCreateItem.savedData.toNumber(), "Incorrect saved typeId");
    });

    it("Get Item Data With Error", async () => {
        await testHelper.testError(
            async () => await instance.getItemData(100000, 100000),
            "Get Item Data was successfuly with not existing market and ItemType and not from owner");
    });

    it("Check Suply", async () => {
        let dataToCreateItemType = {
            marketId        :   marketId,
            name            :   "Test Type",
            totalSuply      :   10,
            allowSale       :   true,
            allowAuction    :   false,
            allowRent       :   true,
            allowLootbox    :   false
        };
        let responseCreateItemType = await testHelper.createItemType(instance, dataToCreateItemType, marketOwner);
        let dataToCreateItem = {
            marketId    : marketId,
            typeId      : responseCreateItemType.typeId
        };
        
        for (let i = 0; i < 10; ++i) {
            await testHelper.createItem(instance, dataToCreateItem, marketOwner);
        }

        await testHelper.testError(
            async () => await testHelper.createItem(instance, dataToCreateItem, marketOwner),
            "Create Item was successfuly with 0 remaining");
    });

    it("Transfer Item Ownership", async () => {
        let responseCreateItemType = await testHelper.createItemType(instance, commonDataToCreateItemType, marketOwner);
        let dataToCreateItem = {
            marketId    : marketId,
            typeId      : responseCreateItemType.typeId
        };

        let responseCreateItem = await testHelper.createItem(instance, dataToCreateItem, marketOwner);
        let dataToTransferOwnership = {
            marketId    : marketId,
            itemId      : responseCreateItem.itemId,
            to          : accounts[5]
        };

        let responseTransferOwnership = await testHelper.transferItemOwnership(instance, dataToTransferOwnership, marketOwner);

        assert.equal(dataToTransferOwnership.marketId, responseTransferOwnership.marketId, "marketId incorrect in the event");
        assert.equal(dataToTransferOwnership.itemId, responseTransferOwnership.itemId, "itemId incorrect in the event");
        assert.equal(marketOwner, responseTransferOwnership.previousOwner, "previousOwner incorrect in the event");
        assert.equal(dataToTransferOwnership.to, responseTransferOwnership.newOwner, "newOwner incorrect in the event");
        assert.equal(dataToTransferOwnership.to, responseTransferOwnership.savedOwner, "newOwner was not saved in the contract");
    });

    it("Transfer Item Ownership with error", async () => {
        let responseCreateItemType = await testHelper.createItemType(instance, commonDataToCreateItemType, marketOwner);
        let dataToCreateItem = {
            marketId    : marketId,
            typeId      : responseCreateItemType.typeId
        };

        let responseCreateItem = await testHelper.createItem(instance, dataToCreateItem, marketOwner);
        let dataToTransferOwnership = {
            marketId    : marketId,
            itemId      : responseCreateItem.itemId,
            to          : accounts[5]
        };

        dataToTransferOwnership = {
            marketId    : 100000,
            itemId      : responseCreateItem.itemId,
            to          : accounts[5]
        };
        await testHelper.testError(
            async () => await testHelper.transferItemOwnership(instance, dataToTransferOwnership, marketOwner),
            "The transfer ownership passed without errors"
        );

        dataToTransferOwnership = {
            marketId    : marketId,
            itemId      : 100000,
            to          : accounts[5]
        };
        await testHelper.testError(
            async () => await testHelper.transferItemOwnership(instance, dataToTransferOwnership, marketOwner),
            "The transfer ownership passed without errors for non-existent item"
        );

        dataToTransferOwnership = {
            marketId    : marketId,
            itemId      : responseCreateItem.itemId,
            to          : testHelper.zeroAddress
        };
        await testHelper.testError(
            async () => await testHelper.transferItemOwnership(instance, dataToTransferOwnership, marketOwner),
            "The transfer ownership passed without errors for zero address as new owner"
        );

        dataToTransferOwnership = {
            marketId    : marketId,
            itemId      : responseCreateItem.itemId,
            to          : accounts[6]
        };
        await testHelper.testError(
            async () => await testHelper.transferItemOwnership(instance, dataToTransferOwnership, accounts[5]),
            "The transfer ownership passed without errors from not current item's owner"
        );
        
        dataToTransferOwnership = {
            marketId    : marketId,
            itemId      : responseCreateItem.itemId,
            to          : marketOwner
        };
        await testHelper.testError(
            async () => await testHelper.transferItemOwnership(instance, dataToTransferOwnership, marketOwner),
            "The transfer ownership passed without errors, where 'to' equal 'owner'"
        );
    });

    it("Balance of items", async () => {
        let responseCreateItemType = await testHelper.createItemType(instance, commonDataToCreateItemType, marketOwner);
        let dataToCreateItem = {
            marketId    : marketId,
            typeId      : responseCreateItemType.typeId
        };

        let balance = (await instance.balanceOfItems(marketId, marketOwner)).toNumber();
        assert.equal(balance, 0, "Incorrect initial balance");

        let responseCreateItem = await testHelper.createItem(instance, dataToCreateItem, marketOwner);
        let dataToTransferOwnershipItem1 = {
            marketId    : marketId,
            itemId      : responseCreateItem.itemId,
            to          : accounts[5]
        };

        responseCreateItem = await testHelper.createItem(instance, dataToCreateItem, marketOwner);
        let dataToTransferOwnershipItem2 = {
            marketId    : marketId,
            itemId      : responseCreateItem.itemId,
            to          : accounts[5]
        };

        balance = (await instance.balanceOfItems(marketId, marketOwner)).toNumber();
        assert.equal(balance, 2, "Incorrect balance after adding two items");

        await testHelper.transferItemOwnership(instance, dataToTransferOwnershipItem1, marketOwner);
        balance = (await instance.balanceOfItems(marketId, marketOwner)).toNumber();
        assert.equal(balance, 1, "Incorrect balance of marketOwner after transfer Item2");
        balance = (await instance.balanceOfItems(marketId, accounts[5])).toNumber();
        assert.equal(balance, 1, "Incorrect balance of account[5] after transfer Item2");

        await testHelper.transferItemOwnership(instance, dataToTransferOwnershipItem2, marketOwner);
        balance = (await instance.balanceOfItems(marketId, marketOwner)).toNumber();
        assert.equal(balance, 0, "Incorrect balance of marketOwner after transfer Item2");
        balance = (await instance.balanceOfItems(marketId, accounts[5])).toNumber();
        assert.equal(balance, 2, "Incorrect balance of account[5] after transfer Item2");

        dataToTransferOwnershipItem1.to = marketOwner;
        dataToTransferOwnershipItem2.to = marketOwner;
        await testHelper.transferItemOwnership(instance, dataToTransferOwnershipItem1, accounts[5]);
        balance = (await instance.balanceOfItems(marketId, marketOwner)).toNumber();
        assert.equal(balance, 1, "Incorrect balance of marketOwner after back transfer Item1");
        balance = (await instance.balanceOfItems(marketId, accounts[5])).toNumber();
        assert.equal(balance, 1, "Incorrect balance of account[5] after back transfer Item1");

        await testHelper.transferItemOwnership(instance, dataToTransferOwnershipItem2, accounts[5]);
        balance = (await instance.balanceOfItems(marketId, marketOwner)).toNumber();
        assert.equal(balance, 2, "Incorrect balance of marketOwner after back transfer Item2");
        balance = (await instance.balanceOfItems(marketId, accounts[5])).toNumber();
        assert.equal(balance, 0, "Incorrect balance of account[5] afte backr transfer Item2");

        await testHelper.testError(
            async () => await instance.balanceOfItems(100000, marketOwner),
            "Check balance success for non-existent market"
        );

        await testHelper.testError(
            async () => await instance.balanceOfItems(marketId, testHelper.zeroAddress),
            "Check balance success for zero address"
        );
    });

    it("Get item owner", async () => {
        let responseCreateItemType = await testHelper.createItemType(instance, commonDataToCreateItemType, marketOwner);
        let dataToCreateItem = {
            marketId    : marketId,
            typeId      : responseCreateItemType.typeId
        };

        let responseCreateItem = await testHelper.createItem(instance, dataToCreateItem, marketOwner);
        let dataToTransferOwnership = {
            marketId    : marketId,
            itemId      : responseCreateItem.itemId,
            to          : accounts[5]
        };

        let itemOwner = await instance.getItemOwner(marketId, dataToTransferOwnership.itemId);
        assert.equal(itemOwner, marketOwner, "Incorrect market owner after item creating");

        await testHelper.transferItemOwnership(instance, dataToTransferOwnership, marketOwner);
        itemOwner = await instance.getItemOwner(marketId, dataToTransferOwnership.itemId);
        assert.equal(itemOwner, accounts[5], "Incorrect market owner after transfer ownership");
    });

    it("Is item owner", async () => {
        let responseCreateItemType = await testHelper.createItemType(instance, commonDataToCreateItemType, marketOwner);
        let dataToCreateItem = {
            marketId    : marketId,
            typeId      : responseCreateItemType.typeId
        };

        let responseCreateItem = await testHelper.createItem(instance, dataToCreateItem, marketOwner);
        let dataToTransferOwnership = {
            marketId    : marketId,
            itemId      : responseCreateItem.itemId,
            to          : accounts[5]
        };

        assert.isOk((await instance.isItemOwner(marketId, dataToTransferOwnership.itemId, {from:marketOwner})), 
        "Incorrect market owner after item creating for owner");
        assert.isOk(!(await instance.isItemOwner(marketId, dataToTransferOwnership.itemId, {from:accounts[5]})), 
        "Correct market owner after item creating for not owner");

        await testHelper.transferItemOwnership(instance, dataToTransferOwnership, marketOwner);
        assert.isOk(!(await instance.isItemOwner(marketId, dataToTransferOwnership.itemId, {from:marketOwner})), 
        "Correct market owner after transfer ownership for owner");
        assert.isOk((await instance.isItemOwner(marketId, dataToTransferOwnership.itemId, {from:accounts[5]})), 
        "Incorrect market owner after transfer ownership for not owner");
    });

    it("Item type exist", async () => {
        let responseCreateItemType = await testHelper.createItemType(instance, commonDataToCreateItemType, marketOwner);

        assert.isOk((await instance.itemTypeExist(marketId, responseCreateItemType.typeId)), "Item type does not exist after creating");
        assert.isOk(!(await instance.itemTypeExist(marketId, 100000)), "Non-existing Item type exist");
        assert.isOk(!(await instance.itemTypeExist(100000, responseCreateItemType.typeId)), "Non-existing Item type exist");
    });

    it("Item exist", async () => {
        let responseCreateItemType = await testHelper.createItemType(instance, commonDataToCreateItemType, marketOwner);
        let dataToCreateItem = {
            marketId    : marketId,
            typeId      : responseCreateItemType.typeId
        };

        let responseCreateItem = await testHelper.createItem(instance, dataToCreateItem, marketOwner);

        assert.isOk((await instance.itemExist(marketId, responseCreateItem.itemId)), "Item does not exist after creating");
        assert.isOk(!(await instance.itemExist(marketId, 100000)), "Non-existing Item exist");
        assert.isOk(!(await instance.itemExist(100000, responseCreateItem.itemId)), "Non-existing Item exist");
    });
});




/**
 * Data validation
 * @param {struct} localDataStruct data used for creating item type
 * @param {struct} contractDataStruct data saved in contract
 */
function checkItemTypeData (localDataStruct, contractDataStruct){
    assert.equal(localDataStruct.name, contractDataStruct.name, "Incorrect saved type name");
    assert.equal(localDataStruct.totalSuply, contractDataStruct.remainingSuply.toNumber(), 
        "Incorrect saved remainingSuply");
    assert.equal(localDataStruct.totalSuply, contractDataStruct.totalSuply.toNumber(), "Incorrect saved totalSuply");
    assert.equal(localDataStruct.allowSale, contractDataStruct.allowSale, "Incorrect saved allowSale");
    assert.equal(localDataStruct.allowAuction, contractDataStruct.allowAuction, "Incorrect saved allowAuction");
    assert.equal(localDataStruct.allowRent, contractDataStruct.allowRent, "Incorrect saved allowRent");
    assert.equal(localDataStruct.allowLootbox, contractDataStruct.allowLootbox, "Incorrect saved allowLootbox");
}