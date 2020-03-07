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
library SaleItem {
    using SafeMath for uint256;

    struct Data {
        uint256 marketId;
        uint256 itemTypeId;
        uint256 remainingSupply;
        uint256 totalSupply;

        bool isFinal;
        bool enable;
    }

    /**
     * @dev Checks whether it is possible to release an item
     * @return true if it possible
     */
    function realeasePossible(Data storage data) internal view returns (bool) {
        return enable && (!data.isFinal || data.remainingSupply > 0);
    }

    /**
     * @dev reduces the number of remaining objects by 1 if it Final
     */
    function recordItemRelease(Data storage data) internal {
        if (enable && data.isFinal && data.remainingSupply > 0)
            data.remainingSupply = SafeMath.sub(data.remainingSupply, 1);
    }
}