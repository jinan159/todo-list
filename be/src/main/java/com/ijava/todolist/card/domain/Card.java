package com.ijava.todolist.card.domain;

import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.Setter;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.lang.NonNull;

import java.time.LocalDateTime;

@Getter
@EqualsAndHashCode
public class Card {

    private Long id;
    private String title;
    private String content;
    private Long columnsId;
    private final LocalDateTime createdDate;
    private LocalDateTime modifiedDate;

    public Card(Long id, String title, String content, Long columnsId, LocalDateTime createdDate, LocalDateTime modifiedDate) {
        this.id = id;
        this.title = title;
        this.content = content;
        this.columnsId = columnsId;
        this.createdDate = createdDate;
        this.modifiedDate = modifiedDate;
    }

    public Card(String title, String content, Long columnsId, LocalDateTime createdDate, LocalDateTime modifiedDate) {
        this(null, title, content, columnsId, createdDate, modifiedDate);
    }

    public void setId(Long id) {
        this.id = id;
    }

    public void moveColumn(Long columnsId) {
        this.columnsId = columnsId;
    }

    public void updateTitle(String title) {
        this.title = title;
    }

    public void updateContent(String content) {
        this.content = content;
    }

    public void changeModifiedDate() {
        this.modifiedDate = LocalDateTime.now();
    }

}
