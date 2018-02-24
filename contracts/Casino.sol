pragma solidity ^0.4.19;

contract Casino {
    address owner;

    function Casino(uint _minimumBet) {
        owner = msg.sender;
        if (_minimumBet != 0) minimumBet = _minimumBet;
    }

    function kill() {
        if (msg.sender == owner) selfdestruct(owner);
    }

    function bet(uint number) payable {
        assert(checkPlayerExists(msg.sender) == false);
        assert(number >= 1 && number <= 10);
        assert(msg.value >= minimumBet);

        playerInfo[msg.sender].amountBet = msg.value;
        playerInfo[msg.sender].numberSelected = number;
        numberOfBets += 1;
        players.push(msg.sender);
        totalBet += msg.value;

        if (numberOfBets >= maxAmountOfBets) generateNumberWinner();
    }

    function checkPlayerExists(address player) returns(bool) {
        for(uint i=0; i<players.length; i++) {
            if (players[i] == player) return true;
        }

        return false;
    }

    function generateNumberWinner() {
        uint generatedNumber = block.number % 10 + 1;
        distributePrizes(generatedNumber);
    }

    function distributePrizes(uint generatedNumber) {
        address[100] memory winners;
        uint count = 0;

        for (uint i=0; i<players.length; i++) {
            address playerAddress = players[i];
            if (playerInfo[playerAddress].numberSelected == generatedNumber) {
                winners[count] = playerAddress;
                count++;
            }
            delete playerInfo[playerAddress];
        }

        players.length = 0;

        uint prize = totalBet / count;

        for (uint j=0; j<count; j++) {
            if (winners[j] != address(0)) {
                winners[j].transfer(prize);
            }
        }
    }

    uint minimumBet;
    uint totalBet;
    uint numberOfBets;
    uint maxAmountOfBets = 100;
    address[] players;

    struct Player {
        uint amountBet;
        uint numberSelected;
    }

    mapping(address => Player) playerInfo;
}



