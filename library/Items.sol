pragma solidity >=0.6.0;

import "@openzeppelin/contracts/math/SafeMath.sol";

library Items {
    using SafeMath for uint256;

    struct Item {
        uint256 typeId;
    }

    struct ItemType {
        string name;
        
        uint256 remainingSupply;
        uint256 totalSupply;

        bool isFinal;
        bool allowSale;
        bool allowAuction;
        bool allowRent;
        bool allowLootbox;
    }

    /**
     * @dev Checks whether it is possible to create an item
     * @return true if it possible
     */
    function creatingPossible(ItemType storage itemType)
        internal
        view
        returns (bool)
    {
        return !itemType.isFinal || itemType.remainingSupply > 0;
    }

    /**
     * @dev reduces the number of remaining objects by 1 if it Final
     */
    function recordItemCreated(ItemType storage itemType) internal {
        if (itemType.isFinal && itemType.remainingSupply > 0)
            itemType.remainingSupply = SafeMath.sub(
                itemType.remainingSupply,
                1
            );
    }

}
