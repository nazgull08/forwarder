pragma solidity ^0.8.10;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
/**
 * Contract that will forward any incoming Ether to its creator
 */
contract New_Forwarder2 {
  // Address to which any funds sent to this contract will be forwarded
  address public parentAddress;
  event TokensFlushed(address forwarderAddress, uint value, address tokenContractAddress);

  /**
   * Create the contract, and set the destination address to that of the creator
   */
  constructor(address addr) public{
    parentAddress = addr;
  }

  /**
   * Default function; Gets called when Ether is deposited, and forwards it to the destination address
   */
  receive() external payable {
        (bool sent, bytes memory data) = parentAddress.call{value: msg.value}("");
        require(sent, "Failed to send Ether");
  }

  /**
   * Execute a token transfer of the full balance from the forwarder token to the parent address
   * @param tokenContractAddress the address of the erc20 token contract
   */
  function flushTokens(address tokenContractAddress) public {
    IERC20 instance = IERC20(tokenContractAddress);
    uint256 forwarderBalance = instance.balanceOf(address(this));
    if (forwarderBalance == 0) {
      revert();
    }
    instance.transfer(parentAddress, forwarderBalance);
    // fire of an event just for the record!
    emit TokensFlushed(address(this), forwarderBalance, tokenContractAddress);
  }

  /**
   * It is possible that funds were sent to this address before the contract was deployed.
   * We can flush those funds to the destination address.
   */
  function flush() public {
    (bool sent, bytes memory data) = parentAddress.call{value: address(this).balance}("");
        require(sent, "Failed to send Ether");  
  }

}


