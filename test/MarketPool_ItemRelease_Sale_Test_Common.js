const MarketPool_ItemRelease_Sale = artifacts.require("./MarketPool_ItemRelease_Sale.sol");

const truffleAssert = require('truffle-assertions');
const testHelper = require("../jsmoduls/test-helper.js");

contract("MarketPool_ItemRelease_Sale Common Test", async accounts => {
    let instance;

    let notExistingMarketId = Number.MAX_VALUE;
    let notExistingItemTypeId = Number.MAX_VALUE;

    let marketOwner = accounts[1];
    let notMarketOwner = accounts[2];
    let marketId;
    let itemTypeId1;
    let itemTypeId2;
    let itemTypeId3;

    var commonDataToCreateMarket = {
        name            : "Common Test Market"
    };

    var commonDataToCreateItemType1 = {
        marketId        :   0, //undefined
        name            :   "Common Test Type 1",
        totalSupply     :   0,
        allowSale       :   true,
        allowAuction    :   true,
        allowRent       :   true,
        allowLootbox    :   true
    };
    var commonDataToCreateItemType2 = {
        marketId        :   0, //undefined
        name            :   "Common Test Type 2",
        totalSupply     :   0,
        allowSale       :   true,
        allowAuction    :   true,
        allowRent       :   true,
        allowLootbox    :   true
    };
    var commonDataToCreateItemType3 = {
        marketId        :   0, //undefined
        name            :   "Common Test Type 3",
        totalSupply     :   0,
        allowSale       :   true,
        allowAuction    :   true,
        allowRent       :   true,
        allowLootbox    :   true
    };

    before(async () => {
        instance = await MarketPool_ItemRelease_Sale.deployed();
    });

    //Создаём новый магазин перед каждым тестом
    beforeEach(async () => {
        let responseCreateMarket = await testHelper.createMarket(instance, commonDataToCreateMarket, marketOwner);
        marketId = responseCreateMarket.marketId;
        commonDataToCreateItemType1.marketId = responseCreateMarket.marketId;
        commonDataToCreateItemType2.marketId = responseCreateMarket.marketId;
        commonDataToCreateItemType3.marketId = responseCreateMarket.marketId;

        let responseCreateItemType = await testHelper.createItemType(instance, commonDataToCreateItemType1, marketOwner);
        itemTypeId1 = responseCreateItemType.typeId;

        responseCreateItemType = await testHelper.createItemType(instance, commonDataToCreateItemType2, marketOwner);
        itemTypeId2 = responseCreateItemType.typeId;

        responseCreateItemType = await testHelper.createItemType(instance, commonDataToCreateItemType3, marketOwner);
        itemTypeId3 = responseCreateItemType.typeId;
    });


    it("Create Sale Release Test", async () => {
        let dataToCreateSaleRelease = {
            marketId        :   marketId,
            itemTypeIdArray :   [itemTypeId1, itemTypeId2],
            totalSupply     :   99999999,
            priceInWei      :   testHelper.ethToWei(0.1),
            enable          :   true
        }

        let responseCreateSaleRelease = await testHelper.createSaleRelease(instance, dataToCreateSaleRelease, marketOwner);
        assert.equal(responseCreateSaleRelease.marketId, dataToCreateSaleRelease.marketId, "Incorrect marketId from event");

        let dataInContract = await instance.getSaleRelease.call(responseCreateSaleRelease.marketId, responseCreateSaleRelease.saleReleaseInnerId);

        assert.equal(dataInContract.marketId, dataToCreateSaleRelease.marketId, "Incorrect returned marketId");
        assert.equal(dataInContract.priceInWei, dataToCreateSaleRelease.priceInWei, "Incorrect returned priceInWei");
        assert.equal(dataInContract.remainingSupply, dataToCreateSaleRelease.totalSupply, "Incorrect returned remainingSupply");
        assert.equal(dataInContract.totalSupply, dataToCreateSaleRelease.totalSupply, "Incorrect returned totalSupply");
        assert.equal(dataInContract.isFinal, true, "Incorrect returned isFinal");
        assert.equal(dataInContract.enable, dataToCreateSaleRelease.enable, "Incorrect returned enable");

        testHelper.toNumberArray(dataInContract.itemTypeIdArray).forEach(element => {
            let index = dataToCreateSaleRelease.itemTypeIdArray.indexOf(element);
            assert.isOk(index >= 0, "Cannot find item type id. Invalid data was saved");
            dataToCreateSaleRelease.itemTypeIdArray.splice(index, 1);
        });

        assert.isOk(dataToCreateSaleRelease.itemTypeIdArray.length == 0, "The number of saved item type ids differs from the number of transmitted ones");
    });

    it("Create Sale Release Test With Errors", async () => {
        let dataToCreateSaleRelease = {
            marketId        :   marketId,
            itemTypeIdArray :   [itemTypeId1, itemTypeId2],
            totalSupply     :   99999999,
            priceInWei      :   testHelper.ethToWei(0.1),
            enable          :   true
        }

        await testHelper.testError(async () => {
            await testHelper.createSaleRelease(instance, dataToCreateSaleRelease, notMarketOwner);
        }, "Not the market owner was able to create the sale release");
        
        dataToCreateSaleRelease.itemTypeIdArray = [notExistingItemTypeId];
        await testHelper.testError(async () => {
            await testHelper.createSaleRelease(instance, dataToCreateSaleRelease, marketOwner);
        }, "Success to create an sale release with a nonexistent item type");
        dataToCreateSaleRelease.itemTypeIdArray = [itemTypeId1, itemTypeId2];

        dataToCreateSaleRelease.marketId = notExistingMarketId;
        await testHelper.testError(async () => {
            await testHelper.createSaleRelease(instance, dataToCreateSaleRelease, marketOwner);
        }, "Success to create an sale release in a nonexistent market");
        dataToCreateSaleRelease.marketId = marketId;

        dataToCreateSaleRelease.itemTypeIdArray = [notExistingItemTypeId];
        await testHelper.testError(async () => {
            await testHelper.createSaleRelease(instance, dataToCreateSaleRelease, marketOwner);
        }, "Success to create an sale release without item types");
    });
    
    it("Remove Sale Release Test", async () => {
        let dataToCreateSaleRelease = {
            marketId        :   marketId,
            itemTypeIdArray :   [itemTypeId1, itemTypeId2],
            totalSupply     :   99999999,
            priceInWei      :   testHelper.ethToWei(0.1),
            enable          :   true
        }

        let responseCreateSaleRelease = await testHelper.createSaleRelease(instance, dataToCreateSaleRelease, marketOwner);
        let dataToRemoveSaleRelease = 
        {
            marketId                : responseCreateSaleRelease.marketId,
            saleReleaseInnerId      : responseCreateSaleRelease.saleReleaseInnerId,
        }
        let responseRemoveSaleRelease = await testHelper.removeSaleRelease(instance, dataToRemoveSaleRelease, marketOwner);
        assert.equal(dataToRemoveSaleRelease.marketId, responseRemoveSaleRelease.marketId, "Incorrect marketId From event");
        assert.equal(dataToRemoveSaleRelease.saleReleaseInnerId, responseRemoveSaleRelease.saleReleaseInnerId, "Incorrect saleReleaseInnerId From event");


        let saleReleaseExists = await instance.saleReleaseExists.call(dataToRemoveSaleRelease.marketId, dataToRemoveSaleRelease.saleReleaseInnerId);
        assert.isOk(!saleReleaseExists, "The element was not deleted");
    });

    it("Remove Sale Release Test With Errors", async () => {
        let dataToCreateSaleRelease = {
            marketId        :   marketId,
            itemTypeIdArray :   [itemTypeId1, itemTypeId2],
            totalSupply     :   99999999,
            priceInWei      :   testHelper.ethToWei(0.1),
            enable          :   true
        }

        let responseCreateSaleRelease = await testHelper.createSaleRelease(instance, dataToCreateSaleRelease, marketOwner);
        let dataToRemoveSaleRelease = 
        {
            marketId                : responseCreateSaleRelease.marketId,
            saleReleaseInnerId      : responseCreateSaleRelease.saleReleaseInnerId,
        }
        await testHelper.testError(async () => {
            await testHelper.removeSaleRelease(instance, dataToRemoveSaleRelease, notMarketOwner);
        }, "Not the market owner was able to remove the sale release");

        dataToRemoveSaleRelease.marketId = notExistingMarketId;
        await testHelper.testError(async () => {
            await testHelper.removeSaleRelease(instance, dataToRemoveSaleRelease, marketOwner);
        }, "Success to remove an sale release with a nonexistent market");
    });

    it("Update Sale Release Test", async () => {
        let dataToCreateSaleRelease = {
            marketId        :   marketId,
            itemTypeIdArray :   [itemTypeId1, itemTypeId2],
            totalSupply     :   99999999,
            priceInWei      :   testHelper.ethToWei(0.1),
            enable          :   true
        }

        let responseCreateSaleRelease = await testHelper.createSaleRelease(instance, dataToCreateSaleRelease, marketOwner);
        
        let dataToUpdateSaleRelease = {
            marketId                : responseCreateSaleRelease.marketId,
            saleReleaseInnerId      : responseCreateSaleRelease.saleReleaseInnerId,
            totalSupply             : 10,
            priceInWei              : testHelper.ethToWei(0.3),
            enable                  : false
        }
        let responseUpdateSaleRelease = await testHelper.updateSaleRelease(instance, dataToUpdateSaleRelease, marketOwner);
        let dataInContract = await instance.getSaleRelease.call(responseUpdateSaleRelease.marketId, responseUpdateSaleRelease.saleReleaseInnerId);
        assert.equal(dataToUpdateSaleRelease.marketId, responseUpdateSaleRelease.marketId, "Incorrect marketId from event");


        assert.equal(dataInContract.marketId, dataToUpdateSaleRelease.marketId, "Incorrect returned marketId");
        assert.equal(dataInContract.priceInWei, dataToUpdateSaleRelease.priceInWei, "Incorrect returned priceInWei");
        assert.equal(dataInContract.remainingSupply, dataToUpdateSaleRelease.totalSupply, "Incorrect returned remainingSupply");
        assert.equal(dataInContract.totalSupply, dataToUpdateSaleRelease.totalSupply, "Incorrect returned totalSupply");
        assert.equal(dataInContract.isFinal, true, "Incorrect returned isFinal");
        assert.equal(dataInContract.enable, dataToUpdateSaleRelease.enable, "Incorrect returned enable");

        testHelper.toNumberArray(dataInContract.itemTypeIdArray).forEach(element => {
            let index = dataToCreateSaleRelease.itemTypeIdArray.indexOf(element);
            assert.isOk(index >= 0, "Cannot find item type id. Invalid data was saved");
            dataToCreateSaleRelease.itemTypeIdArray.splice(index, 1);
        });

        assert.isOk(dataToCreateSaleRelease.itemTypeIdArray.length == 0, "The number of saved item type ids differs from the number of transmitted ones");
    });

    it("Update Sale Release Test With Errors", async () => {
        let dataToCreateSaleRelease = {
            marketId        :   marketId,
            itemTypeIdArray :   [itemTypeId1, itemTypeId2],
            totalSupply     :   99999999,
            priceInWei      :   testHelper.ethToWei(0.1),
            enable          :   true
        }

        let responseCreateSaleRelease = await testHelper.createSaleRelease(instance, dataToCreateSaleRelease, marketOwner);
        let dataToUpdateSaleRelease = {
            marketId                : responseCreateSaleRelease.marketId,
            saleReleaseInnerId      : responseCreateSaleRelease.saleReleaseInnerId,
            totalSupply             : 10,
            priceInWei              : testHelper.ethToWei(0.3),
            enable                  : false
        }

        await testHelper.testError(async () => {
            await testHelper.updateSaleRelease(instance, dataToUpdateSaleRelease, notMarketOwner);
        }, "Not the market owner was able to remove the sale release");

        dataToUpdateSaleRelease.marketId = notExistingMarketId;
        await testHelper.testError(async () => {
            await testHelper.updateSaleRelease(instance, dataToUpdateSaleRelease, notMarketOwner);
        }, "Success to remove an sale release with a nonexistent market");
        dataToUpdateSaleRelease.marketId = responseCreateSaleRelease.marketId;
    });

    it("Test Final Status after creating and update in SaleRelease", async () => {
        let dataToCreateSaleRelease = {
            marketId        :   marketId,
            itemTypeIdArray :   [itemTypeId1, itemTypeId2],
            totalSupply     :   99999999,
            priceInWei      :   testHelper.ethToWei(0.1),
            enable          :   true
        }

        let responseCreateSaleRelease = await testHelper.createSaleRelease(instance, dataToCreateSaleRelease, marketOwner);
        let dataInContract = await instance.getSaleRelease.call(responseCreateSaleRelease.marketId, responseCreateSaleRelease.saleReleaseInnerId);
        assert.equal(dataInContract.isFinal, true, "Incorrect returned isFinal after creating");
        
        let dataToUpdateSaleRelease = {
            marketId                : responseCreateSaleRelease.marketId,
            saleReleaseInnerId      : responseCreateSaleRelease.saleReleaseInnerId,
            totalSupply             : 10,
            priceInWei              : testHelper.ethToWei(0.3),
            enable                  : false
        }
        await testHelper.updateSaleRelease(instance, dataToUpdateSaleRelease, marketOwner);
        dataInContract = await instance.getSaleRelease.call(responseCreateSaleRelease.marketId, responseCreateSaleRelease.saleReleaseInnerId);
        assert.equal(dataInContract.isFinal, true, "Incorrect returned isFinal");

        dataToUpdateSaleRelease.totalSupply = 0;
        await testHelper.updateSaleRelease(instance, dataToUpdateSaleRelease, marketOwner);
        dataInContract = await instance.getSaleRelease.call(responseCreateSaleRelease.marketId, responseCreateSaleRelease.saleReleaseInnerId);
        assert.equal(dataInContract.isFinal, false, "Incorrect returned isFinal");

        dataToUpdateSaleRelease.totalSupply = 10;
        await testHelper.updateSaleRelease(instance, dataToUpdateSaleRelease, marketOwner);
        dataInContract = await instance.getSaleRelease.call(responseCreateSaleRelease.marketId, responseCreateSaleRelease.saleReleaseInnerId);
        assert.equal(dataInContract.isFinal, true, "Incorrect returned isFinal");

        dataToCreateSaleRelease.totalSupply = 0;
        responseCreateSaleRelease = await testHelper.createSaleRelease(instance, dataToCreateSaleRelease, marketOwner);
        dataToUpdateSaleRelease.saleReleaseInnerId = responseCreateSaleRelease.saleReleaseInnerId;
        dataInContract = await instance.getSaleRelease.call(responseCreateSaleRelease.marketId, responseCreateSaleRelease.saleReleaseInnerId);
        assert.equal(dataInContract.isFinal, false, "Incorrect returned isFinal after creating");

        dataToUpdateSaleRelease.totalSupply = 10;
        await testHelper.updateSaleRelease(instance, dataToUpdateSaleRelease, marketOwner);
        dataInContract = await instance.getSaleRelease.call(responseCreateSaleRelease.marketId, responseCreateSaleRelease.saleReleaseInnerId);
        assert.equal(dataInContract.isFinal, true, "Incorrect returned isFinal");
    });

    it("Buy Sale Release Simple", async () => {
        let dataToCreateSaleRelease = {
            marketId        :   marketId,
            itemTypeIdArray :   [itemTypeId1, itemTypeId2],
            totalSupply     :   0,
            priceInWei      :   testHelper.ethToWei(0.1),
            enable          :   true
        }
        let accountItemsOwner = accounts[7];
        let responseCreateSaleRelease = await testHelper.createSaleRelease(instance, dataToCreateSaleRelease, marketOwner);

        let dataToBuySaleRelease = {
            marketId            : marketId,
            saleReleaseInnerId  : responseCreateSaleRelease.saleReleaseInnerId,
            newOwner            : accountItemsOwner
        }

        let responseBuySaleRelease = await testHelper.buySaleRelease(instance, dataToBuySaleRelease, accountItemsOwner, testHelper.ethToWei(10.0));
        assert.equal(dataToBuySaleRelease.marketId, responseBuySaleRelease.marketId, "Incorrect marketId from event");
        assert.equal(dataToBuySaleRelease.saleReleaseInnerId, responseBuySaleRelease.saleReleaseInnerId, "Incorrect saleReleaseInnerId from event");

        let tmpItemTypeIdArray = dataToCreateSaleRelease.itemTypeIdArray.slice(0);
        for(let i = 0; i < responseBuySaleRelease.itemIdArray.length; ++i) {
            let itemTypeId = (await instance.getItemData.call(dataToCreateSaleRelease.marketId, responseBuySaleRelease.itemIdArray[i])).toNumber();
            let isItemOwner = await instance.isItemOwner.call(dataToCreateSaleRelease.marketId, responseBuySaleRelease.itemIdArray[i], {from: accountItemsOwner});
            let index = tmpItemTypeIdArray.indexOf(itemTypeId);
            assert.isOk(index >= 0, "Cannot find item type id. Invalid data was saved");
            assert.isOk(isItemOwner, "Incorrect item type owner");
            tmpItemTypeIdArray.splice(index, 1);
        }
        assert.isOk(tmpItemTypeIdArray.length == 0, "The number of bought item ids differs from the number of transmitted ones");
    });

    it("Buy Sale Release with Final status in Sale Release", async () => {
        let itemTypeTotalSupply = 0;
        let saleReleaseTotalSupply = 3;
        let updateTotalSupply = 5;
        var dataToCreateItemType = {
            marketId        :   marketId, //undefined
            name            :   "Test Type",
            totalSupply     :   itemTypeTotalSupply,
            allowSale       :   true,
            allowAuction    :   true,
            allowRent       :   true,
            allowLootbox    :   true
        };
        let responseCreateItemType = await testHelper.createItemType(instance, dataToCreateItemType, marketOwner);

        let dataToCreateSaleRelease = {
            marketId        :   marketId,
            itemTypeIdArray :   [responseCreateItemType.typeId],
            totalSupply     :   saleReleaseTotalSupply,
            priceInWei      :   testHelper.ethToWei(0.01),
            enable          :   true
        }
        let accountBuyer = accounts[8];
        let accountItemsOwner = accounts[7];
        let initialBalanceOfItems = (await instance.balanceOfItems.call(dataToCreateItemType.marketId, accountItemsOwner)).toNumber();
        let responseCreateSaleRelease = await testHelper.createSaleRelease(instance, dataToCreateSaleRelease, marketOwner);

        let dataToBuySaleRelease = {
            marketId            : marketId,
            saleReleaseInnerId  : responseCreateSaleRelease.saleReleaseInnerId,
            newOwner            : accountItemsOwner
        }
        for(let i = 0; i < dataToCreateSaleRelease.totalSupply; ++i) {
            let responseBuySaleRelease = await testHelper.buySaleRelease(instance, dataToBuySaleRelease, accountBuyer, testHelper.ethToWei(0.01));
            for(let j = 0; j < responseBuySaleRelease.itemIdArray.length; ++j)
                assert.isOk(await instance.isItemOwner(responseBuySaleRelease.marketId, responseBuySaleRelease.itemIdArray[j], {from: accountItemsOwner}), "Item owner inccorrect");
        }
        
        await testHelper.testError(async () => {
            await testHelper.buySaleRelease(instance, dataToBuySaleRelease, accountBuyer, testHelper.ethToWei(0.01));
        }, "Bought was successful after the number of elements has been exhausted");

        let dataToUpdateSaleRelease = {
            marketId                : responseCreateSaleRelease.marketId,
            saleReleaseInnerId      : responseCreateSaleRelease.saleReleaseInnerId,
            totalSupply             : updateTotalSupply,
            priceInWei              : testHelper.ethToWei(0.3),
            enable                  : true
        }
        let responseUpdateSaleRelease = await testHelper.updateSaleRelease(instance, dataToUpdateSaleRelease, marketOwner);

        for(let i = 0; i < dataToUpdateSaleRelease.totalSupply; ++i) {
            let responseBuySaleRelease = await testHelper.buySaleRelease(instance, dataToBuySaleRelease, accountBuyer, testHelper.ethToWei(0.3));
            for(let j = 0; j < responseBuySaleRelease.itemIdArray.length; ++j)
                assert.isOk(await instance.isItemOwner(responseBuySaleRelease.marketId, responseBuySaleRelease.itemIdArray[j], {from: accountItemsOwner}), "Item owner inccorrect after update");
        }
        
        await testHelper.testError(async () => {
            await testHelper.buySaleRelease(instance, dataToBuySaleRelease, accountBuyer, testHelper.ethToWei(0.3));
        }, "Bought was successful after the number of elements has been exhausted after update");

        let balanceOfItems = (await instance.balanceOfItems.call(responseCreateSaleRelease.marketId, accountItemsOwner)).toNumber();
        assert.equal(balanceOfItems - initialBalanceOfItems, dataToCreateSaleRelease.totalSupply * dataToCreateSaleRelease.itemTypeIdArray.length + dataToUpdateSaleRelease.totalSupply * dataToCreateSaleRelease.itemTypeIdArray.length, 
            "Inccorrect item balance after bought");
    });

    it("Buy Sale Release with Final status in Items", async () => {
        let itemTypeTotalSupply = 5;
        let saleReleaseTotalSupply = 0;
        var dataToCreateItemType = {
            marketId        :   marketId, //undefined
            name            :   "Test Type",
            totalSupply     :   itemTypeTotalSupply,
            allowSale       :   true,
            allowAuction    :   true,
            allowRent       :   true,
            allowLootbox    :   true
        };
        let responseCreateItemType = await testHelper.createItemType(instance, dataToCreateItemType, marketOwner);

        let dataToCreateSaleRelease = {
            marketId        :   marketId,
            itemTypeIdArray :   [responseCreateItemType.typeId],
            totalSupply     :   saleReleaseTotalSupply,
            priceInWei      :   testHelper.ethToWei(0.01),
            enable          :   true
        }
        let accountBuyer = accounts[8];
        let accountItemsOwner = accounts[7];
        let responseCreateSaleRelease = await testHelper.createSaleRelease(instance, dataToCreateSaleRelease, marketOwner);

        let dataToBuySaleRelease = {
            marketId            : marketId,
            saleReleaseInnerId  : responseCreateSaleRelease.saleReleaseInnerId,
            newOwner            : accountItemsOwner
        }

        for(let i = 0; i < dataToCreateItemType.totalSupply; ++i) {
            await testHelper.buySaleRelease(instance, dataToBuySaleRelease, accountBuyer, testHelper.ethToWei(0.01));
        }
        await testHelper.testError(async () => {
            await testHelper.buySaleRelease(instance, dataToBuySaleRelease, accountBuyer, testHelper.ethToWei(0.01));
        }, "Bought was successful after the number of item types has been exhausted");
    });

    it("Buy Sale Release Check Price", async () => {
        let saleReleaseTotalSupply = 0;
        let price = testHelper.ethToWei(0.01);
        let morePrice = testHelper.ethToWei(0.02);
        let lessPrice = testHelper.ethToWei(0.001);

        let dataToCreateSaleRelease = {
            marketId        :   marketId,
            itemTypeIdArray :   [itemTypeId1, itemTypeId3],
            totalSupply     :   saleReleaseTotalSupply,
            priceInWei      :   price,
            enable          :   true
        }
        let accountBuyer = accounts[8];
        let accountItemsOwner = accounts[7];
        let responseCreateSaleRelease = await testHelper.createSaleRelease(instance, dataToCreateSaleRelease, marketOwner);

        let dataToBuySaleRelease = {
            marketId            : marketId,
            saleReleaseInnerId  : responseCreateSaleRelease.saleReleaseInnerId,
            newOwner            : accountItemsOwner
        }
        await testHelper.buySaleRelease(instance, dataToBuySaleRelease, accountBuyer, price);
        await testHelper.buySaleRelease(instance, dataToBuySaleRelease, accountBuyer, morePrice);
        await testHelper.testError(async () => {
            await testHelper.buySaleRelease(instance, dataToBuySaleRelease, accountBuyer, lessPrice);
        }, "Bought was successful with less money");
    });

    it("Buy Sale Release Check Enable/Disabe", async () => {
        let saleReleaseTotalSupply = 0;
        let price = testHelper.ethToWei(0.01);

        let dataToCreateSaleRelease = {
            marketId        :   marketId,
            itemTypeIdArray :   [itemTypeId1, itemTypeId3],
            totalSupply     :   saleReleaseTotalSupply,
            priceInWei      :   price,
            enable          :   true
        }
        let accountBuyer = accounts[8];
        let accountItemsOwner = accounts[7];
        let responseCreateSaleRelease = await testHelper.createSaleRelease(instance, dataToCreateSaleRelease, marketOwner);

        let dataToBuySaleRelease = {
            marketId            : marketId,
            saleReleaseInnerId  : responseCreateSaleRelease.saleReleaseInnerId,
            newOwner            : accountItemsOwner
        }
        await testHelper.buySaleRelease(instance, dataToBuySaleRelease, accountBuyer, price);

        let dataToUpdateSaleRelease = {
            marketId                : responseCreateSaleRelease.marketId,
            saleReleaseInnerId      : responseCreateSaleRelease.saleReleaseInnerId,
            totalSupply             : 0,
            priceInWei              : price,
            enable                  : false
        }
        let responseUpdateSaleRelease = await testHelper.updateSaleRelease(instance, dataToUpdateSaleRelease, marketOwner);

        await testHelper.testError(async () => {
            await testHelper.buySaleRelease(instance, dataToBuySaleRelease, accountBuyer, lessPrice);
        }, "Bought was successful with disabled release item");

        dataToUpdateSaleRelease.enable = true;
        responseUpdateSaleRelease = await testHelper.updateSaleRelease(instance, dataToUpdateSaleRelease, marketOwner);
        await testHelper.buySaleRelease(instance, dataToBuySaleRelease, accountBuyer, price);
    });

    it("Get Sale Release", async () => {
        let saleReleaseTotalSupply = 10;
        let price = testHelper.ethToWei(0.01);
        let morePrice = testHelper.ethToWei(0.02);

        let dataToCreateSaleRelease = {
            marketId        :   marketId,
            itemTypeIdArray :   [itemTypeId1, itemTypeId3],
            totalSupply     :   saleReleaseTotalSupply,
            priceInWei      :   price,
            enable          :   false
        }
        let accountBuyer = accounts[8];
        let accountItemsOwner = accounts[7];
        let responseCreateSaleRelease = await testHelper.createSaleRelease(instance, dataToCreateSaleRelease, marketOwner);

        let responseGetData = await instance.getSaleRelease(responseCreateSaleRelease.marketId, responseCreateSaleRelease.saleReleaseInnerId);
        assert.equal(dataToCreateSaleRelease.marketId, responseGetData.marketId.toNumber(), "MarketID inccorect from getter");
        assert.equal(dataToCreateSaleRelease.priceInWei, responseGetData.priceInWei, "PriceInWei inccorect from getter");
        assert.equal(dataToCreateSaleRelease.totalSupply, responseGetData.remainingSupply.toNumber(), "RenainingSupply inccorect from getter");
        assert.equal(dataToCreateSaleRelease.totalSupply, responseGetData.totalSupply.toNumber(), "TotalSupply inccorect from getter");
        assert.equal(dataToCreateSaleRelease.totalSupply > 0, responseGetData.isFinal, "IsFinal inccorect from getter");
        assert.equal(dataToCreateSaleRelease.enable, responseGetData.enable, "Enable inccorect from getter");

        let tmpItemTypeIdArray = dataToCreateSaleRelease.itemTypeIdArray.slice(0);
        for(let i = 0; i < responseGetData.itemTypeIdArray.length; ++i) {
            let index = tmpItemTypeIdArray.indexOf(responseGetData.itemTypeIdArray[i].toNumber());
            assert.isOk(index >= 0, "Cannot find item type id. Invalid data was saved");
            tmpItemTypeIdArray.splice(index, 1);
        }
        assert.isOk(tmpItemTypeIdArray.length == 0, "The number of bought item ids differs from the number of transmitted ones");


        let dataToUpdateSaleRelease = {
            marketId                : responseCreateSaleRelease.marketId,
            saleReleaseInnerId      : responseCreateSaleRelease.saleReleaseInnerId,
            totalSupply             : 0,
            priceInWei              : morePrice,
            enable                  : false
        }
        await testHelper.updateSaleRelease(instance, dataToUpdateSaleRelease, marketOwner);
        responseGetData = await instance.getSaleRelease(responseCreateSaleRelease.marketId, responseCreateSaleRelease.saleReleaseInnerId);
        assert.equal(dataToUpdateSaleRelease.priceInWei, responseGetData.priceInWei, "PriceInWei inccorect from getter after update");
        assert.equal(0, responseGetData.remainingSupply.toNumber(), "RenainingSupply inccorect from getter after update");
        assert.equal(0, responseGetData.totalSupply.toNumber(), "TotalSupply inccorect from getter after update");
        assert.equal(false, responseGetData.isFinal, "IsFinal inccorect from getter after update");
        assert.equal(dataToUpdateSaleRelease.enable, responseGetData.enable, "Enable inccorect from getter after update");

        dataToUpdateSaleRelease.totalSupply = 5;
        dataToUpdateSaleRelease.enable = true;
        await testHelper.updateSaleRelease(instance, dataToUpdateSaleRelease, marketOwner);
        let dataToBuySaleRelease = {
            marketId            : marketId,
            saleReleaseInnerId  : responseCreateSaleRelease.saleReleaseInnerId,
            newOwner            : accountItemsOwner
        }
        await testHelper.buySaleRelease(instance, dataToBuySaleRelease, accountBuyer, morePrice);
        responseGetData = await instance.getSaleRelease(responseCreateSaleRelease.marketId, responseCreateSaleRelease.saleReleaseInnerId);
        assert.equal(dataToUpdateSaleRelease.priceInWei, responseGetData.priceInWei, "PriceInWei inccorect from getter after update and bought");
        assert.equal(dataToUpdateSaleRelease.totalSupply - 1, responseGetData.remainingSupply.toNumber(), "RenainingSupply inccorect from getter after update and bought");
        assert.equal(dataToUpdateSaleRelease.totalSupply, responseGetData.totalSupply.toNumber(), "TotalSupply inccorect from getter after update and bought");
        assert.equal(dataToUpdateSaleRelease.totalSupply > 0, responseGetData.isFinal, "IsFinal inccorect from getter after update and bought");
        assert.equal(dataToUpdateSaleRelease.enable, responseGetData.enable, "Enable inccorect from getter after update and bought");
    });

    it("Get Sale Release Array For Item Type", async () => {
        let saleReleaseTotalSupply = 10;
        let price = testHelper.ethToWei(0.01);
        let morePrice = testHelper.ethToWei(0.02);

        let dataToCreateSaleRelease = {
            marketId        :   marketId,
            itemTypeIdArray :   [itemTypeId1, itemTypeId3],
            totalSupply     :   saleReleaseTotalSupply,
            priceInWei      :   price,
            enable          :   false
        }
        let accountBuyer = accounts[8];
        let accountItemsOwner = accounts[7];
        let responseCreateSaleRelease1 = await testHelper.createSaleRelease(instance, dataToCreateSaleRelease, marketOwner);

        dataToCreateSaleRelease.itemTypeIdArray = [itemTypeId3]
        let responseCreateSaleRelease2 = await testHelper.createSaleRelease(instance, dataToCreateSaleRelease, marketOwner);

        dataToCreateSaleRelease.itemTypeIdArray = [itemTypeId1, itemTypeId3]
        let responseCreateSaleRelease3 = await testHelper.createSaleRelease(instance, dataToCreateSaleRelease, marketOwner);

        let arraySaleReleasesItemType1 = await instance.getSaleReleaseArrayForItemType.call(dataToCreateSaleRelease.marketId, itemTypeId1);
        let arraySaleReleasesItemType3 = await instance.getSaleReleaseArrayForItemType.call(dataToCreateSaleRelease.marketId, itemTypeId3);

        checkArrays(
            [responseCreateSaleRelease1.saleReleaseInnerId, responseCreateSaleRelease3.saleReleaseInnerId],
            arraySaleReleasesItemType1,
            "ItemType1");
        checkArrays(
            [responseCreateSaleRelease1.saleReleaseInnerId, responseCreateSaleRelease2.saleReleaseInnerId, responseCreateSaleRelease3.saleReleaseInnerId],
            arraySaleReleasesItemType3,
            "ItemType3");

        await testHelper.removeSaleRelease(instance, responseCreateSaleRelease1, marketOwner);

        arraySaleReleasesItemType1 = await instance.getSaleReleaseArrayForItemType.call(dataToCreateSaleRelease.marketId, itemTypeId1);
        arraySaleReleasesItemType3 = await instance.getSaleReleaseArrayForItemType.call(dataToCreateSaleRelease.marketId, itemTypeId3);

        
        checkArrays(
            [responseCreateSaleRelease3.saleReleaseInnerId],
            arraySaleReleasesItemType1,
            "ItemType1 after remove one");
        checkArrays(
            [responseCreateSaleRelease2.saleReleaseInnerId, responseCreateSaleRelease3.saleReleaseInnerId],
            arraySaleReleasesItemType3,
            "ItemType3 after remove one");
    });

    it("Sale Release Exists", async () => {
        assert.isOk(!(await instance.saleReleaseExists.call(marketId, 999999999)), "Non existing sale release exists!")

        let saleReleaseTotalSupply = 10;
        let price = testHelper.ethToWei(0.01);

        let dataToCreateSaleRelease = {
            marketId        :   marketId,
            itemTypeIdArray :   [itemTypeId1, itemTypeId3],
            totalSupply     :   saleReleaseTotalSupply,
            priceInWei      :   price,
            enable          :   false
        }
        let responseCreateSaleRelease = await testHelper.createSaleRelease(instance, dataToCreateSaleRelease, marketOwner);
        assert.isOk(await instance.saleReleaseExists.call(marketId, responseCreateSaleRelease.saleReleaseInnerId), "Sale release does not exists!")

        await testHelper.removeSaleRelease(instance, responseCreateSaleRelease, marketOwner);
        assert.isOk(!(await instance.saleReleaseExists.call(marketId, responseCreateSaleRelease.saleReleaseInnerId)), "Sale release exists after removing!")
    });
    /*
    it("", async () => {});
    it("", async () => {});
    it("", async () => {});
    it("", async () => {});*/
});

function checkArrays(nArray, bnArray, addToError){
    let arrayInContract = bnArray.slice(0);
    let checkArray = nArray.slice(0);
    for(let i = 0; i < arrayInContract.length; ++i) {
        let index = checkArray.indexOf(arrayInContract[i].toNumber());
        assert.isOk(index >= 0, "Cannot find sale release id. Invalid data was saved." + addToError);
        checkArray.splice(index, 1);
    }
    assert.isOk(checkArray.length == 0, "Couldn't find all the elements." + addToError);
}