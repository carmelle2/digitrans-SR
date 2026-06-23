// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title SupplyChainTraceability
 * @dev Smart Contract pour tracer les marchandises (cacao, café) d'AGROCAM S.A.
 * Conforme aux exigences de la loi camerounaise n°2010/012 sur la traçabilité.
 */
contract SupplyChainTraceability {
    
    // Rôles dans la chaîne d'approvisionnement
    enum Role { NONE, PLANTATION, PROCESSING, RETAIL }
    
    struct Participant {
        string name;
        string location; // Ex: "Douala", "Yaoundé"
        Role role;
        bool isActive;
    }

    struct Product {
        uint256 id;
        string name;         // Ex: "Cacao Grade A"
        uint256 quantityKg;
        address currentOwner;
        uint256 timestamp;
        string status;       // Ex: "Récolté", "Transformé", "En transit"
    }

    struct Trace {
        address owner;
        string location;
        string status;
        uint256 timestamp;
    }

    address public admin;
    uint256 public productCounter;
    
    mapping(address => Participant) public participants;
    mapping(uint256 => Product) public products;
    mapping(uint256 => Trace[]) public productHistory;

    event ParticipantAdded(address indexed account, string name, Role role);
    event ProductRegistered(uint256 indexed productId, string name, address indexed owner);
    event ProductTransferred(uint256 indexed productId, address indexed from, address indexed to, string status);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Acces refuse: Admin requis");
        _;
    }

    modifier onlyParticipant() {
        require(participants[msg.sender].isActive, "Acces refuse: Participant non reconnu");
        _;
    }

    modifier onlyOwnerOf(uint256 _productId) {
        require(products[_productId].currentOwner == msg.sender, "Acces refuse: Vous ne possedez pas ce produit");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    /**
     * @dev Ajoute un nouvel acteur (Plantation, Usine, Restaurant)
     */
    function addParticipant(address _account, string memory _name, string memory _location, Role _role) public onlyAdmin {
        participants[_account] = Participant(_name, _location, _role, true);
        emit ParticipantAdded(_account, _name, _role);
    }

    /**
     * @dev Enregistre un nouveau produit à la source (Plantation)
     */
    function registerProduct(string memory _name, uint256 _quantityKg) public onlyParticipant {
        require(participants[msg.sender].role == Role.PLANTATION, "Seule une plantation peut enregistrer un produit originel");
        
        productCounter++;
        uint256 newProductId = productCounter;
        
        products[newProductId] = Product({
            id: newProductId,
            name: _name,
            quantityKg: _quantityKg,
            currentOwner: msg.sender,
            timestamp: block.timestamp,
            status: "Recolte"
        });

        // Historique initial
        productHistory[newProductId].push(Trace({
            owner: msg.sender,
            location: participants[msg.sender].location,
            status: "Recolte",
            timestamp: block.timestamp
        }));

        emit ProductRegistered(newProductId, _name, msg.sender);
    }

    /**
     * @dev Transfère la propriété d'un produit (et met à jour la traçabilité)
     */
    function transferProduct(uint256 _productId, address _newOwner, string memory _newStatus) public onlyParticipant onlyOwnerOf(_productId) {
        require(participants[_newOwner].isActive, "Le destinataire n'est pas un participant actif");

        products[_productId].currentOwner = _newOwner;
        products[_productId].status = _newStatus;
        products[_productId].timestamp = block.timestamp;

        productHistory[_productId].push(Trace({
            owner: _newOwner,
            location: participants[_newOwner].location,
            status: _newStatus,
            timestamp: block.timestamp
        }));

        emit ProductTransferred(_productId, msg.sender, _newOwner, _newStatus);
    }

    /**
     * @dev Récupère tout l'historique de traçabilité d'un produit
     */
    function getProductHistory(uint256 _productId) public view returns (Trace[] memory) {
        require(products[_productId].id != 0, "Produit inexistant");
        return productHistory[_productId];
    }
}
