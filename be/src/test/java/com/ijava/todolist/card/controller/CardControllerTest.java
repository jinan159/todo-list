package com.ijava.todolist.card.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.ijava.todolist.card.controller.dto.CardCreateRequest;
import com.ijava.todolist.card.domain.Card;
import com.ijava.todolist.card.exception.CardNotSavedException;
import com.ijava.todolist.card.service.CardService;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.ResultActions;
import org.springframework.test.web.servlet.result.MockMvcResultMatchers;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;

import static org.hamcrest.Matchers.is;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.BDDMockito.given;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(CardController.class)
class CardControllerTest {

    private static final String CARD_CREATE_URL = "/cards";

    @Autowired
    private MockMvc mvc;

    @MockBean
    private CardService cardService;

    @Autowired
    private ObjectMapper objectMapper;

    @Nested
    @DisplayName("카드 목록 조회 요청이 들어왔을 때(GET /cards)")
    class GETCardsTest {

        @Nested
        @DisplayName("칼럼 id 가 있으면")
        class ColumnIdExistTest {

            @Test
            void 카드_목록을_반환한다() throws Exception {
                // given
                DateTimeFormatter dateTimeFormat = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm:ss");
                LocalDateTime date = LocalDateTime.of(2022, 4, 5, 20, 40, 0);
                List<Card> cards = List.of(
                        new Card(1L, "제목1", "카드 내용2", 1L, date, date),
                        new Card(2L, "제목2", "카드 내용2", 1L, date, date)
                );
                given(cardService.findCardList(any())).willReturn(cards);

                // when
                ResultActions result = mvc.perform(
                        get("/cards")
                                .queryParam("columnId", "1")
                );

                // then
                result.andExpect(status().isOk())
                        .andExpect(jsonPath("$[0]").exists())
                        .andExpect(jsonPath("$[1]").exists())

                        .andExpect(jsonPath("$[0].cardId", is(cards.get(0).getId().intValue())))
                        .andExpect(jsonPath("$[0].title", is(cards.get(0).getTitle())))
                        .andExpect(jsonPath("$[0].content", is(cards.get(0).getContent())))
                        .andExpect(jsonPath("$[0].createdDate", is(cards.get(0).getCreatedDate().format(dateTimeFormat))))

                        .andExpect(jsonPath("$[1].cardId", is(cards.get(1).getId().intValue())))
                        .andExpect(jsonPath("$[1].title", is(cards.get(1).getTitle())))
                        .andExpect(jsonPath("$[1].content", is(cards.get(1).getContent())))
                        .andExpect(jsonPath("$[1].createdDate", is(cards.get(1).getCreatedDate().format(dateTimeFormat))));
            }
        }

        @Nested
        @DisplayName("칼럼 id 가 없으면")
        class ColumnIdNotExistTest {

            @Test
            void BadRequest_상태코드를_반환한다() throws Exception {
                // given
                String url = "/cards";

                // when
                ResultActions result = mvc.perform(get(url));

                // then
                result.andExpect(status().isBadRequest());
            }
        }
    }

    @Nested
    @DisplayName("카드 입력 요청이 들어왔을 때(POST /cards)")
    class POSTCardsTest {

        @Nested
        @DisplayName("칼럼 id 와 제목이 정상적으로 들어온 경우")
        class SuccessTest {

            @Test
            void 입력된_id_와_함께_카드_정보를_반환한다() throws Exception {
                // given
                String title = "카드 제목";
                String content = "카드 내용입니다.";
                Long columnId = 1L;
                String requestBody = objectMapper.writeValueAsString(new CardCreateRequest(columnId, title, content));
                Card expectedCard = createCard(title, content, columnId, LocalDateTime.now());
                given(cardService.save(any())).willReturn(expectedCard);


                // when
                ResultActions result = mvc.perform(
                        post(CARD_CREATE_URL)
                                .contentType(MediaType.APPLICATION_JSON)
                                .content(requestBody)
                );

                // then
                result.andExpect(status().isOk())
                        .andExpect(content().contentType(MediaType.APPLICATION_JSON))
                        .andExpect(jsonPath("$.cardId", is(expectedCard.getId().intValue())))
                        .andExpect(jsonPath("$.title", is(expectedCard.getTitle())))
                        .andExpect(jsonPath("$.content", is(expectedCard.getContent())));
            }
        }
    }

    private Card createCard(String title, String content, Long columnId, LocalDateTime createdDate) {
        return new Card(1L, title, content, columnId, createdDate, createdDate);
    }
}