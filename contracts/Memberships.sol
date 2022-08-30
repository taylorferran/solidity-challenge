// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

contract Memberships {


    event CreateUser(uint _id, string _username);
    event UpdateUser(uint id, string _newUsername);

    // Create struct containing all necessary members details
    struct members 
    {
        uint creationDate;
        address addr;
        string username;
        bool isActive;
    }

    // TODO: Currently we use this to keep count of member count and asign member ID,
    // this means this count is currently inaccurate when memberships are deleted or expire
    uint private memberCount = 1;
    mapping (uint => members) private memberByID;
    mapping (string => bool) private nameInUse;
    mapping (address => bool) private membershipActiveForThisAddress;

    modifier checkUsernameValidity(string memory _username) 
    {
        // Require username to not already be in use
        require(!nameInUse[_username], "Username taken.");
        // Require entered username to not be empty 
        bytes memory _usernameEmptyCheck = bytes(_username);
        require(_usernameEmptyCheck.length > 0, "Username empty.");
        _;
    }

    modifier checkMembershipActive(uint _id)
    {
        // This is set to inactive to "delete" a membership
        require(memberByID[_id].isActive, "Membership inactive.");
        _;
    }

    modifier checkAddressMatchesAccount(uint _id) 
    {
        // Require user only able to edit membership with their address 
        require(memberByID[_id].addr == msg.sender, "ID not accessible with this address.");
        _;
    }

    // Let a user create a membership with username that isn't taken 
    // Only allow one membership per address 
    function createMembership(string memory _username) public checkUsernameValidity(_username)
    {
        require(!membershipActiveForThisAddress[msg.sender], "Address already used to activate a memebership");

        // MemberID starts at 1 and increments for each member created
        memberByID[memberCount] = members (
            {
                 // Set creation to unix time now
                creationDate : block.timestamp,
                // Set address to user creating the account
                addr : msg.sender,
                // Set username to desired username
                username : _username, 
                // Set active
                isActive : true
            }
        );
        // Increment member count to keep track of memberIDs
        memberCount++;
        // Set name in use so that another user cannot use the same one
        nameInUse[_username] = true;
        // Set membership active for this address
        membershipActiveForThisAddress[msg.sender] = true;
        emit CreateUser(memberCount-1, _username);
    }

    function updateMembership(uint _id, string memory _username) public checkUsernameValidity(_username) checkAddressMatchesAccount(_id) checkMembershipActive(_id)
    {
        require(checkMembershipValidity(_id), "Membership expired.");
        // Remove old username from the pool of taken usernames
        nameInUse[memberByID[_id].username] = false;
        // Set membership username to new username
        memberByID[_id].username = _username;
        // Add new username to the pool of taken usernames
        nameInUse[_username] = true;
        emit UpdateUser(_id, _username);
    }


    // We cannot delete entries from hashmaps in solidity so here we're
    // just setting it to inactive, making it unusable in other functions.
    // I think in general this will be more scalable than an array based approach
    function deleteMembership(uint _id) public checkAddressMatchesAccount(_id)
    {
        require(memberByID[_id].isActive, "Membership already deleted.");
        memberByID[_id].isActive = false;
    }


    ///      ///
    //  UTILS //
    ///     /// 

    function checkMembershipValidity(uint _id) public view checkMembershipActive(_id) returns (bool) 
    {
        // If the the current time minus the creation date is over 30 days in seconds, we know that the expiry time has been passed
        // Therefore we can return false to use this in requires elsewhere, if it is valid we can return true.
        return ((block.timestamp - memberByID[_id].creationDate >  2592000) ? false : true);
    }

    // Maybe can delete this function
    function getMembership(uint _id) public view checkMembershipActive(_id) returns (members memory) 
    {
        // Return membership struct with all details
        return memberByID[_id];
    }

    function getMemberCount() public view returns (uint) 
    {
        return memberCount-1;
    }

    function getMemberNameByID(uint _id) public view checkMembershipActive(_id) returns(string memory)
    {
        return memberByID[_id].username;
    }


}