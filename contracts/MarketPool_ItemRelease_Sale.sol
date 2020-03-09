pragma solidity >=0.6.0;

import "../library/Release/Sale/Sale.sol";
import "../library/Release/Sale/SaleDataList.sol";
import "./MarketPool_Items.sol";

contract MarketPool_ItemRelease_Sale is MarketPool_Items {
    using SafeMath for uint256;
    using Sale for Sale.Data;
    using SaleDataList for SaleDataList.List;

    event SaleDataCreated(uint256 indexed marketId, uint256 indexed itemTypeId);
    event SaleDataRemoved(uint256 indexed marketId, uint256 indexed itemTypeId);

    event SaleDataEnabled(uint256 indexed marketId, uint256 indexed itemTypeId);
    event SaleDataDisabled(uint256 indexed marketId, uint256 indexed itemTypeId);
    event SaleDataUpdated(uint256 indexed marketId, uint256 indexed itemTypeId);

    SaleDataList.List[] private saleDataListArray;

    // ID магазина к ID типа предмета к внутреннему индексу в SaleItemList.List (если 0, о его нет в списке)
    mapping(uint256 => mapping(uint256 => uint256)) private marketToItemTypeToInnerIndex;

    // ID магазина к списку данных по продаже
    mapping(uint256 => SaleDataList.List) private marketToSaleDataList;


    /**
     * @notice Create new Sale Data for Release Items
     */
    function createSaleData(
        uint256 marketId,
        uint256 itemTypeId,
        uint256 totalSupply,
        uint256 priceInWei)
        external
        onlyMarketOwner(marketId)
        onlyItemTypeExist(marketId, itemTypeId)
    {
        require(!saleDataExists(marketId, itemTypeId), "Sale Data already exists");

        bool isFinal = totalSupply > 0;
        uint256 innerId;
        (,innerId) = marketToSaleDataList[marketId].add(Sale.Data(
            marketId,
            itemTypeId,
            priceInWei,
            totalSupply,
            totalSupply,
            isFinal,
            false
        ));
        marketToItemTypeToInnerIndex[marketId][itemTypeId] = innerId;
        emit SaleDataCreated(marketId, itemTypeId);
    }

    function removeSaleData(uint256 marketId, uint256 itemTypeId)
        external
        onlyMarketOwner(marketId)
        onlySaleDataExists(marketId, itemTypeId)
    {
        marketToSaleDataList[marketId].removeByInnerlId(marketToItemTypeToInnerIndex[marketId][itemTypeId]);
        marketToItemTypeToInnerIndex[marketId][itemTypeId] = 0;
        emit SaleDataRemoved(marketId, itemTypeId);
    }

    function enableSaleData(uint256 marketId, uint256 itemTypeId)
        external
        onlyMarketOwner(marketId)
        onlySaleDataExists(marketId, itemTypeId)
    {
        Sale.Data storage saleData = _getSaleDataRef(marketId, itemTypeId);
        saleData.enable = true;
        emit SaleDataEnabled(marketId, itemTypeId);
    }

    function disableSaleData(uint256 marketId, uint256 itemTypeId)
        external
        onlyMarketOwner(marketId)
        onlySaleDataExists(marketId, itemTypeId)
    {
        Sale.Data storage saleData = _getSaleDataRef(marketId, itemTypeId);
        saleData.enable = false;
        emit SaleDataDisabled(marketId, itemTypeId);
    }

    function updateSaleData(
        uint256 marketId,
        uint256 itemTypeId,
        uint256 priceInWei)
        external
        onlyMarketOwner(marketId)
        onlySaleDataExists(marketId, itemTypeId)
    {
        Sale.Data storage saleData = _getSaleDataRef(marketId, itemTypeId);
        saleData.priceInWei = priceInWei;
        emit SaleDataUpdated(marketId, itemTypeId);
    }

    function updateSaleData(
        uint256 marketId,
        uint256 itemTypeId,
        uint256 totalSupply,
        uint256 priceInWei)
        external
        onlyMarketOwner(marketId)
        onlySaleDataExists(marketId, itemTypeId)
    {
        Sale.Data storage saleData = _getSaleDataRef(marketId, itemTypeId);
        saleData.priceInWei = priceInWei;
        saleData.remainingSupply = totalSupply;
        saleData.totalSupply = totalSupply;
        saleData.isFinal = totalSupply > 0;
        emit SaleDataUpdated(marketId, itemTypeId);
    }


    function buyItem(uint256 marketId, uint256 itemTypeId, address itemOwner)
        external
        payable
        onlySaleDataExists(marketId, itemTypeId)
    {
        Sale.Data memory saleData = _getSaleDataRef(marketId, itemTypeId);
        require(saleData.enable, "Current sale realease is disabled");
        require(msg.value >= saleData.priceInWei, "Not enough eth for buy this item");
        require(saleData.realeasePossible(), "Release this item type is impossible");


        payable(marketToOwner[marketId]).transfer(msg.value);
        _createItem(marketId, itemTypeId, itemOwner);
    }




    /**
     * @notice Return data about Sale Release for selected item type
     */
    function getSaleData(uint256 marketIdToFound, uint256 itemTypeIdToFound)
        public
        view
        onlySaleDataExists(marketId, itemTypeId)
        returns(
            uint256 marketId,
            uint256 itemTypeId,
            uint256 priceInWei,
            uint256 remainingSupply,
            uint256 totalSupply,
            bool isFinal,
            bool enable
        )
    {
        uint256 innerIndex = marketToItemTypeToInnerIndex[marketIdToFound][itemTypeIdToFound];
        Sale.Data memory saleData = marketToSaleDataList[marketIdToFound].getByInnerIndex(innerIndex);
        return (
            saleData.marketId,
            saleData.itemTypeId,
            saleData.priceInWei,
            saleData.remainingSupply,
            saleData.totalSupply,
            saleData.isFinal,
            saleData.enable
        );
    }

    /**
     * @notice Return TRUE if sale data exists
     */
    function saleDataExists(uint256 marketId, uint256 itemTypeId)
        public
        view
        returns(bool)
    {
        return marketToItemTypeToInnerIndex[marketId][itemTypeId] > 0;
    }




    function _getSaleDataRef(uint256 marketId, uint256 itemTypeId)
        internal
        view
        returns (Sale.Data storage)
    {
        return marketToSaleDataList[marketId].getByInnerIndex(marketToItemTypeToInnerIndex[marketId][itemTypeId]);
    }




    modifier onlySaleDataExists(uint256 marketId, uint256 itemTypeId) {
        require(saleDataExists(marketId, itemTypeId), "SaleData does not exists");
        _;
    }
}