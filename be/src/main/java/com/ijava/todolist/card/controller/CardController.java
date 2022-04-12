package com.ijava.todolist.card.controller;

import com.ijava.todolist.card.controller.dto.*;
import com.ijava.todolist.card.domain.Card;
import com.ijava.todolist.card.service.CardService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.util.Comparator;
import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequiredArgsConstructor
public class CardController {

    private final CardService cardService;

    @GetMapping("/cards")
    public List<CardResponse> cardList(@RequestParam(value="columnId") Long columnId) {
        return cardService.findCardList(columnId)
                .stream()
                .map(CardResponse::from)
                .sorted(Comparator.comparing(CardResponse::getCreatedDate))
                .collect(Collectors.toUnmodifiableList());
    }

    @PostMapping("/cards")
    public CardResponse createCard(@RequestBody CardCreateRequest cardCreateRequest) {
        Card save = cardService.saveNewCard(cardCreateRequest);
        return CardResponse.from(save);
    }

    @PutMapping("/cards/{id}")
    @ResponseStatus(value = HttpStatus.NO_CONTENT)
    public void updateCard(@PathVariable("id") Long id, @RequestBody CardUpdateRequest updateRequest) {
        cardService.updateCard(id, updateRequest);
    }

    @PatchMapping("/cards")
    public CardMovedResponse moveCard(@RequestBody CardMoveRequest cardMoveRequest) {
        return cardService.moveCard(cardMoveRequest);
    }
}
