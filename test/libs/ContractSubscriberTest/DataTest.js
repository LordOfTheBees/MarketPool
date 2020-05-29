const truffleAssert = require('truffle-assertions');

/**
 * Сохранить данные
 * @param {contract} instance контракт содержащий интерфейс DataTest
 * @param {address} address сохраняемый адрес
 * @param {address} from адрес с которого будет сделан вызов
 */
async function saveDataAddress(instance, address, from) {
    await instance.saveDataAddress(address, {from: from});
}

/**
 * Получить данные
 * @param {contract} instance контракт содержащий интерфейс DataTest
 * @returns {address}
 */
async function getDataAddress(instance) {
    return await instance.getDataAddress.call();
}

module.exports.saveDataAddress  = saveDataAddress;
module.exports.getDataAddress   = getDataAddress;

