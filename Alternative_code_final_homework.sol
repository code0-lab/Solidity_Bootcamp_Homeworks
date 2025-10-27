// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract ProposalContract {
    // ****************** Data ***********************

    //Owner
    address public owner;

    // Teklifler için benzersiz ID sağlamak
    uint256 private counter;

    struct Proposal {
        string description; // Teklifin açıklaması
        uint256 approve; // 'Onay' oylarının sayısı
        uint256 reject; // 'Red' oylarının sayısı
        uint256 pass; // 'Çekimser' oylarının sayısı
        uint256 total_vote_to_end; // Oylamayı bitirmek için gereken toplam oy sayısı
        bool current_state; // Teklifin son durumu (true: geçti, false: kaldı)
        bool is_active; // Teklifin oylamaya açık olup olmadığı
    }

    // Teklifleri ID'lerine göre saklar (public yaparak ücretsiz bir getter oluşturur)
    mapping(uint256 => Proposal) public proposal_history;

    // HANGİ teklifte (uint256) HANGİ adresin (address) oy kullandığını (bool) takip eder.
    // Bu, verimsiz 'voted_addresses' dizisinin ve 'isVoted' fonksiyonunun yerini alır.
    mapping(uint256 => mapping(address => bool)) public hasVoted;

    //constructor
    constructor() {
        owner = msg.sender;
        // Sahibi oy kullandı listesine eklemek bir hataydı, kaldırıldı.
        // Sahip de oy kullanabilmeli (veya bu bilinçli olarak engellenmeli).
    }

    // ****************** Modifiers ***********************

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    /**
     * @dev Bir adresin belirli bir teklife oy verip veremeyeceğini kontrol eder.
     * 1. Teklifin var olduğunu
     * 2. Teklifin hala aktif (oylamaya açık) olduğunu
     * 3. Adresin bu teklif için daha önce oy KULLANMADIĞINI kontrol eder.
     */
    modifier canVote(uint256 _proposalId) {
        // 1. Teklifin varlığını kontrol et
        require(
            proposal_history[_proposalId].total_vote_to_end > 0,
            "Proposal does not exist"
        );
        // 2. Teklifin aktifliğini kontrol et
        require(
            proposal_history[_proposalId].is_active == true,
            "Proposal is not active"
        );
        // 3. Oy kullanılıp kullanılmadığını (mapping üzerinden) O(1) maliyetle kontrol et
        require(
            hasVoted[_proposalId][msg.sender] == false,
            "Address has already voted on this proposal"
        );
        _;
    }

    // ****************** Execute Functions ***********************

    /**
     * @dev Sadece sahibin yeni bir teklif oluşturmasını sağlar.
     */
    function create(
        string calldata _description,
        uint256 _total_vote_to_end
    ) external onlyOwner {
        require(_total_vote_to_end > 0, "Total vote limit must be greater than 0");
        counter += 1;
        proposal_history[counter] = Proposal(
            _description,
            0,
            0,
            0,
            _total_vote_to_end,
            false, // Başlangıçta 'current_state' false (başarısız)
            true // Başlangıçta 'is_active' true (oylamaya açık)
        );
    }

    /**
     * @dev Belirli bir teklif için 'Onay' oyu verir.
     */
    function approve(uint256 _proposalId) external canVote(_proposalId) {
        proposal_history[_proposalId].approve++;
        hasVoted[_proposalId][msg.sender] = true;
        _checkProposalEnd(_proposalId);
    }

    /**
     * @dev Belirli bir teklif için 'Red' oyu verir.
     */
    function reject(uint256 _proposalId) external canVote(_proposalId) {
        proposal_history[_proposalId].reject++;
        hasVoted[_proposalId][msg.sender] = true;
        _checkProposalEnd(_proposalId);
    }

    /**
     * @dev Belirli bir teklif için 'Çekimser' oyu verir.
     */
    function pass(uint256 _proposalId) external canVote(_proposalId) {
        proposal_history[_proposalId].pass++;
        hasVoted[_proposalId][msg.sender] = true;
        _checkProposalEnd(_proposalId);
    }

    /**
     * @dev (Dahili) Her oydan sonra çağrılır. Gerekli oy sayısına ulaşılıp ulaşılmadığını
     * kontrol eder ve oylamayı sonlandırır.
     */
    function _checkProposalEnd(uint256 _proposalId) internal {
        Proposal storage proposal = proposal_history[_proposalId];
        uint256 totalVotes = proposal.approve + proposal.reject + proposal.pass;

        if (totalVotes >= proposal.total_vote_to_end) {
            proposal.is_active = false;
            // Geçme koşulu: Onay > Red
            if (proposal.approve > proposal.reject) {
                proposal.current_state = true;
            } else {
                proposal.current_state = false;
            }
        }
    }

    /**
     * @dev Kontrat sahibini değiştirir.
     */
    function setOwner(address new_owner) external onlyOwner {
        owner = new_owner;
    }

    // ****************** Query Functions ***********************

    /**
     * @dev fonksiyon (README'deki).
     */
    function getProposalStatus(
        uint256 proposalId
    ) external view returns (bool) {
        Proposal storage proposal = proposal_history[proposalId];
        return proposal.current_state;
    }

    /**
     * @dev En son oluşturulan teklifin detaylarını döndürür.
     */
    function getCurrentProposal() external view returns (Proposal memory) {
        return proposal_history[counter];
    }

    /**
     * @dev Belirli bir ID'ye sahip teklifin detaylarını döndürür.
     * (uint26 hatası burada düzeltildi)
     */
    function getProposal(
        uint256 number
    ) external view returns (Proposal memory) {
        return proposal_history[number];
    }
}