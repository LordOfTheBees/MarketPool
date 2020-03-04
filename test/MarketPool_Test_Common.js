const MarketPool = artifacts.require("./MarketPool.sol");
const truffleAssert = require('truffle-assertions');

const zeroAccount = '0x0000000000000000000000000000000000000000';

contract("MarketPool Common Test", accounts => {
    it("Market creation test. Market Exist test", async () => {
        let marketName = "marketName";
        let creationAccount = accounts[1];
        let marketId;
        let instance = await MarketPool.deployed();

        let result = await instance.createMarket(marketName, {from: creationAccount});
        await truffleAssert.eventEmitted(result , 'MarketCreated', async (res) => {
            marketId = res.marketId.toNumber();
        });

        assert.isOk(await instance.marketExist(marketId), "Market does not exist after creation");
    });

    it("Get Market Data", async () => {
        let marketName = "marketName";
        let creationAccount = accounts[1];
        let marketId;
        let instance = await MarketPool.deployed();

        let result = await instance.createMarket(marketName, {from: creationAccount});
        await truffleAssert.eventEmitted(result , 'MarketCreated', async (res) => {
            marketId = res.marketId.toNumber();
        });

        let storedName= await instance.getMarketData.call(marketId);

        assert.equal(storedName, marketName, "Name in contract incorrect");
    });

    it("Transfer Market Ownership", async () => {
        let marketName = "marketName";
        let creationAccount = accounts[1];
        let newOwnerAccount = accounts[2];
        let notOwnerAccount = accounts[3];
        let marketId;
        let instance = await MarketPool.deployed();

        let result = await instance.createMarket(marketName, {from: creationAccount});
        await truffleAssert.eventEmitted(result , 'MarketCreated', async (res) => {
            marketId = res.marketId.toNumber();
        });

        let withoutError = true;
        try {
            await instance.transferMarketOwnership(marketId, '0x0000000000000000000000000000000000000000', {from: creationAccount});
        }
        catch (exception) {
            withoutError = false;
        }
        if(withoutError) throw "Transfer passed without errors with ZERO address"

        withoutError = true;
        try {
            await instance.transferMarketOwnership(marketId, newOwnerAccount, {from: notOwnerAccount});
        }
        catch (exception) {
            withoutError = false;
        }
        if(withoutError) throw "Transfer was successful through the not owner address"

        await instance.transferMarketOwnership(marketId, newOwnerAccount, {from: creationAccount});
        let newOwner = await instance.getMarketOwner.call(marketId);
        assert.equal(newOwner, newOwnerAccount, "Transfer to newOwnerAccount failed");

        await instance.transferMarketOwnership(marketId, creationAccount, {from: newOwnerAccount});
        newOwner = await instance.getMarketOwner.call(marketId);
        assert.equal(newOwner, creationAccount, "Reverse Transfer failed");
    });

    it("Renounce Market Ownership", async () => {
        let marketName = "marketName";
        let creationAccount = accounts[1];
        let notOwnerAccount = accounts[3];
        let marketId;
        let instance = await MarketPool.deployed();

        let result = await instance.createMarket(marketName, {from: creationAccount});
        await truffleAssert.eventEmitted(result , 'MarketCreated', async (res) => {
            marketId = res.marketId.toNumber();
        });


        withoutError = true;
        try {
            await instance.renounceMarketOwnership(marketId, {from: notOwnerAccount});
        }
        catch (exception) {
            withoutError = false;
        }
        if(withoutError) throw "Renounce was successful through the not owner address"


        await instance.renounceMarketOwnership(marketId, {from: creationAccount});
        let newOwner = await instance.getMarketOwner.call(marketId);
        assert.equal(newOwner, '0x0000000000000000000000000000000000000000', "Transfer to newOwnerAccount failed");


        withoutError = true;
        try {
            await instance.transferMarketOwnership(marketId, newOwnerAccount, {from: creationAccount});
        }
        catch (exception) {
            withoutError = false;
        }
        if(withoutError) throw "Transfer was successful after renounce"
    });

    it("Get Market Owner", async () => {
        let marketName = "marketName";
        let creationAccount = accounts[1];
        let newOwnerAccount = accounts[2];
        let marketId;
        let instance = await MarketPool.deployed();

        let result = await instance.createMarket(marketName, {from: creationAccount});
        await truffleAssert.eventEmitted(result , 'MarketCreated', async (res) => {
            marketId = res.marketId.toNumber();
        });
        let owner = await instance.getMarketOwner.call(marketId);
        assert.equal(owner, creationAccount, "Initial owner not creationAccount");


        await instance.transferMarketOwnership(marketId, newOwnerAccount, {from: creationAccount});
        owner = await instance.getMarketOwner.call(marketId);
        assert.equal(owner, newOwnerAccount, "After transfer owner not equal newOwnerAccount");


        await instance.renounceMarketOwnership(marketId, {from: newOwnerAccount});
        owner = await instance.getMarketOwner.call(marketId);
        assert.equal(owner, zeroAccount, "After renounce owner not equal zero");
    });

    it("Is Market Owner", async () => {
        let marketName = "marketName";
        let creationAccount = accounts[1];
        let newOwnerAccount = accounts[2];
        let marketId;
        let instance = await MarketPool.deployed();

        let result = await instance.createMarket(marketName, {from: creationAccount});
        await truffleAssert.eventEmitted(result , 'MarketCreated', async (res) => {
            marketId = res.marketId.toNumber();
        });
        assert.isOk(await instance.isMarketOwner.call(marketId, {from: creationAccount}), "Initial owner not creationAccount");


        await instance.transferMarketOwnership(marketId, newOwnerAccount, {from: creationAccount});
        assert.isOk(await instance.isMarketOwner.call(marketId, {from: newOwnerAccount}), "After transfer owner not equal newOwnerAccount");


        await instance.renounceMarketOwnership(marketId, {from: newOwnerAccount});
        assert.isOk(!(await instance.isMarketOwner.call(marketId, {from: creationAccount})), "After renounce owner not equal zero");
        assert.isOk(!(await instance.isMarketOwner.call(marketId, {from: newOwnerAccount})), "After renounce owner not equal zero");
    });
});