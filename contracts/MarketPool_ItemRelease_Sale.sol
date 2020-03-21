pragma solidity >=0.6.0;

import "../library/Release/Sale/SaleReleasePosition.sol";
import "../library/Release/Sale/SaleReleaseDataList.sol";
import "../library/ListUint256.sol";
import "./MarketPool_Items.sol";

contract MarketPool_ItemRelease_Sale is MarketPool_Items {
    using SafeMath for uint256;
    using SaleReleasePosition for SaleReleasePosition.Data;
    using SaleReleaseDataList for SaleReleaseDataList.List;
    using ListUint256 for ListUint256.List;

    event SaleReleaseCreated(uint256 indexed marketId, uint256 indexed saleReleaseInnerId);
    event SaleReleaseRemoved(uint256 indexed marketId, uint256 indexed saleReleaseInnerId);
    event SaleReleaseUpdated(uint256 indexed marketId, uint256 indexed saleReleaseInnerId);
    event SaleReleaseBought(uint256 indexed marketId, uint256 indexed saleReleaseInnerId, uint256[] itemIdArray);



    // ID магазина к ID типа предмета к внутреннему индексу в SaleItemList.List где встречается текущий тип
    mapping(uint256 => mapping(uint256 => ListUint256.List)) private marketToItemTypeToInnerIndexesList;

    // ID магазина к списку данных по продаже
    mapping(uint256 => SaleReleaseDataList.List) private marketToSaleReleaseDataList;



    /**
     * @notice Create new Sale Data for Release Items
     */
    function createSaleRelease(
        uint256 marketId,
        uint256[] calldata itemTypeIdArray,
        uint256 totalSupply,
        uint256 priceInWei,
        bool enable)
        external
        onlyMarketOwner(marketId)
    {
        require(itemTypeIdArray.length > 0, "Cannot create Sale Release without item types");
        for(uint i = 0; i < itemTypeIdArray.length; ++i){
            require(itemTypeExist(marketId, itemTypeIdArray[i]), "One of the item type does not exists");
        }


        bool isFinal = totalSupply > 0;
        uint256 innerId;
        (,innerId) = marketToSaleReleaseDataList[marketId].add(SaleReleasePosition.Data(
            marketId,
            priceInWei,
            totalSupply,
            totalSupply,
            isFinal,
            enable,
            itemTypeIdArray,
            new uint256[](itemTypeIdArray.length)
        ));

        uint256 tmpInnerId;
        SaleReleasePosition.Data storage saleRelease = marketToSaleReleaseDataList[marketId].getByInnerIndex(innerId);
        for(uint i = 0; i < itemTypeIdArray.length; ++i){
            (,tmpInnerId) = marketToItemTypeToInnerIndexesList[marketId][itemTypeIdArray[i]].add(innerId);
            saleRelease.itemTypeIdToInnerIndex[i] = tmpInnerId;
        }
        emit SaleReleaseCreated(marketId, innerId);
    }

    function removeSaleRelease(uint256 marketId, uint256 saleReleaseInnerId)
        external
        onlyMarketOwner(marketId)
        onlySaleReleaseExists(marketId, saleReleaseInnerId)
    {
        SaleReleasePosition.Data memory data = marketToSaleReleaseDataList[marketId].getByInnerIndex(saleReleaseInnerId);

        for(uint i = 0; i < data.itemTypeIdArray.length; ++i) {
            marketToItemTypeToInnerIndexesList[marketId][data.itemTypeIdArray[i]].removeByInnerlId(data.itemTypeIdToInnerIndex[i]);
        }

        marketToSaleReleaseDataList[marketId].removeByInnerlId(saleReleaseInnerId);
        emit SaleReleaseRemoved(marketId, saleReleaseInnerId);
    }

    function updateSaleRelease(
        uint256 marketId,
        uint256 saleReleaseInnerId,
        uint256 totalSupply,
        uint256 priceInWei,
        bool enable)
        external
        onlyMarketOwner(marketId)
        onlySaleReleaseExists(marketId, saleReleaseInnerId)
    {
        SaleReleasePosition.Data storage data = _getSaleReleaseRef(marketId, saleReleaseInnerId);
        data.priceInWei = priceInWei;
        data.remainingSupply = totalSupply;
        data.totalSupply = totalSupply;
        data.isFinal = totalSupply > 0;
        data.enable = enable;
        emit SaleReleaseUpdated(marketId, saleReleaseInnerId);
    }


    function buySaleRelease(uint256 marketId, uint256 saleReleaseInnerId, address itemOwner)
        external
        payable
        onlySaleReleaseExists(marketId, saleReleaseInnerId)
    {
        SaleReleasePosition.Data storage data = _getSaleReleaseRef(marketId, saleReleaseInnerId);
        require(data.enable, "Current sale realease is disabled");
        require(msg.value >= data.priceInWei, "Not enough eth for buy this item");
        require(data.realeasePossible(), "Release this item type is impossible");
        data.recordItemRelease();

        uint256[] memory itemIdArray = new uint256[](data.itemTypeIdArray.length);

        payable(marketToOwner[marketId]).transfer(data.priceInWei);
        if (msg.value > data.priceInWei) payable(msg.sender).transfer(msg.value - data.priceInWei);

        for(uint256 i = 0; i < data.itemTypeIdArray.length; ++i) {
            itemIdArray[i] = _createItem(marketId, data.itemTypeIdArray[i], itemOwner);
        }
        
        emit SaleReleaseBought(marketId, saleReleaseInnerId, itemIdArray);
    }


    /**
     * @notice Return data about Sale Release for selected item type
     */
    function getSaleRelease(uint256 marketIdToFound, uint256 saleReleaseInnerId)
        public
        view
        onlySaleReleaseExists(marketIdToFound, saleReleaseInnerId)
        returns(
            uint256 marketId,
            uint256 priceInWei,
            uint256 remainingSupply,
            uint256 totalSupply,

            bool isFinal,
            bool enable,
            uint256[] memory itemTypeIdArray
        )
    {
        SaleReleasePosition.Data memory data = marketToSaleReleaseDataList[marketIdToFound].getByInnerIndex(saleReleaseInnerId);
        return (
            data.marketId,
            data.priceInWei,
            data.remainingSupply,
            data.totalSupply,

            data.isFinal,
            data.enable,
            data.itemTypeIdArray
        );
    }


    /**
     * @notice Return array of inner id's SaleReleases by itemTypeId
     */
    function getSaleReleaseArrayForItemType(uint256 marketId, uint256 itemTypeId)
        external
        view
        onlyItemTypeExist(marketId, itemTypeId)
        returns (uint256[] memory)
    {
        ListUint256.List storage list = marketToItemTypeToInnerIndexesList[marketId][itemTypeId];
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
    function saleReleaseExists(uint256 marketId, uint256 saleReleaseInnerId)
        public
        view
        returns(bool)
    {
        return marketToSaleReleaseDataList[marketId].existsByInnerId(saleReleaseInnerId);
    }




    function _getSaleReleaseRef(uint256 marketId, uint256 saleReleaseInnerId)
        internal
        view
        returns (SaleReleasePosition.Data storage)
    {
        return marketToSaleReleaseDataList[marketId].getByInnerIndex(saleReleaseInnerId);
    }




    modifier onlySaleReleaseExists(uint256 marketId, uint256 saleReleaseInnerId) {
        require(saleReleaseExists(marketId, saleReleaseInnerId), "SaleRelease does not exists");
        _;
    }
}