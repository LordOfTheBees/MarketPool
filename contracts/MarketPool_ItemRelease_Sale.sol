pragma solidity >=0.6.0;


import "../library/Release/Sale/SaleReleasePosition.sol";
import "../library/Release/Sale/ItemRelease_Sale.sol";
import "./MarketPool_Items.sol";

contract MarketPool_ItemRelease_Sale is MarketPool_Items {
    using ItemRelease_Sale for ItemRelease_Sale.Instance;
    using SaleReleasePosition for SaleReleasePosition.Data;

    event SaleReleaseCreated(uint256 indexed marketId, uint256 indexed saleReleaseInnerId);
    event SaleReleaseRemoved(uint256 indexed marketId, uint256 indexed saleReleaseInnerId);
    event SaleReleaseUpdated(uint256 indexed marketId, uint256 indexed saleReleaseInnerId);
    event SaleReleaseBought(uint256 indexed marketId, uint256 indexed saleReleaseInnerId, uint256[] itemIdArray);

    ItemRelease_Sale.Instance private instance = ItemRelease_Sale.Instance();



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
        for(uint i = 0; i < itemTypeIdArray.length; ++i){
            require(itemTypeExist(marketId, itemTypeIdArray[i]), "One of the item type does not exists");
        }
        uint256 innerId = instance.createSaleRelease(marketId, itemTypeIdArray, totalSupply, priceInWei, enable);
        emit SaleReleaseCreated(marketId, innerId);
    }

    function removeSaleRelease(uint256 marketId, uint256 saleReleaseInnerId)
        external
        onlyMarketOwner(marketId)
    {
        instance.removeSaleRelease(marketId, saleReleaseInnerId);
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
    {
        instance.updateSaleRelease(marketId, saleReleaseInnerId, totalSupply, priceInWei, enable);
        emit SaleReleaseUpdated(marketId, saleReleaseInnerId);
    }


    /*function buySaleRelease(uint256 marketId, uint256 saleReleaseInnerId, address itemOwner)
        external
        payable
    {
        SaleReleasePosition.Data storage data = instance.getSaleReleaseByInnerId(marketId, saleReleaseInnerId);
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
    }*/


    /**
     * @notice Return data about Sale Release for selected item type
     */
    /*function getSaleReleaseByNormalId(uint256 marketIdToFound, uint256 saleReleaseId)
        public
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
		return instance.getSaleReleaseDataByNormalId(marketIdToFound, saleReleaseId);
    }*/


    /**
     * @notice Return array of inner id's SaleReleases by itemTypeId
     */
    function getSaleReleaseArrayForItemType(uint256 marketId, uint256 itemTypeId)
        external
        view
        onlyItemTypeExist(marketId, itemTypeId)
        returns (uint256[] memory)
    {
        return instance.getSaleReleaseArrayForItemType(marketId, itemTypeId);
    }
}