pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Exchanger {

    address private owner;
    mapping(IERC20 => uint256) private  rates;

    constructor(){
        owner = msg.sender;
    }

    modifier onlyOwner(){
        require(msg.sender==owner, "Only owner can do this operation");
        _;
    }
    modifier supportedToken(address token){
        require(rates[IERC20(token)] > 0, "Unallowed token");
        _;
    }


    function addToken(address token, uint256 rate) onlyOwner external {
       rates[IERC20(token)] = rate;
    }

    function changeRate(address token , uint256 rate) onlyOwner supportedToken(token) external{
        require(rate>0, "Rate can't be <= 0");
        rates[IERC20(token)] = rate;
    }

    function getBalance(address token) supportedToken(token) onlyOwner external view returns (uint256)  {
        return IERC20(token).balanceOf(address(this));
    }

    function isAllowed(address token) external view returns(bool){
        return rates[IERC20(token)] > 0;
    }

    function buyToken(address token, uint256 amount) supportedToken(token) external  payable {
        require(rates[IERC20(token)] * amount >= msg.value);
        require(IERC20(token).transferFrom(address(this), msg.sender, amount), "Something went wrong");
    }

    function sellToken(address token, uint256 amount) supportedToken(token) external {
        require(IERC20(token).transferFrom(msg.sender, address(this), amount), "Something went wrong");
        require(payable(msg.sender).send(rates[IERC20(token)] * amount), "Something went wrong");
    }

     receive() external payable {
    
    }
}
