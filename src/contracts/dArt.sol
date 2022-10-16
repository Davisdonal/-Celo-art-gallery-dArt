// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

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
    uint private artsLength = 0;
    address private cUsdTokenAddress =
        0x874069Fa1Eb16D44d622F2e0Ca25eeA172369bC1;

    struct Art {
        address payable owner;
        string image;
        string description;
        uint tip;
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

    function addArt(
        string calldata _image,
        string calldata _description,
        uint _tip
    ) public checkIfValidInput(_tip)  {
        require(bytes(_image).length > 0, "Empty image");
        require(bytes(_description).length > 0, "Empty description");
        arts[artsLength] = Art(
            payable(msg.sender),
            _image,
            _description,
            _tip
        );
    }

    function unlistArt(uint _index) public checkIfArtOwner(_index) {
        uint newArtsLength = artsLength - 1;
        arts[_index] = arts[newArtsLength];
        delete arts[newArtsLength];
        artsLength = newArtsLength;
    }

    
    function modifyTip(uint _index, uint _newTip)
        external
        checkIfArtOwner(_index)
        checkIfValidInput(_newTip)
    {
        arts[_index].tip = _newTip;
    }

    // getting art
    function getArt(uint _index)
        public
        view
        returns (
            address payable,
            string memory,
            string memory,
            uint
            
        )
    {
        return (
            arts[_index].owner,
            arts[_index].image,
            arts[_index].description,
            arts[_index].tip
        );
    }

    function buyArt(uint _index, uint _quantity) public payable checkIfValidInput(_quantity){
        Art storage currentArt = arts[_index];
        
        require(
            IERC20Token(cUsdTokenAddress).transferFrom(
                msg.sender,
                currentArt.owner,
                currentArt.tip * _quantity
            ),
            "Transfer failed."
        );
    }

    // to get the length of arts in the mapping
    function getArtsLength() public view returns (uint) {
        return (artsLength);
    }

}
