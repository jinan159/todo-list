package com.ijava.todolist.card.service;

import com.ijava.todolist.card.domain.Card;
import com.ijava.todolist.card.exception.CardNotFoundException;
import com.ijava.todolist.card.repository.CardRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.Collections;
import java.util.List;

@Service
@RequiredArgsConstructor
public class CardService {

    private final static int CARD_COUNT_DEFAULT = 0;

    private final CardRepository cardRepository;

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
}
