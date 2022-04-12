package com.ijava.todolist.card.service;

import com.ijava.todolist.card.controller.dto.CardCreateRequest;
import com.ijava.todolist.card.controller.dto.CardMoveRequest;
import com.ijava.todolist.card.controller.dto.CardMovedResponse;
import com.ijava.todolist.card.controller.dto.CardUpdateRequest;
import com.ijava.todolist.card.domain.Card;
import com.ijava.todolist.card.exception.CardNotFoundException;
import com.ijava.todolist.card.repository.CardRepository;
import com.ijava.todolist.history.Action;
import com.ijava.todolist.history.service.HistoryService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.Collections;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class CardService {

    private final static int CARD_COUNT_DEFAULT = 0;

    private final CardRepository cardRepository;
    private final HistoryService historyService;

    /**
     * 특정 칼럼에 속한 카드 목록 조회
     * @param columnsId
     * @return
     */
    public List<Card> findCardList(Long columnsId) {
        if (columnsId == null) return Collections.emptyList();

        return cardRepository.findByColumnId(columnsId)
                .orElseGet(Collections::emptyList);
    }

    /**
     * 특정 칼럼에 속한 카드 개수 조회
     * @param columnsId
     * @return
     */
    public int getCountOfCardsOnColumns(Long columnsId) {
        return cardRepository.getCountOfCardsOnColumns(columnsId)
                .orElse(CARD_COUNT_DEFAULT);

    }

    /**
     * id 로 카드 조회
     * @param id
     * @return
     */
    public Card findCardById(Long id) {
        return cardRepository.findById(id)
                .orElseThrow(CardNotFoundException::new);
    }

    /**
     * 카드 저장 요청 시, 카드 생성
     * @param request
     * @return
     */
    @Transactional
    public Card saveNewCard(CardCreateRequest request) {
        LocalDateTime createdDate = LocalDateTime.now();
        Card newCard = new Card(request.getTitle(), request.getContent(), request.getColumnId(), createdDate, createdDate);
        Card savedCard = cardRepository.save(newCard);

        historyService.store(savedCard.getId(), savedCard.getColumnsId(), Action.ADD, LocalDateTime.now());

        return savedCard;
    }

    /**
     * 카드 수정 요청 시, 존재하는 카드이면 수정후, 수정된 카드를 반환함
     * @param cardId
     * @param updateRequest
     * @return
     */
    public Card updateCard(Long cardId, CardUpdateRequest updateRequest) {
        Card savedCard = cardRepository.findById(cardId)
                .orElseThrow(CardNotFoundException::new);

        Card updatedCard = new Card(
                savedCard.getId(),
                updateRequest.getTitle(),
                updateRequest.getContent(),
                savedCard.getColumnsId(),
                savedCard.getCreatedDate(),
                LocalDateTime.now()
        );

        return cardRepository.save(updatedCard);
    }

    public CardMovedResponse moveCard(CardMoveRequest cardMoveRequest) {
        Card savedCard = cardRepository.findById(cardMoveRequest.getCardId())
                .orElseThrow(CardNotFoundException::new);

        Card updatedCard = cardRepository.save(new Card(
                savedCard.getId(),
                savedCard.getTitle(),
                savedCard.getContent(),
                cardMoveRequest.getColumnId(),
                savedCard.getCreatedDate(),
                LocalDateTime.now()
        ));

        return new CardMovedResponse(updatedCard.getId(), savedCard.getColumnsId(), updatedCard.getColumnsId());
    }
}
