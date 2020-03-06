const MarketPool = artifacts.require("./MarketPool.sol");

const truffleAssert = require('truffle-assertions');
const testHelper = require("../jsmoduls/test-helper.js");

contract("MarketPool Common Test", accounts => {
    let marketName = "marketName";

    it("Market creation test. Market Exist test", async () => {
        
        let creationAccount = accounts[1];
        let instance = await MarketPool.deployed();

        let responseCreateMarket = await testHelper.createMarket(instance, {name : marketName}, creationAccount);
        assert.isOk(await instance.marketExist(responseCreateMarket.marketId), "Market does not exist after creation");
    });

    it("Get Market Data", async () => {
        let creationAccount = accounts[1];
        let instance = await MarketPool.deployed();

        let responseCreateMarket = await testHelper.createMarket(instance, {name : marketName}, creationAccount);
        let marketId = responseCreateMarket.marketId;
        let storedName= await instance.getMarketData.call(marketId);

        assert.equal(storedName, marketName, "Name in contract incorrect");
    });

    it("Transfer Market Ownership", async () => {
        let creationAccount = accounts[1];
        let newOwnerAccount = accounts[2];
        let notOwnerAccount = accounts[3];
        let instance = await MarketPool.deployed();

        let responseCreateMarket = await testHelper.createMarket(instance, {name : marketName}, creationAccount);
        let marketId = responseCreateMarket.marketId;

        await testHelper.testError(
            async () => await instance.transferMarketOwnership(marketId, testHelper.zeroAddress, {from: creationAccount}),
            "Transfer passed without errors with ZERO address"
        )

        await testHelper.testError(
            async () => await instance.transferMarketOwnership(marketId, newOwnerAccount, {from: notOwnerAccount}),
            "Transfer was successful through the not owner address"
        )

        await instance.transferMarketOwnership(marketId, newOwnerAccount, {from: creationAccount});
        let newOwner = await instance.getMarketOwner.call(marketId);
        assert.equal(newOwner, newOwnerAccount, "Transfer to newOwnerAccount failed");

        await instance.transferMarketOwnership(marketId, creationAccount, {from: newOwnerAccount});
        newOwner = await instance.getMarketOwner.call(marketId);
        assert.equal(newOwner, creationAccount, "Reverse Transfer failed");
    });

    it("Renounce Market Ownership", async () => {
        let creationAccount = accounts[1];
        let notOwnerAccount = accounts[3];
        let instance = await MarketPool.deployed();

        let responseCreateMarket = await testHelper.createMarket(instance, {name : marketName}, creationAccount);
        let marketId = responseCreateMarket.marketId;

        await testHelper.testError(
            async () => await instance.renounceMarketOwnership(marketId, {from: notOwnerAccount}),
            "Renounce was successful through the not owner address");

        await instance.renounceMarketOwnership(marketId, {from: creationAccount});
        let newOwner = await instance.getMarketOwner.call(marketId);
        assert.equal(newOwner, '0x0000000000000000000000000000000000000000', "Transfer to newOwnerAccount failed");

        
        await testHelper.testError(
            async () => await instance.transferMarketOwnership(marketId, newOwnerAccount, {from: creationAccount}),
            "Transfer was successful after renounce");
    });

    it("Get Market Owner", async () => {
        let creationAccount = accounts[1];
        let newOwnerAccount = accounts[2];
        let instance = await MarketPool.deployed();

        let responseCreateMarket = await testHelper.createMarket(instance, {name : marketName}, creationAccount);
        let marketId = responseCreateMarket.marketId;

        let owner = await instance.getMarketOwner.call(marketId);
        assert.equal(owner, creationAccount, "Initial owner not creationAccount");


        await instance.transferMarketOwnership(marketId, newOwnerAccount, {from: creationAccount});
        owner = await instance.getMarketOwner.call(marketId);
        assert.equal(owner, newOwnerAccount, "After transfer owner not equal newOwnerAccount");


        await instance.renounceMarketOwnership(marketId, {from: newOwnerAccount});
        owner = await instance.getMarketOwner.call(marketId);
        assert.equal(owner, testHelper.zeroAddress, "After renounce owner not equal zero");
    });

    it("Is Market Owner", async () => {
        let creationAccount = accounts[1];
        let newOwnerAccount = accounts[2];
        let instance = await MarketPool.deployed();

        let responseCreateMarket = await testHelper.createMarket(instance, {name : marketName}, creationAccount);
        let marketId = responseCreateMarket.marketId;

        assert.isOk(await instance.isMarketOwner.call(marketId, {from: creationAccount}), "Initial owner not creationAccount");


        await instance.transferMarketOwnership(marketId, newOwnerAccount, {from: creationAccount});
        assert.isOk(await instance.isMarketOwner.call(marketId, {from: newOwnerAccount}), "After transfer owner not equal newOwnerAccount");


        await instance.renounceMarketOwnership(marketId, {from: newOwnerAccount});
        assert.isOk(!(await instance.isMarketOwner.call(marketId, {from: creationAccount})), "After renounce owner not equal zero");
        assert.isOk(!(await instance.isMarketOwner.call(marketId, {from: newOwnerAccount})), "After renounce owner not equal zero");
    });
});