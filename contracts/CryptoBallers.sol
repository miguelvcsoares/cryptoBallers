pragma solidity ^0.4.24;

import './ERC721.sol';

contract CryptoBallers is ERC721 {

    struct Baller {
        string name;
        uint level;
        uint offenseSkill;
        uint defenseSkill;
        uint winCount;
        uint lossCount;
    }

    address owner;
    Baller[] public ballers;

    // Mapping for if address has claimed their free baller
    mapping(address => bool) public claimedFreeBaller;

    // Fee for buying a baller
    uint ballerFee = 0.10 ether;

    /**
    * @dev Ensures ownership of the specified token ID
    * @param _tokenId uint256 ID of the token to check
    */
    modifier onlyOwnerOf(uint256 _tokenId) {
        require (ownerOf(_tokenId) == msg.sender);
        _;
    }

    /**
    * @dev Ensures ownership of contract
    */
    modifier onlyOwner() {
        require (owner  == msg.sender);
        _;
    }

    /**
    * @dev Ensures baller has level above specified level
    * @param _level uint level that the baller needs to be above
    * @param _ballerId uint ID of the Baller to check
    */
    modifier aboveLevel(uint _level, uint _ballerId) {
        // TODO add your code
        require (ballers[_ballerId].level > _level);
        _;
    }

    constructor() public {
        owner = msg.sender;
    }

    /**
    * @dev Allows user to claim first free baller, ensure no address can claim more than one
    */
    function claimFreeBaller() public {
        // TODO add your code
        require (!claimedFreeBaller[msg.sender]);
        
        _createBaller("Baller claimed", 8, 16, 24); 
        claimedFreeBaller[msg.sender] == true;  

    }

    /**
    * @dev Allows user to buy baller with set attributes
    */
    function buyBaller() public payable {
        // TODO add your code
        require (msg.value >= ballerFee);
        _createBaller("Baller bought", 7, 14, 21);   
    }

    /**
    * @dev Play a game with your baller and an opponent baller
    * If your baller has more offensive skill than your opponent's defensive skill
    * you win, your level goes up, the opponent loses, and vice versa.
    * If you win and your baller reaches level 5, you are awarded a new baller with a mix of traits
    * from your baller and your opponent's baller.
    * @param _ballerId uint ID of the Baller initiating the game
    * @param _opponentId uint ID that the baller needs to be above
    */
    function playBall(uint _ballerId, uint _opponentId) onlyOwnerOf(_ballerId) public {
       // TODO add your code
        Baller storage baller1 = baller[_ballerId];
        Baller storage baller2 = baller[_opponentId];

        if(baller1.offenseSkill > baller2.defenseSkill) {
            baller1.winCount = baller1.winCount.add(1);
            baller1.level = baller1.level.add(1);
            baller2.lossCount = baller2.lossCount.add(1);

            if(baller1.level == 5) {
                _createBaller("Winner Baller", level, offenseSkill, defenseSkill);
            }
        }

        else {
            baller1.lossCount = baller1.lossCount.add(1);
            baller2.winCount = baller2.winCount.add(1);
        }
    }

    /**
    * @dev Changes the name of your baller if they are above level two
    * @param _ballerId uint ID of the Baller who's name you want to change
    * @param _newName string new name you want to give to your Baller
    */
    function changeName(uint _ballerId, string _newName) external aboveLevel(2, _ballerId) onlyOwnerOf(_ballerId) {
        // TODO add your code
        ballers[_ballerId].name = _newName;
    }

    /**
   * @dev Creates a baller based on the params given, adds them to the Baller array and mints a token
   * @param _name string name of the Baller
   * @param _level uint level of the Baller
   * @param _offenseSkill offensive skill of the Baller
   * @param _defenseSkill defensive skill of the Baller
   */
    function _createBaller(string _name, uint _level, uint _offenseSkill, uint _defenseSkill) internal {
        // TODO add your code
        uint id = ballers.length;
        ballers.push(Baller(_name, _level, _offenseSkill, _defenseSkill, 0, 0));
        _mint(msg.sender, id);
    }

    /**
    * @dev Helper function for a new baller which averages the attributes of the level, attack, defense of the ballers
    * @param _baller1 Baller first baller to average
    * @param _baller2 Baller second baller to average
    * @return tuple of level, attack and defense
    */
    function _breedBallers(Baller _baller1, Baller _baller2) internal pure returns (uint, uint, uint) {
        uint level = _baller1.level.add(_baller2.level).div(2);
        uint attack = _baller1.offenseSkill.add(_baller2.offenseSkill).div(2);
        uint defense = _baller1.defenseSkill.add(_baller2.defenseSkill).div(2);
        return (level, attack, defense);

    }
}