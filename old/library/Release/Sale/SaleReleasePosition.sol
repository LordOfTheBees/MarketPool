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
library SaleReleasePosition {
    using SafeMath for uint256;

    struct Data {
        uint256 marketId;
        uint256 priceInWei;
        uint256 remainingSupply;
        uint256 totalSupply;
        uint256 innerId;

        bool isFinal;
        bool enable;
        uint256[] itemTypeIdArray;
        uint256[] itemTypeIdToInnerIndex; // inner indexes for removing this from their lists
    }

    /**
     * @dev Checks whether it is possible to release an item
     * @return true if it possible
     */
    function realeasePossible(Data memory data) internal pure returns (bool) {
        return data.enable && (!data.isFinal || data.remainingSupply > 0) && data.itemTypeIdArray.length > 0;
    }

    /**
     * @dev reduces the number of remaining objects by 1 if it Final
     */
    function recordItemRelease(Data storage data) internal {
        if (data.enable && data.isFinal && data.remainingSupply > 0)
            data.remainingSupply = SafeMath.sub(data.remainingSupply, 1);
    }
}