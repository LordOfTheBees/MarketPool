const MarketPool_ItemRelease_Sale = artifacts.require("./MarketPool_ItemRelease_Sale.sol");

const truffleAssert = require('truffle-assertions');
const testHelper = require("../jsmoduls/test-helper.js");

contract("MarketPool_ItemRelease_Sale Common Test", async accounts => {
    let instance;

    let marketOwner = accounts[1];
    let marketId;
    let itemTypeId;

    var commonDataToCreateMarket = {
        name            : "Common Test Market"
    };

    var commonDataToCreateItemType = {
        marketId        :   0, //undefined
        name            :   "Common Test Type",
        totalSupply     :   99999999,
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
        commonDataToCreateItemType.marketId = responseCreateMarket.marketId;

        let responseCreateItemType = await testHelper.createItemType(instance, commonDataToCreateItemType, marketOwner);
        itemTypeId = responseCreateItemType.typeId;
    });


    it("Create Sale Data Test", async () => {
        let dataToCreateSaleData = {
            marketId        :   marketId,
            itemTypeId      :   itemTypeId,
            totalSupply     :   99999999,
            priceInWei      :   testHelper.ethToWei(0.1)
        }

        let responseCreateSaleData = await testHelper.createSaleData(instance, dataToCreateSaleData, marketOwner);
        let dataInContract = await instance.getSaleData.call(dataToCreateSaleData.marketId, dataToCreateSaleData.itemTypeId);

        assert.equal(dataInContract.marketId, dataToCreateSaleData.marketId, "Incorrect returned marketId");
        assert.equal(dataInContract.itemTypeId, dataToCreateSaleData.itemTypeId, "Incorrect returned itemTypeId");
        assert.equal(dataInContract.priceInWei, dataToCreateSaleData.priceInWei, "Incorrect returned priceInWei");
        assert.equal(dataInContract.remainingSupply, dataToCreateSaleData.totalSupply, "Incorrect returned remainingSupply");
        assert.equal(dataInContract.totalSupply, dataToCreateSaleData.totalSupply, "Incorrect returned totalSupply");
        assert.equal(dataInContract.isFinal, true, "Incorrect returned isFinal");
        assert.equal(dataInContract.enable, false, "Incorrect returned enable");

        console.log(responseCreateSaleData);
        assert.equal(responseCreateSaleData.marketId, dataToCreateSaleData.marketId, "Incorrect marketId from event");
        assert.equal(responseCreateSaleData.itemTypeId, dataToCreateSaleData.itemTypeId, "Incorrect itemTypeId from event");
    });
    /*
    it("", async () => {});
    it("", async () => {});
    it("", async () => {});
    it("", async () => {});
    it("", async () => {});
    it("", async () => {});
    it("", async () => {});
    it("", async () => {});*/
});