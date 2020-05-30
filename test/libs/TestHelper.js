const truffleAssert = require('truffle-assertions');

/**
 * Calls the passed function and waits for it to fall
 * @param {function} testFunction a function that should fall with an error when it is called
 * @param {string} errorMessage output error if the function did not fall
 * @param {boolean} needLogError if true, then error will show in log
 */
let throws = async function (testFunction, errorMessage, needLogError = false) {
    withoutError = true;
    try {
        await testFunction();
    }
    catch (exception) {
        if (needLogError) console.log(exception);
        withoutError = false;
    }
    if (withoutError) throw errorMessage;
}

/**
 * Calls the passed function and waits for it does not fall
 * @param {function} testFunction a function that should fall with an error when it is called
 * @param {string} errorMessage output error if the function did not fall
 * @param {boolean} needLogError if true, then error will show in log
 */
let doesNotThrow = async function (testFunction, errorMessage, needLogError = false) {
    withError = false;
    try {
        await testFunction();
    }
    catch (exception) {
        if (needLogError) console.log(exception);
        withError = true;
    }
    if (withoutError) throw errorMessage;
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
 * The zero address for use in contract call
 */
const zeroAddress = '0x0000000000000000000000000000000000000000';


module.exports.zeroAddress                      = zeroAddress;

module.exports.throws                           = throws;
module.exports.doesNotThrow                     = doesNotThrow;
module.exports.toNumberArray                    = toNumberArray
module.exports.ethToWei                         = ethToWei;
module.exports.weiToEther                       = weiToEther;