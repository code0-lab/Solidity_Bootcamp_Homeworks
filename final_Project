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

    // Teklifleri ID'lerine göre saklar
    mapping(uint256 => Proposal) public proposal_history;

    // HANGİ teklifte (uint256) HANGİ adresin (address) oy kullandığını (bool) takip eder.
    // Bu, verimsiz 'voted_addresses' dizisinin yerini alır.
    mapping(uint256 => mapping(address => bool)) public hasVoted;

    //constructor
    constructor() {
        owner = msg.sender;
        // Sahibi oy kullandı listesine eklemek bir hataydı, kaldırıldı.
    }

    // ****************** Modifiers ***********************

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    /**
     * @dev Bir adresin belirli bir teklife oy verip veremeyeceğini kontrol eder.
     * 1. Teklifin var olduğunu (total_vote_to_end > 0)
     * 2. Teklifin hala aktif (oylamaya açık) olduğunu
     * 3. Adresin bu teklif için daha önce oy KULLANMADIĞINI kontrol eder.
     */
    modifier canVote(uint256 _proposalId) {
        // 1. Teklifin varlığını kontrol et (oluşturulurken 0'dan büyük set edildiğini varsayarak)
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
        // Oyu kaydet
        proposal_history[_proposalId].approve++;
        // Oy verenin adresini bu teklif için işaretle
        hasVoted[_proposalId][msg.sender] = true;

        // Oylamayı bitirme koşulunu kontrol et
        _checkProposalEnd(_proposalId);
    }

    /**
     * @dev Belirli bir teklif için 'Red' oyu verir.
     */
    function reject(uint256 _proposalId) external canVote(_proposalId) {
        // Oyu kaydet
        proposal_history[_proposalId].reject++;
        // Oy verenin adresini bu teklif için işaretle
        hasVoted[_proposalId][msg.sender] = true;

        // Oylamayı bitirme koşulunu kontrol et
        _checkProposalEnd(_proposalId);
    }

    /**
     * @dev Belirli bir teklif için 'Çekimser' oyu verir.
     */
    function pass(uint256 _proposalId) external canVote(_proposalId) {
        // Oyu kaydet
        proposal_history[_proposalId].pass++;
        // Oy verenin adresini bu teklif için işaretle
        hasVoted[_proposalId][msg.sender] = true;

        // Oylamayı bitirme koşulunu kontrol et
        _checkProposalEnd(_proposalId);
    }

    /**
     * @dev (Dahili) Her oydan sonra çağrılır. Gerekli oy sayısına ulaşılıp ulaşılmadığını
     * kontrol eder ve oylamayı sonlandırır.
     */
    function _checkProposalEnd(uint256 _proposalId) internal {
        // 'storage' kullanarak state üzerinde değişiklik yapacağız
        Proposal storage proposal = proposal_history[_proposalId];

        uint256 totalVotes = proposal.approve + proposal.reject + proposal.pass;

        // Gerekli toplam oy sayısına ulaşıldıysa
        if (totalVotes >= proposal.total_vote_to_end) {
            // 1. Oylamayı kapat
            proposal.is_active = false;

            // 2. Sonucu belirle (Geçme koşulu: Onay > Red)
            if (proposal.approve > proposal.reject) {
                proposal.current_state = true; // Teklif GEÇTİ
            } else {
                proposal.current_state = false; // Teklif KALDI (Red veya Eşit)
            }
        }
    }

    // ****************** View Functions ***********************

    /**
     * @dev Artık oylama bitince doğru sonucu dönecek.
     */
    function getProposalStatus(
        uint256 proposalId
    ) external view returns (bool) {
        // proposal_history'i public yaptığımız için bu fonksiyona gerek kalmadı
        // ancak sizin kodunuzda olduğu için bırakıyorum.
        Proposal storage proposal = proposal_history[proposalId];
        return proposal.current_state;
    }

    /**
     * @dev Kontrat sahibini değiştirir.
     */
    function setOwner(address new_owner) external onlyOwner {
        owner = new_owner;
    }

    /**
     * @dev Mevcut teklif sayısını döndürür.
     */
    function getProposalCount() external view returns (uint256) {
        return counter;
    }
}
