pragma solidity >=0.6.0;

import "@openzeppelin/contracts/math/SafeMath.sol";

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented or decremented by one. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 * Since it is not possible to overflow a 256 bit integer with increments of one, `increment` can skip the {SafeMath}
 * overflow check, thereby saving gas. This does assume however correct usage, in that the underlying `_value` is never
 * directly accessed.
 */
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
    function creatingPossible(ItemType storage itemType) internal view returns (bool) {
        return !itemType.isFinal || itemType.remainingSupply > 0;
    }
    
    /**
     * @dev reduces the number of remaining objects by 1 if it Final
     */
    function recordItemCreated(ItemType storage itemType) internal {
        if (itemType.isFinal && itemType.remainingSupply > 0)
            itemType.remainingSupply = SafeMath.sub(itemType.remainingSupply, 1);
    }
    
}