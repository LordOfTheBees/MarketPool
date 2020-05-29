const truffleAssert = require('truffle-assertions');

/**
 * Проинициализировать внутренний контракт данных
 * @param {contract} instance контракт содержащий интерфейс FunctionsTest
 * @param {address} address сохраняемый адрес
 * @param {address} from адрес с которого будет сделан вызов
 */
async function initData(instance, address, from) {
    await instance.initData(address, {from: from});
}

/**
 * Сохранить данные
 * @param {contract} instance контракт содержащий интерфейс FunctionsTest
 * @param {address} address сохраняемый адрес
 * @param {address} from адрес с которого будет сделан вызов
 */
async function saveDataAddress(instance, address, from) {
    await instance.saveDataAddress(address, {from: from});
}

/**
 * Получить данные
 * @param {contract} instance контракт содержащий интерфейс FunctionsTest
 * @returns {address}
 */
async function getDataAddress(instance) {
    return await instance.getDataAddress.call();
}

module.exports.initData         = initData;
module.exports.saveDataAddress  = saveDataAddress;
module.exports.getDataAddress   = getDataAddress;

