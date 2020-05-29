pragma solidity >=0.6.0;

import "./SaleReleasePosition.sol";
import "./SaleReleaseDataList.sol";
import "../../ListUint256.sol";

library ItemRelease_Sale {
    using SafeMath for uint256;
    using SaleReleasePosition for SaleReleasePosition.Data;
    using SaleReleaseDataList for SaleReleaseDataList.List;
    using ListUint256 for ListUint256.List;

    struct Instance {
        // ID магазина к ID типа предмета к внутреннему индексу в SaleItemList.List где встречается текущий тип
        mapping(uint256 => mapping(uint256 => ListUint256.List)) marketToItemTypeToInnerIndexesList;

        // ID магазина к списку данных по продаже
        mapping(uint256 => SaleReleaseDataList.List) marketToSaleReleaseDataList;
    }


    /**
     * @notice Create new Sale Data for Release Items
     */
    function createSaleRelease(
        Instance storage instance,
        uint256 marketId,
        uint256[] memory itemTypeIdArray,
        uint256 totalSupply,
        uint256 priceInWei,
        bool enable)
        internal
        returns(uint256)
    {
        require(itemTypeIdArray.length > 0, "Cannot create Sale Release without item types");

        bool isFinal = totalSupply > 0;
        uint256 innerId;
        (,innerId) = instance.marketToSaleReleaseDataList[marketId].add(SaleReleasePosition.Data(
            marketId,
            priceInWei,
            totalSupply,
            totalSupply,
            0,
            isFinal,
            enable,
            itemTypeIdArray,
            new uint256[](itemTypeIdArray.length)
        ));

        uint256 tmpInnerId;
        SaleReleasePosition.Data storage saleRelease = instance.marketToSaleReleaseDataList[marketId].getByInnerIndex(innerId);
        saleRelease.innerId = innerId;
        for(uint i = 0; i < itemTypeIdArray.length; ++i){
            (,tmpInnerId) = instance.marketToItemTypeToInnerIndexesList[marketId][itemTypeIdArray[i]].add(innerId);
            saleRelease.itemTypeIdToInnerIndex[i] = tmpInnerId;
        }
        return innerId;
    }


    function removeSaleRelease(
        Instance storage instance,
        uint256 marketId,
        uint256 saleReleaseInnerId)
        internal
        onlySaleReleaseExists(instance, marketId, saleReleaseInnerId, true)
    {
        SaleReleasePosition.Data memory data = instance.marketToSaleReleaseDataList[marketId].getByInnerIndex(saleReleaseInnerId);

        for(uint i = 0; i < data.itemTypeIdArray.length; ++i) {
            instance.marketToItemTypeToInnerIndexesList[marketId][data.itemTypeIdArray[i]].removeByInnerlId(data.itemTypeIdToInnerIndex[i]);
        }

        instance.marketToSaleReleaseDataList[marketId].removeByInnerlId(saleReleaseInnerId);
    }


    function updateSaleRelease(
        Instance storage instance,
        uint256 marketId,
        uint256 saleReleaseInnerId,
        uint256 totalSupply,
        uint256 priceInWei,
        bool enable)
        internal
        onlySaleReleaseExists(instance, marketId, saleReleaseInnerId, true)
    {
        SaleReleasePosition.Data storage data = instance.marketToSaleReleaseDataList[marketId].getByInnerIndex(saleReleaseInnerId);
        data.priceInWei = priceInWei;
        data.remainingSupply = totalSupply;
        data.totalSupply = totalSupply;
        data.isFinal = totalSupply > 0;
        data.enable = enable;
    }


    function getSaleReleaseByInnerId(
        Instance storage instance,
        uint256 marketId,
        uint256 saleReleaseInnerId)
        internal
        view
        onlySaleReleaseExists(instance, marketId, saleReleaseInnerId, true)
        returns(SaleReleasePosition.Data storage)
    {
        return instance.marketToSaleReleaseDataList[marketId].getByInnerIndex(saleReleaseInnerId);
    }


    function getSaleReleaseDataByNormalId(
        Instance storage instance,
        uint256 marketIdToFound,
        uint256 saleReleaseId)
        internal
        view
        returns(
            uint256 marketId,
            uint256 priceInWei,
            uint256 remainingSupply,
            uint256 totalSupply,
            uint256 innerId,

            bool isFinal,
            bool enable,
            uint256[] memory itemTypeIdArray
        )
    {
        (SaleReleasePosition.Data memory data,) = instance.marketToSaleReleaseDataList[marketIdToFound].get(saleReleaseId);
        return (
            data.marketId,
            data.priceInWei,
            data.remainingSupply,
            data.totalSupply,
            data.innerId,

            data.isFinal,
            data.enable,
            data.itemTypeIdArray
        );
    }


    /**
     * @notice Return array of inner id's SaleReleases by itemTypeId
     */
    function getSaleReleaseArrayForItemType(
        Instance storage instance,
        uint256 marketId,
        uint256 itemTypeId)
        internal
        view
        returns (uint256[] memory)
    {
        ListUint256.List storage list = instance.marketToItemTypeToInnerIndexesList[marketId][itemTypeId];
        uint256 length = list.getLength();
        uint256[] memory resultArray = new uint256[](length);
        uint256 innerIndex = list.iterate(0);
        for(uint256 i = 0; i < length; ++i) {
            uint256 item = list.getByInnerIndex(innerIndex);
            resultArray[i] = item;
            innerIndex = list.iterate(innerIndex);
        }

        return resultArray;
    }


    /**
     * @notice Return TRUE if sale data exists
     */
    function saleReleaseExists(Instance storage instance, uint256 marketId, uint256 saleReleaseId, bool isInnerId)
        internal
        view
        returns(bool)
    {
        if (isInnerId) return instance.marketToSaleReleaseDataList[marketId].existsByInnerId(saleReleaseId);
        else instance.marketToSaleReleaseDataList[marketId].getLength() > saleReleaseId;
    }




    modifier onlySaleReleaseExists(Instance storage instance, uint256 marketId, uint256 saleReleaseId, bool isInnerId) {
        require(saleReleaseExists(instance, marketId, saleReleaseId, isInnerId), "SaleRelease does not exists");
        _;
    }
}