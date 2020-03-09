const truffleAssert = require('truffle-assertions');

/**
 * Calls the passed function and waits for it to fall
 * @param {function} testFunction a function that should fall with an error when it is called
 * @param {string} errorMessage output error if the function did not fall
 * @param {boolean} needLogError if true, then error will show in log
 */
let testError = async function (testFunction, errorMessage, needLogError = false) {
    withoutError = true;
    try {
        await testFunction();
    }
    catch (exception) {
        if (needLogError) console.log(exception);
        withoutError = false;
    }
    if(withoutError) throw errorMessage;
}

function ethToWei(ethCount) {
    return web3.utils.toWei(ethCount.toString(), "ether");
}

function weiToEther(weiCount) {
    return web3.utils.fromWei(weiCount.toString(), "ether");
}

/**
 * Creating new market
 * @param {contract} instance current contract deployed instance
 * @param {{name:string}} data data for creating market. Need fields: name
 * @param {address} from account which call this transaction
 * @returns {{marketId:Number}}
 */
async function createMarket(instance, data, from) {
    let marketId;

    let createMarketResult = await instance.createMarket(data.name, {from: from});

    try {
        await truffleAssert.eventEmitted(createMarketResult , 'MarketCreated', async (res) => {
            marketId = res.marketId.toNumber();
        });
    }
    catch(exception) {
        console.log(exception);
    }
    
    return { marketId: marketId };
}

/**
 * Creating new item type
 * @param {contract} instance current contract deployed instance
 * @param {{marketId:number, name:string, totalSupply:number, allowSale:boolean, allowAuction:boolean, allowRent:boolean, allowLootbox:boolean}} data data for creating item type
 * @param {address} from account which call this transaction
 * @returns {{marketId:number, typeId:number, savedData:struct}}
 */
async function createItemType(instance, data, from){
    let typeId;
    let marketId;
    let savedData;

    let result = await instance.createItemType(
        data.marketId, 
        data.name, 
        data.totalSupply,
        data.allowSale, 
        data.allowAuction, 
        data.allowRent, 
        data.allowLootbox, 
        {from: from});
    
    try {
        await truffleAssert.eventEmitted(result , 'ItemTypeCreated', async (res) => {
            marketId = res.marketId.toNumber();
            typeId = res.itemTypeId.toNumber();
        });
        savedData = await instance.marketToItemTypes.call(marketId, typeId);
    }
    catch(exception){
        console.log(exception);
    }

    return { marketId: marketId,  typeId: typeId, savedData: savedData};
}

/**
 * Creating new item
 * @param {contract} instance current contract deployed instance
 * @param {{marketId:number, typeId:number}} data data for creating item
 * @param {address} from account which call this transaction
 * @returns {{marketId:number, typeId:number, itemId:number, savedData:struct}}
 */
async function createItem(instance, data, from){
    let typeId;
    let marketId;
    let itemId;
    let savedData

    let result = await instance.createItem(data.marketId, data.typeId, {from: from});
    try {
        await truffleAssert.eventEmitted(result , 'ItemCreated', async (res) => {
            marketId = res.marketId.toNumber();
            typeId = res.itemTypeId.toNumber();
            itemId = res.itemId.toNumber();
        });
        savedData = await instance.marketToItems.call(marketId, itemId);
    }
    catch(exception){
        console.log(exception);
    }

    return { marketId: marketId,  typeId: typeId, itemId: itemId, savedData: savedData};
}

/**
 * Creating new item
 * @param {contract} instance current contract deployed instance
 * @param {{marketId:number, itemId:number, to:address}} data data for transfer ownership of item
 * @param {address} from account which call this transaction
 * @returns {{marketId:number, itemId:number, previousOwner:address, newOwner:address, savedOwner:address}}
 */
async function transferItemOwnership(instance, data, from){
    let marketId;
    let itemId;
    let previousOwner;
    let newOwner;
    let savedOwner;

    let result = await instance.transferItemOwnership(data.marketId, data.itemId, data.to, {from: from});
    try {
        await truffleAssert.eventEmitted(result , 'ItemOwnershipTransferred', async (res) => {
            marketId = res.marketId.toNumber();
            itemId = res.itemId.toNumber();
            previousOwner = res.previousOwner;
            newOwner = res.newOwner;
        });
        savedOwner = await instance.marketToItemToOwner.call(data.marketId, data.itemId);
    }
    catch(exception){
        console.log(exception);
    }

    return { marketId: marketId,  itemId: itemId, previousOwner: previousOwner, newOwner: newOwner, savedOwner: savedOwner};
}

/**
 * Creating new Sale data for Releasing items
 * @param {contract} instance current contract deployed instance
 * @param {{marketId:number, itemTypeId:number, totalSupply:number, priceInWei:number}} data data
 * @param {address} from account which call this transaction
 * @returns {{marketId:number, itemTypeId:number}}
 */
async function createSaleData(instance, data, from) {
    let marketId;
    let itemTypeId;

    let result = await instance.createSaleData(
        data.marketId,
        data.itemTypeId,
        data.totalSupply,
        data.priceInWei,
        {from:from});
    try {
        await truffleAssert.eventEmitted(result , 'SaleDataCreated', async (res) => {
            marketId = res.marketId.toNumber();
            itemTypeId = res.itemTypeId.toNumber();
        });
    }
    catch(exception){
        console.log(exception);
    }

    return {marketId:marketId, itemTypeId:itemTypeId}
}

/**
 * Remove existing Sale data
 * @param {contract} instance current contract deployed instance
 * @param {{marketId:number, itemTypeId:number}} data data
 * @param {address} from account which call this transaction
 * @returns {{marketId:number, itemTypeId:number}}
 */
async function removeSaleData(instance, data, from) {
    let marketId;
    let itemTypeId;

    await instance.removeSaleData(
        data.marketId,
        data.itemTypeId,
        {from:from});
    try {
        await truffleAssert.eventEmitted(result , 'SaleDataRemoved', async (res) => {
            marketId = res.marketId.toNumber();
            itemTypeId = res.itemTypeId.toNumber();
        });
    }
    catch(exception){
        console.log(exception);
    }

    return {marketId:marketId, itemTypeId:itemTypeId}
}

/**
 * Enable existing Sale data
 * @param {contract} instance current contract deployed instance
 * @param {{marketId:number, itemTypeId:number}} data data
 * @param {address} from account which call this transaction
 * @returns {{marketId:number, itemTypeId:number}}
 */
async function enableSaleData(instance, data, from) {
    let marketId;
    let itemTypeId;

    await instance.enableSaleData(
        data.marketId,
        data.itemTypeId,
        {from:from});
    try {
        await truffleAssert.eventEmitted(result , 'SaleDataEnabled', async (res) => {
            marketId = res.marketId.toNumber();
            itemTypeId = res.itemTypeId.toNumber();
        });
    }
    catch(exception){
        console.log(exception);
    }

    return {marketId:marketId, itemTypeId:itemTypeId}
}

/**
 * Disable existing Sale data
 * @param {contract} instance current contract deployed instance
 * @param {{marketId:number, itemTypeId:number}} data data
 * @param {address} from account which call this transaction
 * @returns {{marketId:number, itemTypeId:number}}
 */
async function disableSaleData(instance, data, from) {
    let marketId;
    let itemTypeId;

    await instance.disableSaleData(
        data.marketId,
        data.itemTypeId,
        {from:from});
    try {
        await truffleAssert.eventEmitted(result , 'SaleDataDisabled', async (res) => {
            marketId = res.marketId.toNumber();
            itemTypeId = res.itemTypeId.toNumber();
        });
    }
    catch(exception){
        console.log(exception);
    }

    return {marketId:marketId, itemTypeId:itemTypeId}
}

/**
 * Update existing Sale data
 * @param {contract} instance current contract deployed instance
 * @param {{marketId:number, itemTypeId:number, totalSupply:number, priceInWei:number}} data data
 * @param {address} from account which call this transaction
 * @returns {{marketId:number, itemTypeId:number}}
 */
async function updateSaleDataWithTotalSupply(instance, data, from) {
    let marketId;
    let itemTypeId;

    await instance.updateSaleData(
        data.marketId,
        data.itemTypeId,
        data.totalSupply,
        data.priceInWei,
        {from:from});
    try {
        await truffleAssert.eventEmitted(result , 'SaleDataUpdated', async (res) => {
            marketId = res.marketId.toNumber();
            itemTypeId = res.itemTypeId.toNumber();
        });
    }
    catch(exception){
        console.log(exception);
    }

    return {marketId:marketId, itemTypeId:itemTypeId}
}

/**
 * Update existing Sale data
 * @param {contract} instance current contract deployed instance
 * @param {{marketId:number, itemTypeId:number, priceInWei:number}} data data
 * @param {address} from account which call this transaction
 * @returns {{marketId:number, itemTypeId:number}}
 */
async function updateSaleData(instance, data, from) {
    let marketId;
    let itemTypeId;

    await instance.updateSaleData(
        data.marketId,
        data.itemTypeId,
        data.priceInWei,
        {from:from});
    try {
        await truffleAssert.eventEmitted(result , 'SaleDataUpdated', async (res) => {
            marketId = res.marketId.toNumber();
            itemTypeId = res.itemTypeId.toNumber();
        });
    }
    catch(exception){
        console.log(exception);
    }

    return {marketId:marketId, itemTypeId:itemTypeId}
}

/**
 * Buy item
 * @param {contract} instance current contract deployed instance
 * @param {{marketId:number, itemTypeId:number, itemOwner:address}} data
 * @param {address} from account which call this transaction
 * @returns {{marketId:number, typeId:number, itemId:number, savedData:struct}}
 */
async function buyItem(instance, data, from){
    let typeId;
    let marketId;
    let itemId;
    let savedData

    let result = await instance.buyItem(data.marketId, data.typeId, data.itemOwner, {from: from});
    try {
        await truffleAssert.eventEmitted(result , 'ItemCreated', async (res) => {
            marketId = res.marketId.toNumber();
            typeId = res.itemTypeId.toNumber();
            itemId = res.itemId.toNumber();
        });
        savedData = await instance.marketToItems.call(marketId, itemId);
    }
    catch(exception){
        console.log(exception);
    }

    return { marketId: marketId,  typeId: typeId, itemId: itemId, savedData: savedData};
}


/**
 * The zero address for use in contract call
 */
const zeroAddress = '0x0000000000000000000000000000000000000000';


module.exports.zeroAddress                      = zeroAddress;
module.exports.testError                        = testError;
module.exports.ethToWei                         = ethToWei;
module.exports.weiToEther                       = weiToEther;

module.exports.createMarket                     = createMarket;

module.exports.createItemType                   = createItemType;
module.exports.createItem                       = createItem;
module.exports.transferItemOwnership            = transferItemOwnership;

module.exports.createSaleData                   = createSaleData;
module.exports.removeSaleData                   = removeSaleData;
module.exports.enableSaleData                   = enableSaleData;
module.exports.disableSaleData                  = disableSaleData;
module.exports.updateSaleDataWithTotalSupply    = updateSaleDataWithTotalSupply;
module.exports.updateSaleData                   = updateSaleData;
module.exports.buyItem                          = buyItem;