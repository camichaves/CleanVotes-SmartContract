// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;
pragma experimental ABIEncoderV2;

contract VoteCodeContract {

        address appAddress = 0xB14cAFcb782b0C388cFe2122Fb36f7BE4844b16d;
        enum state { CREATING, READY, FINISH }

        struct Election{
        string  titleVote;
        address  owner;
        mapping (uint => Candidate)  candidates;
        uint  candidatecount;
        mapping (string => bool)  votantes;
        uint  votantecount;
        mapping (bytes32 => bool) codigos;
        state estado;
        string description;
        uint256 initVote;
        uint256 endVote;
        }

    struct Candidate{
        string name;
        string description;
        uint voteCount;
    }

    struct Votante {
        string name;
        bool voto;
    }

    mapping (address => Election) public electiones;
    uint cantElecciones;
    uint prueba = 0;

    
    event eventNewVotacion( 
        address _ownerAdr,
        string[] _emailsVotantes
        );

    event eventVote( 
        uint indexed _candidateid
        );

    constructor(){
    cantElecciones = 0;
    }

    // payable

    function nuevaVotacion(string memory _titulo, string [] memory _nameCandidatos,
    uint256 cantVotantes, string memory _descripcion, string [] memory _emailsVotantes)  public{
        // Reviso si ya tiene una votacion vigente
        require(electiones[msg.sender].candidatecount == 0, "YA TIENES UNA ELECCION");

        electiones[msg.sender].titleVote = _titulo;
        electiones[msg.sender].description = _descripcion;
        electiones[msg.sender].owner = msg.sender;
         for(uint i = 0; i < _nameCandidatos.length; i++){
            electiones[msg.sender].candidatecount++;
            electiones[msg.sender].candidates[electiones[msg.sender].candidatecount] = Candidate(_nameCandidatos[i],"_description", 0);
         }
         electiones[msg.sender].votantecount = cantVotantes;
         electiones[msg.sender].estado = state.CREATING;
        cantElecciones++;

        emit eventNewVotacion(msg.sender, _emailsVotantes);
    }

    function cargaCodigosVotacion(address ownerVotacion, bytes32[] memory _codigos) public{
        
        require(msg.sender == appAddress, "SOLO LA APP PUEDE CARGAR CODIGOS");
        require(electiones[ownerVotacion].estado == state.CREATING, "YA SE CARGARON CODIGOS PARA ESTA VOTACION");
        for(uint i = 0; i < _codigos.length; i++){
            electiones[ownerVotacion].codigos[_codigos[i]] = true ;
         }
        electiones[msg.sender].estado = state.READY;
    }
 
    function vote(uint _candidateid, bytes memory _codigo, address _ownerAdr ) public{
        bytes32 hash  = keccak256(_codigo);
        require(electiones[_ownerAdr].codigos[hash] == true, "EL CODIGO DE VOTACION NO ES VALIDO");
        require(_candidateid > 0 && _candidateid <= electiones[_ownerAdr].candidatecount);
    //  require(block.timestamp>=election.initVote && block.timestamp<=election.endVote);
        
        electiones[_ownerAdr].codigos[hash] = false;
        electiones[_ownerAdr].candidates[_candidateid].voteCount ++;

        
        emit eventVote(_candidateid);
    }

    function getCandidatoVotos(address ownerAdr, uint id) public view
    returns (uint){
        return electiones[ownerAdr].candidates[id].voteCount;
    }

    function getCandidatoNombre(address ownerAdr, uint id) public view
    returns (string memory){
        return electiones[ownerAdr].candidates[id].name;
    }

}