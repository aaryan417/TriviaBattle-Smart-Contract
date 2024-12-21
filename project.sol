// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TriviaBattle {
    struct Battle {
        address[] players;
        string[] questions;
        uint8[] answers;
        address winner;
        bool isActive;
    }
    
    mapping(uint => Battle) public battles;
    uint public battleCount;

    event BattleCreated(uint battleId, address creator);
    event PlayerJoined(uint battleId, address player);
    event BattleEnded(uint battleId, address winner);

    modifier onlyActiveBattle(uint battleId) {
        require(battles[battleId].isActive, "Battle is not active");
        _;
    }

    function createBattle(string[] memory questions) public {
        require(questions.length > 0, "Questions required");

        battleCount++;
        Battle storage newBattle = battles[battleCount];
        newBattle.isActive = true;
        newBattle.questions = questions;
        
        emit BattleCreated(battleCount, msg.sender);
    }

    function joinBattle(uint battleId) public onlyActiveBattle(battleId) {
        Battle storage battle = battles[battleId];
        require(battle.players.length < 4, "Battle already full");
        
        battle.players.push(msg.sender);
        emit PlayerJoined(battleId, msg.sender);
    }

    function submitAnswer(uint battleId, uint8 answer) public onlyActiveBattle(battleId) {
        Battle storage battle = battles[battleId];
        bool isPlayer = false;
        
        for (uint i = 0; i < battle.players.length; i++) {
            if (battle.players[i] == msg.sender) {
                isPlayer = true;
                break;
            }
        }
        require(isPlayer, "You are not part of this battle");
        
        battle.answers.push(answer);
    }

    function endBattle(uint battleId) public onlyActiveBattle(battleId) {
        Battle storage battle = battles[battleId];
        
        // Simple logic to determine winner, assuming first correct answer wins.
        address winner;
        for (uint i = 0; i < battle.players.length; i++) {
            if (battle.answers[i] == 1) { // Assuming correct answer is "1"
                winner = battle.players[i];
                break;
            }
        }

        battle.isActive = false;
        battle.winner = winner;
        
        emit BattleEnded(battleId, winner);
    }

    function getBattleInfo(uint battleId) public view returns (address[] memory players, string[] memory questions, address winner, bool isActive) {
        Battle storage battle = battles[battleId];
        return (battle.players, battle.questions, battle.winner, battle.isActive);
    }
}
