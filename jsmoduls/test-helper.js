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

/**
 * BigNumber array transform to number array
 * @param {BN[]} bnArray a function that should fall with an error when it is called
 * @returns {number[]}
 */
function toNumberArray(bnArray) {
    let resultArray = [];
    bnArray.forEach(element => {
        resultArray.push(element.toNumber());
    });
    return resultArray;
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
 * @param {{marketId:number, itemTypeIdArray:number[], totalSupply:number, priceInWei:number, enable:boolean}} data data
 * @param {address} from account which call this transaction
 * @returns {{marketId:number, saleReleaseInnerId:number}}
 */
async function createSaleRelease(instance, data, from) {
    let marketId;
    let saleReleaseInnerId;

    let result = await instance.createSaleRelease(
        data.marketId,
        data.itemTypeIdArray,
        data.totalSupply,
        data.priceInWei,
        data.enable,
        {from:from});
    try {
        await truffleAssert.eventEmitted(result , 'SaleReleaseCreated', async (res) => {
            marketId = res.marketId.toNumber();
            saleReleaseInnerId = res.saleReleaseInnerId.toNumber();
        });
    }
    catch(exception){
        console.log(exception);
    }

    return {marketId:marketId, saleReleaseInnerId:saleReleaseInnerId}
}

/**
 * Remove existing Sale data
 * @param {contract} instance current contract deployed instance
 * @param {{marketId:number, saleReleaseInnerId:number}} data data
 * @param {address} from account which call this transaction
 * @returns {{marketId:number, saleReleaseInnerId:number}}
 */
async function removeSaleRelease(instance, data, from) {
    let marketId;
    let saleReleaseInnerId;

    let result = await instance.removeSaleRelease(
        data.marketId,
        data.saleReleaseInnerId,
        {from:from});
    try {
        await truffleAssert.eventEmitted(result, 'SaleReleaseRemoved', async (res) => {
            marketId = res.marketId.toNumber();
            saleReleaseInnerId = res.saleReleaseInnerId.toNumber();
        });
    }
    catch(exception){
        console.log(exception);
    }

    return {marketId:marketId, saleReleaseInnerId:saleReleaseInnerId}
}

/**
 * Update existing Sale data
 * @param {contract} instance current contract deployed instance
 * @param {{marketId:number, saleReleaseInnerId:number, totalSupply:number, priceInWei:number, enable:boolean}} data data
 * @param {address} from account which call this transaction
 * @returns {{marketId:number, saleReleaseInnerId:number}}
 */
async function updateSaleRelease(instance, data, from) {
    let marketId;
    let saleReleaseInnerId;

    let result = await instance.updateSaleRelease(
        data.marketId,
        data.saleReleaseInnerId,
        data.totalSupply,
        data.priceInWei,
        data.enable,
        {from:from});
    try {
        await truffleAssert.eventEmitted(result , 'SaleReleaseUpdated', async (res) => {
            marketId = res.marketId.toNumber();
            saleReleaseInnerId = res.saleReleaseInnerId.toNumber();
        });
    }
    catch(exception){
        console.log(exception);
    }

    return {marketId:marketId, saleReleaseInnerId:saleReleaseInnerId}
}

/**
 * Buy item
 * @param {contract} instance current contract deployed instance
 * @param {{marketId:number, saleReleaseInnerId:number, newOwner:address}} data
 * @param {address} from account which call this transaction
 * @param {number} value number of wei to send
 * @returns {{marketId:number, saleReleaseInnerId:number, itemIdArray:number[]}}
 */
async function buySaleRelease(instance, data, from, value){
    let saleReleaseInnerId;
    let marketId;
    let itemIdArray

    let result = await instance.buySaleRelease(data.marketId, data.saleReleaseInnerId, data.newOwner, {from: from, value: value});
    try {
        await truffleAssert.eventEmitted(result , 'SaleReleaseBought', async (res) => {
            marketId = res.marketId.toNumber();
            saleReleaseInnerId = res.saleReleaseInnerId.toNumber();
            itemIdArray = toNumberArray(res.itemIdArray);
        });
    }
    catch(exception){
        console.log(exception);
    }

    return { marketId: marketId,  saleReleaseInnerId: saleReleaseInnerId, itemIdArray: itemIdArray};
}


/**
 * The zero address for use in contract call
 */
const zeroAddress = '0x0000000000000000000000000000000000000000';


module.exports.zeroAddress                      = zeroAddress;

module.exports.testError                        = testError;
module.exports.toNumberArray                    = toNumberArray
module.exports.ethToWei                         = ethToWei;
module.exports.weiToEther                       = weiToEther;

module.exports.createMarket                     = createMarket;

module.exports.createItemType                   = createItemType;
module.exports.createItem                       = createItem;
module.exports.transferItemOwnership            = transferItemOwnership;

module.exports.createSaleRelease                = createSaleRelease;
module.exports.removeSaleRelease                = removeSaleRelease;
module.exports.updateSaleRelease                = updateSaleRelease;
module.exports.buySaleRelease                   = buySaleRelease;