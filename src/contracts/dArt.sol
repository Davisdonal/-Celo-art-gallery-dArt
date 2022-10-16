// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;
import "@openzeppelin/contracts/utils/Counters.sol";


interface IERC20Token {
    function transfer(address, uint256) external returns (bool);

    function approve(address, uint256) external returns (bool);

    function transferFrom(
        address,
        address,
        uint256
    ) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address) external view returns (uint256);

    function allowance(address, address) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract TechArt {
    using Counters for Counters.Counter;
    Counters.Counter private artsLength;

    address private constant cUsdTokenAddress =
        0x874069Fa1Eb16D44d622F2e0Ca25eeA172369bC1;

    struct Art {
        address payable owner;
        string image;
        string description;
        uint price;
        uint noOfAvailable;
        uint sold;
    }

    mapping(uint => Art) private arts;

    modifier checkIfArtOwner(uint _index) {
        require(msg.sender == arts[_index].owner, "Unauthorized caller");
        _;
    }

    modifier checkIfValidInput(uint _input) {
        require(_input > 0, "invalid input");
        _;
    }

    modifier checkIfValidString(string calldata _input) {
        require(bytes(_input).length > 0, "Empty string");
        _;
    }

    /**
     * @dev allow users to add a art to sell
     * @notice  values entered needs to be valid
     * @param _noOfAvailable the number of arts available for sale
     */
    function addArt(
        string calldata _image,
        string calldata _description,
        uint _tip,
        uint _noOfAvailable
    ) public 
    checkIfValidInput(_tip) checkIfValidInput(_noOfAvailable) 
    checkIfValidString(_image) checkIfValidString(_description)
    {
        arts[artsLength.current()] = Art(
            payable(msg.sender),
            _image,
            _description,
            _tip,
            _noOfAvailable,
            0
        );
        artsLength.increment();
    }

    /**
     * @dev allow users to buy a art from the platform
     * @notice Reverts if art is out of inventory(out of stock)
     */
    function buyArt(uint _index, uint _quantity) public payable checkIfValidInput(_quantity){
        Art storage currentArt = arts[_index];
        require(currentArt.noOfAvailable > _quantity, "Stocks unavailable");
        require(
            currentArt.owner != msg.sender,
            "You can't buy your own arts"
        );
        currentArt.sold+= _quantity;
        currentArt.noOfAvailable-= _quantity;
        require(
            IERC20Token(cUsdTokenAddress).transferFrom(
                msg.sender,
                currentArt.owner,
                currentArt.price * _quantity
            ),
            "Transfer failed."
        );
    }

    /**
     * @dev allow arts' owners to unlist their arts. Cleanup of gagdet's data occurs
     * @notice This will remove the art from the platform
     */
    function unlistArt(uint _index) public checkIfArtOwner(_index) {
        uint newArtsLength = artsLength - 1;
        arts[_index] = arts[newArtsLength];
        delete arts[newArtsLength];
        artsLength = newArtsLength;
    }

    /**
     * @dev allow arts' owners to increase their inventory of a art(noOfAvailable)
     * @param _amount the number to add with the current inventory
     *
     */
    function addInventory(uint _index, uint _amount)
        public
        checkIfArtOwner(_index)
        checkIfValidInput(_amount)
    {
        Art storage currentArt = arts[_index];
        uint newNoOfAvailable = currentArt.noOfAvailable + _amount;
        currentArt.noOfAvailable = newNoOfAvailable;
    }

        /**
     * @dev allow arts' owners to reduce their inventory of a art(noOfAvailable)
     * @notice Amount to deduct from the current inventory needs to be less or equal to the current inventory
     * @param _amount the number to deduct from the current inventory
     */
    function reduceInventory(uint _index, uint _amount)
        external
        checkIfArtOwner(_index)
        checkIfValidInput(_amount)
    {
        Art storage currentArt = arts[_index];
        require(
            _amount <= currentArt.noOfAvailable,
            "amount can only be less or equal to the number of arts available"
        );
        uint newNoOfAvailable = currentArt.noOfAvailable - _amount;
        currentArt.noOfAvailable = newNoOfAvailable;
    }

    /**
     * @dev allow arts' owners to change the price of their arts
     * @notice newTip needs to be greater than zero
     */
    function modifyTip(uint _index, uint _newTip)
        external
        checkIfArtOwner(_index)
        checkIfValidInput(_newTip)
    {
        arts[_index].price = _newTip;
    }

    // getting art
    function getArt(uint _index)
        public
        view
        returns (
            address payable,
            string memory,
            string memory,
            uint,
            uint,
            uint
        )
    {
        return (
            arts[_index].owner,
            arts[_index].image,
            arts[_index].description,
            arts[_index].price,
            arts[_index].noOfAvailable,
            arts[_index].sold
        );
    }


    // to get the length of arts in the mapping
    function getArtsLength() public view returns (uint) {
        return (artsLength.current());
    }
}