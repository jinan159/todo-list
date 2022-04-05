CREATE TABLE `card` (
    `id` bigint PRIMARY KEY AUTO_INCREMENT,
    `columns_id` bigint,
    `title` varchar(255),
    `content` varchar(500),
    `create_date` timestamp,
    `modified_date` timestamp
);

CREATE TABLE `columns` (
    `id` bigint PRIMARY KEY AUTO_INCREMENT,
    `name` varchar(255),
    `create_date` timestamp,
    `modified_date` timestamp
);

CREATE TABLE `users` (
    `id` bigint PRIMARY KEY AUTO_INCREMENT,
    `name` varchar(255),
    `create_date` timestamp,
    `modified_date` timestamp
);

CREATE TABLE `history` (
   `id` bigint PRIMARY KEY AUTO_INCREMENT,
   `user_id` bigint,
   `card_id` bigint,
   `columns_id` bigint,
   `action` char,
   `create_date` timestamp,
   `modified_date` timestamp
);

-- ALTER TABLE `users` ADD FOREIGN KEY (`id`) REFERENCES `history` (`user_id`);
-- ALTER TABLE `card` ADD FOREIGN KEY (`id`) REFERENCES `history` (`card_id`);
-- ALTER TABLE `columns` ADD FOREIGN KEY (`id`) REFERENCES `history` (`columns_id`);
-- ALTER TABLE `columns` ADD FOREIGN KEY (`id`) REFERENCES `card` (`columns_id`);
