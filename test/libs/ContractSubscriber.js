const truffleAssert = require('truffle-assertions');
const testHelper = require('./TestHelper');

/**
 * Подписывает контракт на передаваемый адрес
 * @param {contract} instance контракт унаследованный от ContractSubscriber
 * @param {address} contractAddress адрес подписываемого окнтракта
 * @param {address} from адрес с которого будет сделан вызов
 */
async function subscribe(instance, contractAddress, from) {
    await instance.subscribe(contractAddress, {from: from});
}

/**
 * Отписывает контракт с передаваемого адреса
 * @param {contract} instance контракт унаследованный от ContractSubscriber
 * @param {address} contractAddress адрес подписываемого окнтракта
 * @param {address} from адрес с которого будет сделан вызов
 */
async function unsubscribe(instance, contractAddress, from) {
    await instance.unsubscribe(contractAddress, {from: from});
}

/**
 * Проверяет подписан ли адрес
 * @param {contract} instance контракт унаследованный от ContractSubscriber
 * @param {address} contractAddress адрес подписываемого окнтракта
 * @returns {boolean} если true, то адрес подписан
 */
async function isSubscriber(instance, contractAddress) {
    return await instance.isSubscriber.call(contractAddress);
}

module.exports.subscribe    = subscribe;
module.exports.unsubscribe  = unsubscribe;
module.exports.isSubscriber = isSubscriber;