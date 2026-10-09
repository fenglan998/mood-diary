/*
 Navicat Premium Dump SQL

 Source Server         : localhost
 Source Server Type    : MySQL
 Source Server Version : 90200 (9.2.0)
 Source Host           : localhost:3306
 Source Schema         : dailybaro

 Target Server Type    : MySQL
 Target Server Version : 90200 (9.2.0)
 File Encoding         : 65001

 Date: 29/07/2025 15:33:08
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for anonymous_posts
-- ----------------------------
DROP TABLE IF EXISTS `anonymous_posts`;
CREATE TABLE `anonymous_posts` (
  `post_id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL,
  `content` text NOT NULL,
  `visibility` enum('public','private') DEFAULT 'public',
  `create_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`post_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `anonymous_posts_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`uid`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ----------------------------
-- Records of anonymous_posts
-- ----------------------------
BEGIN;
INSERT INTO `anonymous_posts` (`post_id`, `user_id`, `content`, `visibility`, `create_time`) VALUES (3, 99999, '欢迎来到匿名星球', 'public', '2025-07-26 03:17:17');
INSERT INTO `anonymous_posts` (`post_id`, `user_id`, `content`, `visibility`, `create_time`) VALUES (4, 99999, '说点什么', 'public', '2025-07-26 14:34:58');
INSERT INTO `anonymous_posts` (`post_id`, `user_id`, `content`, `visibility`, `create_time`) VALUES (5, 99999, '测试一下🐬', 'private', '2025-07-26 14:58:32');
INSERT INTO `anonymous_posts` (`post_id`, `user_id`, `content`, `visibility`, `create_time`) VALUES (6, 1, '希望音频测试顺利通过😊', 'public', '2025-07-26 23:00:00');
INSERT INTO `anonymous_posts` (`post_id`, `user_id`, `content`, `visibility`, `create_time`) VALUES (7, 1, '说点什么🌈', 'public', '2025-07-26 23:50:55');
INSERT INTO `anonymous_posts` (`post_id`, `user_id`, `content`, `visibility`, `create_time`) VALUES (8, 1, '1', 'public', '2025-07-29 14:33:41');
COMMIT;

-- ----------------------------
-- Table structure for capsule_media
-- ----------------------------
DROP TABLE IF EXISTS `capsule_media`;
CREATE TABLE `capsule_media` (
  `media_id` bigint NOT NULL AUTO_INCREMENT,
  `capsule_id` bigint NOT NULL,
  `media_type` enum('image','video','audio','other') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `media_url` varchar(500) NOT NULL,
  PRIMARY KEY (`media_id`),
  KEY `capsule_id` (`capsule_id`),
  CONSTRAINT `capsule_media_ibfk_1` FOREIGN KEY (`capsule_id`) REFERENCES `emotion_capsules` (`capsule_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=33 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ----------------------------
-- Records of capsule_media
-- ----------------------------
BEGIN;
INSERT INTO `capsule_media` (`media_id`, `capsule_id`, `media_type`, `media_url`) VALUES (3, 4, 'audio', '/uploads/f8de5bae-0d42-49cc-bfde-2a38ad0c667d.ncm');
INSERT INTO `capsule_media` (`media_id`, `capsule_id`, `media_type`, `media_url`) VALUES (4, 5, 'audio', '/uploads/0752bf9d-eaeb-464b-b12c-cb3330f45783.ncm');
INSERT INTO `capsule_media` (`media_id`, `capsule_id`, `media_type`, `media_url`) VALUES (5, 6, 'audio', '/uploads/080e5fee-8d60-4933-9e87-b57b57628f87.ncm');
INSERT INTO `capsule_media` (`media_id`, `capsule_id`, `media_type`, `media_url`) VALUES (6, 7, 'audio', '/uploads/8e115d8c-97e6-4d8f-b8fc-03e6399f1bd4.ncm');
INSERT INTO `capsule_media` (`media_id`, `capsule_id`, `media_type`, `media_url`) VALUES (17, 14, 'audio', '/uploads/11782f58-7408-47d6-a3b9-c1cd8ce2b971.ncm');
INSERT INTO `capsule_media` (`media_id`, `capsule_id`, `media_type`, `media_url`) VALUES (18, 15, 'audio', '/uploads/ff0483e5-c1eb-4713-b230-285df9e29bb9.ncm');
INSERT INTO `capsule_media` (`media_id`, `capsule_id`, `media_type`, `media_url`) VALUES (28, 26, 'audio', '/uploads/1aaf466b-2a64-4387-a827-f3ae2ee04c4f.mp3');
INSERT INTO `capsule_media` (`media_id`, `capsule_id`, `media_type`, `media_url`) VALUES (29, 27, 'audio', '/uploads/7b9a2216-0e8e-4d4d-8f58-7abdcd8f3428.mp3');
INSERT INTO `capsule_media` (`media_id`, `capsule_id`, `media_type`, `media_url`) VALUES (30, 28, 'video', '/uploads/06af8695-32b3-4490-99fa-7c6fdb156c14.mp4');
INSERT INTO `capsule_media` (`media_id`, `capsule_id`, `media_type`, `media_url`) VALUES (31, 30, 'audio', '/uploads/21f2f6a8-8bca-4679-a612-261624c20a31.mp3');
INSERT INTO `capsule_media` (`media_id`, `capsule_id`, `media_type`, `media_url`) VALUES (32, 31, 'audio', '/uploads/3cb216cb-40cb-4f79-a508-1477678f35c4.mp3');
COMMIT;

-- ----------------------------
-- Table structure for daily_quotes
-- ----------------------------
DROP TABLE IF EXISTS `daily_quotes`;
CREATE TABLE `daily_quotes` (
  `quote_id` bigint NOT NULL AUTO_INCREMENT,
  `content` varchar(500) NOT NULL,
  `author` varchar(100) DEFAULT 'Unknown',
  PRIMARY KEY (`quote_id`)
) ENGINE=InnoDB AUTO_INCREMENT=45 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ----------------------------
-- Records of daily_quotes
-- ----------------------------
BEGIN;
INSERT INTO `daily_quotes` (`quote_id`, `content`, `author`) VALUES (1, '今天也值得被温柔对待', '系统');
INSERT INTO `daily_quotes` (`quote_id`, `content`, `author`) VALUES (2, '你很棒，继续加油！', '系统');
INSERT INTO `daily_quotes` (`quote_id`, `content`, `author`) VALUES (3, '每一天都是新的开始', '系统');
INSERT INTO `daily_quotes` (`quote_id`, `content`, `author`) VALUES (4, '保持微笑，生活会更美好', '系统');
INSERT INTO `daily_quotes` (`quote_id`, `content`, `author`) VALUES (5, '今天也值得被温柔对待', 'Unknown');
INSERT INTO `daily_quotes` (`quote_id`, `content`, `author`) VALUES (6, '每一个微笑都是对生活的热爱', 'Unknown');
INSERT INTO `daily_quotes` (`quote_id`, `content`, `author`) VALUES (7, '相信自己，你比想象中更强大', 'Unknown');
INSERT INTO `daily_quotes` (`quote_id`, `content`, `author`) VALUES (8, '今天的努力是明天的收获', 'Unknown');
INSERT INTO `daily_quotes` (`quote_id`, `content`, `author`) VALUES (9, '保持希望，保持微笑', 'Unknown');
INSERT INTO `daily_quotes` (`quote_id`, `content`, `author`) VALUES (10, '你正在成为更好的自己', 'Unknown');
INSERT INTO `daily_quotes` (`quote_id`, `content`, `author`) VALUES (11, '每一个今天都是新的开始', 'Unknown');
INSERT INTO `daily_quotes` (`quote_id`, `content`, `author`) VALUES (12, '温柔对待自己，也温柔对待他人', 'Unknown');
INSERT INTO `daily_quotes` (`quote_id`, `content`, `author`) VALUES (13, '小小的进步也是值得庆祝的', 'Unknown');
INSERT INTO `daily_quotes` (`quote_id`, `content`, `author`) VALUES (14, '你的存在本身就是一种美好', 'Unknown');
INSERT INTO `daily_quotes` (`quote_id`, `content`, `author`) VALUES (15, '今天也要开开心心的', 'Unknown');
INSERT INTO `daily_quotes` (`quote_id`, `content`, `author`) VALUES (16, '相信自己，你可以的', 'Unknown');
INSERT INTO `daily_quotes` (`quote_id`, `content`, `author`) VALUES (17, '每一个挑战都是成长的机会', 'Unknown');
INSERT INTO `daily_quotes` (`quote_id`, `content`, `author`) VALUES (18, '保持初心，保持热爱', 'Unknown');
INSERT INTO `daily_quotes` (`quote_id`, `content`, `author`) VALUES (19, '今天的你比昨天更优秀', 'Unknown');
INSERT INTO `daily_quotes` (`quote_id`, `content`, `author`) VALUES (20, '温柔的力量最强大', 'Unknown');
INSERT INTO `daily_quotes` (`quote_id`, `content`, `author`) VALUES (21, '相信自己内心的声音', 'Unknown');
INSERT INTO `daily_quotes` (`quote_id`, `content`, `author`) VALUES (22, '每一个选择都让你更接近梦想', 'Unknown');
INSERT INTO `daily_quotes` (`quote_id`, `content`, `author`) VALUES (23, '今天的阳光为你而亮', 'Unknown');
INSERT INTO `daily_quotes` (`quote_id`, `content`, `author`) VALUES (24, '你值得拥有所有的美好', 'Unknown');
INSERT INTO `daily_quotes` (`quote_id`, `content`, `author`) VALUES (25, '今天也值得被温柔对待', 'Unknown');
INSERT INTO `daily_quotes` (`quote_id`, `content`, `author`) VALUES (26, '每一个微笑都是对生活的热爱', 'Unknown');
INSERT INTO `daily_quotes` (`quote_id`, `content`, `author`) VALUES (27, '相信自己，你比想象中更强大', 'Unknown');
INSERT INTO `daily_quotes` (`quote_id`, `content`, `author`) VALUES (28, '今天的努力是明天的收获', 'Unknown');
INSERT INTO `daily_quotes` (`quote_id`, `content`, `author`) VALUES (29, '保持希望，保持微笑', 'Unknown');
INSERT INTO `daily_quotes` (`quote_id`, `content`, `author`) VALUES (30, '你正在成为更好的自己', 'Unknown');
INSERT INTO `daily_quotes` (`quote_id`, `content`, `author`) VALUES (31, '每一个今天都是新的开始', 'Unknown');
INSERT INTO `daily_quotes` (`quote_id`, `content`, `author`) VALUES (32, '温柔对待自己，也温柔对待他人', 'Unknown');
INSERT INTO `daily_quotes` (`quote_id`, `content`, `author`) VALUES (33, '小小的进步也是值得庆祝的', 'Unknown');
INSERT INTO `daily_quotes` (`quote_id`, `content`, `author`) VALUES (34, '你的存在本身就是一种美好', 'Unknown');
INSERT INTO `daily_quotes` (`quote_id`, `content`, `author`) VALUES (35, '今天也要开开心心的', 'Unknown');
INSERT INTO `daily_quotes` (`quote_id`, `content`, `author`) VALUES (36, '相信自己，你可以的', 'Unknown');
INSERT INTO `daily_quotes` (`quote_id`, `content`, `author`) VALUES (37, '每一个挑战都是成长的机会', 'Unknown');
INSERT INTO `daily_quotes` (`quote_id`, `content`, `author`) VALUES (38, '保持初心，保持热爱', 'Unknown');
INSERT INTO `daily_quotes` (`quote_id`, `content`, `author`) VALUES (39, '今天的你比昨天更优秀', 'Unknown');
INSERT INTO `daily_quotes` (`quote_id`, `content`, `author`) VALUES (40, '温柔的力量最强大', 'Unknown');
INSERT INTO `daily_quotes` (`quote_id`, `content`, `author`) VALUES (41, '相信自己内心的声音', 'Unknown');
INSERT INTO `daily_quotes` (`quote_id`, `content`, `author`) VALUES (42, '每一个选择都让你更接近梦想', 'Unknown');
INSERT INTO `daily_quotes` (`quote_id`, `content`, `author`) VALUES (43, '今天的阳光为你而亮', 'Unknown');
INSERT INTO `daily_quotes` (`quote_id`, `content`, `author`) VALUES (44, '你值得拥有所有的美好', 'Unknown');
COMMIT;

-- ----------------------------
-- Table structure for diaries
-- ----------------------------
DROP TABLE IF EXISTS `diaries`;
CREATE TABLE `diaries` (
  `diary_id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL,
  `title` varchar(255) DEFAULT NULL,
  `content` text,
  `status` enum('draft','published') DEFAULT 'draft',
  `create_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`diary_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `diaries_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`uid`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ----------------------------
-- Records of diaries
-- ----------------------------
BEGIN;
INSERT INTO `diaries` (`diary_id`, `user_id`, `title`, `content`, `status`, `create_time`, `update_time`) VALUES (1, 1, '备考四级day1', 'sadness', 'published', '2025-07-25 00:48:11', '2025-07-25 20:35:31');
INSERT INTO `diaries` (`diary_id`, `user_id`, `title`, `content`, `status`, `create_time`, `update_time`) VALUES (2, 1, 'ceshih', 'ces', 'published', '2025-07-25 15:17:09', '2025-07-28 17:27:45');
INSERT INTO `diaries` (`diary_id`, `user_id`, `title`, `content`, `status`, `create_time`, `update_time`) VALUES (4, 1, 'mv测试', '测试', 'draft', '2025-07-25 20:44:45', '2025-07-27 19:43:07');
INSERT INTO `diaries` (`diary_id`, `user_id`, `title`, `content`, `status`, `create_time`, `update_time`) VALUES (6, 100000, '这是一个测试', '这是一个测试', 'draft', '2025-07-28 23:00:17', '2025-07-28 23:59:00');
COMMIT;

-- ----------------------------
-- Table structure for diary_media
-- ----------------------------
DROP TABLE IF EXISTS `diary_media`;
CREATE TABLE `diary_media` (
  `media_id` bigint NOT NULL AUTO_INCREMENT,
  `diary_id` bigint NOT NULL,
  `media_type` enum('image','video','audio') NOT NULL,
  `media_url` varchar(500) NOT NULL,
  `create_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`media_id`),
  KEY `diary_id` (`diary_id`),
  CONSTRAINT `diary_media_ibfk_1` FOREIGN KEY (`diary_id`) REFERENCES `diaries` (`diary_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ----------------------------
-- Records of diary_media
-- ----------------------------
BEGIN;
INSERT INTO `diary_media` (`media_id`, `diary_id`, `media_type`, `media_url`, `create_time`) VALUES (1, 2, 'image', '/uploads/81da6cb4-2b44-4390-acf8-2c11b81fa9d0.png', '2025-07-25 20:13:27');
INSERT INTO `diary_media` (`media_id`, `diary_id`, `media_type`, `media_url`, `create_time`) VALUES (2, 2, 'image', '/uploads/a9adcaf8-3b17-4de4-9bf6-3182c59af110.png', '2025-07-25 20:15:14');
INSERT INTO `diary_media` (`media_id`, `diary_id`, `media_type`, `media_url`, `create_time`) VALUES (3, 2, 'image', '/uploads/c7231325-a491-406f-a6b3-ba07d96bcbec.png', '2025-07-25 20:16:56');
INSERT INTO `diary_media` (`media_id`, `diary_id`, `media_type`, `media_url`, `create_time`) VALUES (4, 1, 'audio', '/uploads/9cb00afb-68a8-4eb0-89c6-f1c8cca8c4b1.mp3', '2025-07-25 20:32:16');
INSERT INTO `diary_media` (`media_id`, `diary_id`, `media_type`, `media_url`, `create_time`) VALUES (12, 6, 'video', '/uploads/77fffe49-5211-412a-934d-a253b88fd4b3.mp4', '2025-07-28 23:58:39');
COMMIT;

-- ----------------------------
-- Table structure for diary_tags
-- ----------------------------
DROP TABLE IF EXISTS `diary_tags`;
CREATE TABLE `diary_tags` (
  `diary_id` bigint NOT NULL,
  `tag_id` bigint NOT NULL,
  PRIMARY KEY (`diary_id`,`tag_id`),
  KEY `tag_id` (`tag_id`),
  CONSTRAINT `diary_tags_ibfk_1` FOREIGN KEY (`diary_id`) REFERENCES `diaries` (`diary_id`) ON DELETE CASCADE,
  CONSTRAINT `diary_tags_ibfk_2` FOREIGN KEY (`tag_id`) REFERENCES `tags` (`tag_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ----------------------------
-- Records of diary_tags
-- ----------------------------
BEGIN;
INSERT INTO `diary_tags` (`diary_id`, `tag_id`) VALUES (1, 2);
INSERT INTO `diary_tags` (`diary_id`, `tag_id`) VALUES (2, 5);
INSERT INTO `diary_tags` (`diary_id`, `tag_id`) VALUES (6, 7);
COMMIT;

-- ----------------------------
-- Table structure for emotion_analysis_result
-- ----------------------------
DROP TABLE IF EXISTS `emotion_analysis_result`;
CREATE TABLE `emotion_analysis_result` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL,
  `analysis_text` text,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `create_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `emotion_analysis_result_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`uid`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ----------------------------
-- Records of emotion_analysis_result
-- ----------------------------
BEGIN;
COMMIT;

-- ----------------------------
-- Table structure for emotion_capsules
-- ----------------------------
DROP TABLE IF EXISTS `emotion_capsules`;
CREATE TABLE `emotion_capsules` (
  `capsule_id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL,
  `content` text,
  `current_emotion` varchar(50) DEFAULT '开心' COMMENT '当前情绪',
  `thoughts` text COMMENT '想法',
  `future_goal` text COMMENT '未来目标',
  `open_time` timestamp NOT NULL,
  `reminder_type` enum('app_notification','sms') DEFAULT 'app_notification',
  `create_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `reminder_sent` tinyint(1) DEFAULT '0',
  `reminder_read` tinyint(1) DEFAULT '0' COMMENT '应用内提醒是否已读 0未读 1已读',
  PRIMARY KEY (`capsule_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `emotion_capsules_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`uid`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=32 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ----------------------------
-- Records of emotion_capsules
-- ----------------------------
BEGIN;
INSERT INTO `emotion_capsules` (`capsule_id`, `user_id`, `content`, `current_emotion`, `thoughts`, `future_goal`, `open_time`, `reminder_type`, `create_time`, `reminder_sent`, `reminder_read`) VALUES (4, 100001, '这是一个测试胶囊', '开心', NULL, NULL, '2025-07-26 19:46:00', 'app_notification', '2025-07-26 19:45:19', 1, 0);
INSERT INTO `emotion_capsules` (`capsule_id`, `user_id`, `content`, `current_emotion`, `thoughts`, `future_goal`, `open_time`, `reminder_type`, `create_time`, `reminder_sent`, `reminder_read`) VALUES (5, 100001, '这是一个测试', '开心', NULL, NULL, '2025-07-26 19:51:00', 'app_notification', '2025-07-26 19:50:21', 1, 0);
INSERT INTO `emotion_capsules` (`capsule_id`, `user_id`, `content`, `current_emotion`, `thoughts`, `future_goal`, `open_time`, `reminder_type`, `create_time`, `reminder_sent`, `reminder_read`) VALUES (6, 100001, '这依然是一个测试', '开心', NULL, NULL, '2025-07-26 19:54:00', 'app_notification', '2025-07-26 19:53:27', 1, 0);
INSERT INTO `emotion_capsules` (`capsule_id`, `user_id`, `content`, `current_emotion`, `thoughts`, `future_goal`, `open_time`, `reminder_type`, `create_time`, `reminder_sent`, `reminder_read`) VALUES (7, 100001, '这还是一个测试', '开心', NULL, NULL, '2025-07-26 19:06:00', 'app_notification', '2025-07-26 20:05:45', 1, 0);
INSERT INTO `emotion_capsules` (`capsule_id`, `user_id`, `content`, `current_emotion`, `thoughts`, `future_goal`, `open_time`, `reminder_type`, `create_time`, `reminder_sent`, `reminder_read`) VALUES (14, 100001, '这是一个音频测试', '难过', '这是一个音频测试', '音频测试顺利通过', '2025-07-26 21:33:00', 'app_notification', '2025-07-26 21:32:26', 1, 0);
INSERT INTO `emotion_capsules` (`capsule_id`, `user_id`, `content`, `current_emotion`, `thoughts`, `future_goal`, `open_time`, `reminder_type`, `create_time`, `reminder_sent`, `reminder_read`) VALUES (15, 100001, '希望测试顺利通过', '平静', '希望测试顺利通过', '希望测试顺利通过', '2025-07-26 21:49:00', 'app_notification', '2025-07-26 21:48:45', 1, 0);
INSERT INTO `emotion_capsules` (`capsule_id`, `user_id`, `content`, `current_emotion`, `thoughts`, `future_goal`, `open_time`, `reminder_type`, `create_time`, `reminder_sent`, `reminder_read`) VALUES (26, 100000, '测试', '开心', '测试', '测试', '2025-07-27 18:38:00', 'app_notification', '2025-07-27 18:37:03', 1, 0);
INSERT INTO `emotion_capsules` (`capsule_id`, `user_id`, `content`, `current_emotion`, `thoughts`, `future_goal`, `open_time`, `reminder_type`, `create_time`, `reminder_sent`, `reminder_read`) VALUES (27, 1, '测试', '平静', '测试', '测试', '2025-07-27 19:05:00', 'app_notification', '2025-07-27 19:04:07', 1, 1);
INSERT INTO `emotion_capsules` (`capsule_id`, `user_id`, `content`, `current_emotion`, `thoughts`, `future_goal`, `open_time`, `reminder_type`, `create_time`, `reminder_sent`, `reminder_read`) VALUES (28, 1, '1', 'happy', '1', '1', '2025-07-29 12:39:00', 'app_notification', '2025-07-29 12:38:17', 1, 0);
INSERT INTO `emotion_capsules` (`capsule_id`, `user_id`, `content`, `current_emotion`, `thoughts`, `future_goal`, `open_time`, `reminder_type`, `create_time`, `reminder_sent`, `reminder_read`) VALUES (30, 100001, '1', 'happy', '1', '1', '2025-07-29 15:25:00', 'app_notification', '2025-07-29 15:24:15', 1, 0);
INSERT INTO `emotion_capsules` (`capsule_id`, `user_id`, `content`, `current_emotion`, `thoughts`, `future_goal`, `open_time`, `reminder_type`, `create_time`, `reminder_sent`, `reminder_read`) VALUES (31, 1, '1', 'happy', '1', '1', '2025-07-29 15:33:00', 'app_notification', '2025-07-29 15:32:53', 0, 0);
COMMIT;

-- ----------------------------
-- Table structure for mystery_box_items
-- ----------------------------
DROP TABLE IF EXISTS `mystery_box_items`;
CREATE TABLE `mystery_box_items` (
  `box_item_id` bigint NOT NULL AUTO_INCREMENT,
  `content_type` enum('quote','task','tip') NOT NULL,
  `content` text NOT NULL,
  PRIMARY KEY (`box_item_id`)
) ENGINE=InnoDB AUTO_INCREMENT=123 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ----------------------------
-- Records of mystery_box_items
-- ----------------------------
BEGIN;
INSERT INTO `mystery_box_items` (`box_item_id`, `content_type`, `content`) VALUES (83, 'quote', '今天的你比昨天更棒！');
INSERT INTO `mystery_box_items` (`box_item_id`, `content_type`, `content`) VALUES (84, 'quote', '每一个微笑都是对生活的热爱');
INSERT INTO `mystery_box_items` (`box_item_id`, `content_type`, `content`) VALUES (85, 'quote', '相信自己，你比想象中更强大');
INSERT INTO `mystery_box_items` (`box_item_id`, `content_type`, `content`) VALUES (86, 'quote', '慢慢来，一切都会好起来的');
INSERT INTO `mystery_box_items` (`box_item_id`, `content_type`, `content`) VALUES (87, 'quote', '今天的阳光正好，心情也要美美的');
INSERT INTO `mystery_box_items` (`box_item_id`, `content_type`, `content`) VALUES (88, 'quote', '你是独一无二的，值得被温柔对待');
INSERT INTO `mystery_box_items` (`box_item_id`, `content_type`, `content`) VALUES (89, 'quote', '每一个努力的日子都不会被辜负');
INSERT INTO `mystery_box_items` (`box_item_id`, `content_type`, `content`) VALUES (90, 'quote', '保持微笑，生活会更美好');
INSERT INTO `mystery_box_items` (`box_item_id`, `content_type`, `content`) VALUES (91, 'quote', '今天的你依然闪闪发光');
INSERT INTO `mystery_box_items` (`box_item_id`, `content_type`, `content`) VALUES (92, 'quote', '相信自己，你正在成为更好的自己');
INSERT INTO `mystery_box_items` (`box_item_id`, `content_type`, `content`) VALUES (93, 'task', '今天尝试做一件一直想做但没做的小事');
INSERT INTO `mystery_box_items` (`box_item_id`, `content_type`, `content`) VALUES (94, 'task', '给一个朋友发个温暖的问候');
INSERT INTO `mystery_box_items` (`box_item_id`, `content_type`, `content`) VALUES (95, 'task', '整理一下自己的房间或工作台');
INSERT INTO `mystery_box_items` (`box_item_id`, `content_type`, `content`) VALUES (96, 'task', '尝试一种新的食物或饮料');
INSERT INTO `mystery_box_items` (`box_item_id`, `content_type`, `content`) VALUES (97, 'task', '拍一张今天最美的照片');
INSERT INTO `mystery_box_items` (`box_item_id`, `content_type`, `content`) VALUES (98, 'task', '给家人打个电话或发个消息');
INSERT INTO `mystery_box_items` (`box_item_id`, `content_type`, `content`) VALUES (99, 'task', '学习一个新的小技能');
INSERT INTO `mystery_box_items` (`box_item_id`, `content_type`, `content`) VALUES (100, 'task', '写下一件今天感恩的事情');
INSERT INTO `mystery_box_items` (`box_item_id`, `content_type`, `content`) VALUES (101, 'task', '给陌生人一个微笑');
INSERT INTO `mystery_box_items` (`box_item_id`, `content_type`, `content`) VALUES (102, 'task', '尝试一个新的运动或活动');
INSERT INTO `mystery_box_items` (`box_item_id`, `content_type`, `content`) VALUES (103, 'task', '听一首从未听过的音乐');
INSERT INTO `mystery_box_items` (`box_item_id`, `content_type`, `content`) VALUES (104, 'task', '画一幅简单的画');
INSERT INTO `mystery_box_items` (`box_item_id`, `content_type`, `content`) VALUES (105, 'task', '给植物浇水或照顾宠物');
INSERT INTO `mystery_box_items` (`box_item_id`, `content_type`, `content`) VALUES (106, 'task', '尝试一个新的发型或穿搭');
INSERT INTO `mystery_box_items` (`box_item_id`, `content_type`, `content`) VALUES (107, 'task', '给未来的自己写一封信');
INSERT INTO `mystery_box_items` (`box_item_id`, `content_type`, `content`) VALUES (108, 'tip', '深呼吸三次，感受当下的平静');
INSERT INTO `mystery_box_items` (`box_item_id`, `content_type`, `content`) VALUES (109, 'tip', '写下三件今天让你感恩的事情');
INSERT INTO `mystery_box_items` (`box_item_id`, `content_type`, `content`) VALUES (110, 'tip', '听一首喜欢的音乐，放松心情');
INSERT INTO `mystery_box_items` (`box_item_id`, `content_type`, `content`) VALUES (111, 'tip', '给自己一个温暖的拥抱');
INSERT INTO `mystery_box_items` (`box_item_id`, `content_type`, `content`) VALUES (112, 'tip', '闭上眼睛，想象美好的画面');
INSERT INTO `mystery_box_items` (`box_item_id`, `content_type`, `content`) VALUES (113, 'tip', '做5分钟的简单拉伸运动');
INSERT INTO `mystery_box_items` (`box_item_id`, `content_type`, `content`) VALUES (114, 'tip', '喝一杯温水，感受温暖');
INSERT INTO `mystery_box_items` (`box_item_id`, `content_type`, `content`) VALUES (115, 'tip', '数数周围的五种颜色');
INSERT INTO `mystery_box_items` (`box_item_id`, `content_type`, `content`) VALUES (116, 'tip', '深呼吸，感受空气的流动');
INSERT INTO `mystery_box_items` (`box_item_id`, `content_type`, `content`) VALUES (117, 'tip', '给自己一个鼓励的话语');
INSERT INTO `mystery_box_items` (`box_item_id`, `content_type`, `content`) VALUES (118, 'tip', '想象自己在一个安全的地方');
INSERT INTO `mystery_box_items` (`box_item_id`, `content_type`, `content`) VALUES (119, 'tip', '做几个简单的瑜伽动作');
INSERT INTO `mystery_box_items` (`box_item_id`, `content_type`, `content`) VALUES (120, 'tip', '听一段自然的声音');
INSERT INTO `mystery_box_items` (`box_item_id`, `content_type`, `content`) VALUES (121, 'tip', '写下今天的三个小成就');
INSERT INTO `mystery_box_items` (`box_item_id`, `content_type`, `content`) VALUES (122, 'tip', '给自己一个微笑，即使心情不好');
COMMIT;

-- ----------------------------
-- Table structure for post_comments
-- ----------------------------
DROP TABLE IF EXISTS `post_comments`;
CREATE TABLE `post_comments` (
  `comment_id` bigint NOT NULL AUTO_INCREMENT,
  `post_id` bigint NOT NULL,
  `user_id` bigint NOT NULL,
  `content` text NOT NULL,
  `create_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`comment_id`),
  KEY `post_id` (`post_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `post_comments_ibfk_1` FOREIGN KEY (`post_id`) REFERENCES `anonymous_posts` (`post_id`) ON DELETE CASCADE,
  CONSTRAINT `post_comments_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `user` (`uid`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ----------------------------
-- Records of post_comments
-- ----------------------------
BEGIN;
INSERT INTO `post_comments` (`comment_id`, `post_id`, `user_id`, `content`, `create_time`) VALUES (2, 3, 99999, '1', '2025-07-26 14:39:40');
INSERT INTO `post_comments` (`comment_id`, `post_id`, `user_id`, `content`, `create_time`) VALUES (3, 4, 99999, '1', '2025-07-26 15:00:57');
INSERT INTO `post_comments` (`comment_id`, `post_id`, `user_id`, `content`, `create_time`) VALUES (4, 3, 99999, '2', '2025-07-26 15:01:06');
INSERT INTO `post_comments` (`comment_id`, `post_id`, `user_id`, `content`, `create_time`) VALUES (5, 4, 99999, '2', '2025-07-26 15:29:53');
INSERT INTO `post_comments` (`comment_id`, `post_id`, `user_id`, `content`, `create_time`) VALUES (6, 6, 99999, '1', '2025-07-26 23:51:03');
INSERT INTO `post_comments` (`comment_id`, `post_id`, `user_id`, `content`, `create_time`) VALUES (7, 6, 1, '2', '2025-07-29 02:50:18');
INSERT INTO `post_comments` (`comment_id`, `post_id`, `user_id`, `content`, `create_time`) VALUES (8, 4, 1, '3', '2025-07-29 02:50:26');
INSERT INTO `post_comments` (`comment_id`, `post_id`, `user_id`, `content`, `create_time`) VALUES (9, 8, 1, '2', '2025-07-29 14:33:46');
INSERT INTO `post_comments` (`comment_id`, `post_id`, `user_id`, `content`, `create_time`) VALUES (10, 8, 1, '3', '2025-07-29 15:07:50');
COMMIT;

-- ----------------------------
-- Table structure for post_likes
-- ----------------------------
DROP TABLE IF EXISTS `post_likes`;
CREATE TABLE `post_likes` (
  `like_id` bigint NOT NULL AUTO_INCREMENT,
  `post_id` bigint NOT NULL,
  `user_id` bigint NOT NULL,
  PRIMARY KEY (`like_id`),
  UNIQUE KEY `post_id_user_id` (`post_id`,`user_id`),
  KEY `post_likes_ibfk_2` (`user_id`),
  CONSTRAINT `post_likes_ibfk_1` FOREIGN KEY (`post_id`) REFERENCES `anonymous_posts` (`post_id`) ON DELETE CASCADE,
  CONSTRAINT `post_likes_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `user` (`uid`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ----------------------------
-- Records of post_likes
-- ----------------------------
BEGIN;
INSERT INTO `post_likes` (`like_id`, `post_id`, `user_id`) VALUES (4, 3, 99999);
INSERT INTO `post_likes` (`like_id`, `post_id`, `user_id`) VALUES (6, 3, 100001);
INSERT INTO `post_likes` (`like_id`, `post_id`, `user_id`) VALUES (14, 4, 1);
INSERT INTO `post_likes` (`like_id`, `post_id`, `user_id`) VALUES (3, 4, 99999);
INSERT INTO `post_likes` (`like_id`, `post_id`, `user_id`) VALUES (5, 4, 100000);
INSERT INTO `post_likes` (`like_id`, `post_id`, `user_id`) VALUES (7, 4, 100001);
INSERT INTO `post_likes` (`like_id`, `post_id`, `user_id`) VALUES (16, 7, 1);
INSERT INTO `post_likes` (`like_id`, `post_id`, `user_id`) VALUES (17, 8, 1);
COMMIT;

-- ----------------------------
-- Table structure for tags
-- ----------------------------
DROP TABLE IF EXISTS `tags`;
CREATE TABLE `tags` (
  `tag_id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL,
  `tag_name` varchar(50) NOT NULL,
  PRIMARY KEY (`tag_id`),
  UNIQUE KEY `user_id_tag_name` (`user_id`,`tag_name`),
  CONSTRAINT `tags_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`uid`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ----------------------------
-- Records of tags
-- ----------------------------
BEGIN;
INSERT INTO `tags` (`tag_id`, `user_id`, `tag_name`) VALUES (3, 1, '压力');
INSERT INTO `tags` (`tag_id`, `user_id`, `tag_name`) VALUES (5, 1, '平静');
INSERT INTO `tags` (`tag_id`, `user_id`, `tag_name`) VALUES (1, 1, '开心');
INSERT INTO `tags` (`tag_id`, `user_id`, `tag_name`) VALUES (4, 1, '激动');
INSERT INTO `tags` (`tag_id`, `user_id`, `tag_name`) VALUES (2, 1, '难过');
INSERT INTO `tags` (`tag_id`, `user_id`, `tag_name`) VALUES (7, 100000, '压力');
INSERT INTO `tags` (`tag_id`, `user_id`, `tag_name`) VALUES (6, 100000, '平静');
COMMIT;

-- ----------------------------
-- Table structure for user
-- ----------------------------
DROP TABLE IF EXISTS `user`;
CREATE TABLE `user` (
  `uid` bigint NOT NULL AUTO_INCREMENT,
  `account` varchar(20) NOT NULL COMMENT '账号',
  `password` varchar(100) NOT NULL COMMENT '密码',
  `phone` varchar(20) DEFAULT NULL COMMENT '手机号',
  `email` varchar(50) DEFAULT NULL COMMENT '邮箱',
  `status` tinyint DEFAULT '0' COMMENT '状态 0正常 1禁用',
  `isdelete` tinyint DEFAULT '0' COMMENT '是否删除 0未删除 1已删除',
  `wx_openid` varchar(64) DEFAULT NULL COMMENT '微信openid',
  `energy` int DEFAULT '0',
  PRIMARY KEY (`uid`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=100003 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='用户表';

-- ----------------------------
-- Records of user
-- ----------------------------
BEGIN;
INSERT INTO `user` (`uid`, `account`, `password`, `phone`, `email`, `status`, `isdelete`, `wx_openid`, `energy`) VALUES (1, 'test', '$2a$10$x8bdEIeR0SQdBIIjPCzytuN7YOuPtMShvWhjnKdmzKo6NjOQW2iSu', '13111111112', 'test@163.com', 0, 0, NULL, 35);
INSERT INTO `user` (`uid`, `account`, `password`, `phone`, `email`, `status`, `isdelete`, `wx_openid`, `energy`) VALUES (3, 'zhangsan', '$2a$10$27X.Fkzsilyqkwk3OPmubO2zam6mVezSNjn8DKkZ22E3MsY/8nOpu', '13111111111', '123@123.com', 0, 1, NULL, 0);
INSERT INTO `user` (`uid`, `account`, `password`, `phone`, `email`, `status`, `isdelete`, `wx_openid`, `energy`) VALUES (4, 'zhang3', '$2a$10$gLaqZM4ONLpCMeT5edzvV.2IcDAzaGlXNC0aUr9moOhxrznzv6kw2', '13111111111', '3@163.com', 0, 1, NULL, 0);
INSERT INTO `user` (`uid`, `account`, `password`, `phone`, `email`, `status`, `isdelete`, `wx_openid`, `energy`) VALUES (99999, 'anonymous', 'anonymous', NULL, NULL, 0, 0, NULL, 0);
INSERT INTO `user` (`uid`, `account`, `password`, `phone`, `email`, `status`, `isdelete`, `wx_openid`, `energy`) VALUES (100000, 'lisi', '$2a$10$DS235Px226MoVShN8bQWZOaul2CQWu5wwf3ps4WEV8nssoxcA/b2m', NULL, NULL, 0, 0, NULL, 22);
INSERT INTO `user` (`uid`, `account`, `password`, `phone`, `email`, `status`, `isdelete`, `wx_openid`, `energy`) VALUES (100001, 'wangwu', '$2a$10$1P5/AGeBcctbwy.ddeh1uOCm1RJH4LXU.eBbvYVmyaing0.rWYaqa', NULL, NULL, 0, 0, NULL, 5);
INSERT INTO `user` (`uid`, `account`, `password`, `phone`, `email`, `status`, `isdelete`, `wx_openid`, `energy`) VALUES (100002, 'zhao6', '$2a$10$tQuQE3oSbgCP4PC3mtOw0.nLrHGl.QEpEiEwf45khBuKJZo4EdQFK', NULL, NULL, 0, 0, NULL, 6);
COMMIT;

-- ----------------------------
-- Table structure for user_daily_quote
-- ----------------------------
DROP TABLE IF EXISTS `user_daily_quote`;
CREATE TABLE `user_daily_quote` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL,
  `content` varchar(500) NOT NULL,
  `create_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `user_daily_quote_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`uid`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ----------------------------
-- Records of user_daily_quote
-- ----------------------------
BEGIN;
INSERT INTO `user_daily_quote` (`id`, `user_id`, `content`, `create_time`, `update_time`) VALUES (1, 100000, '每一个微笑都是对生活的热爱', '2025-07-26 15:52:10', '2025-07-27 16:12:03');
INSERT INTO `user_daily_quote` (`id`, `user_id`, `content`, `create_time`, `update_time`) VALUES (2, 1, '1', '2025-07-26 18:58:02', '2025-07-29 14:30:28');
INSERT INTO `user_daily_quote` (`id`, `user_id`, `content`, `create_time`, `update_time`) VALUES (3, 100002, '你正在成为更好的自己', '2025-07-27 16:53:15', '2025-07-27 16:53:15');
INSERT INTO `user_daily_quote` (`id`, `user_id`, `content`, `create_time`, `update_time`) VALUES (4, 100001, '每一个今天都是新的开始', '2025-07-27 17:02:30', '2025-07-29 15:13:58');
COMMIT;

-- ----------------------------
-- Table structure for user_drawn_boxes
-- ----------------------------
DROP TABLE IF EXISTS `user_drawn_boxes`;
CREATE TABLE `user_drawn_boxes` (
  `drawn_box_id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL,
  `box_item_id` bigint NOT NULL,
  `draw_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `is_completed` tinyint(1) DEFAULT '0' COMMENT '0 for not completed/not applicable, 1 for completed',
  PRIMARY KEY (`drawn_box_id`),
  KEY `user_id` (`user_id`),
  KEY `box_item_id` (`box_item_id`),
  CONSTRAINT `user_drawn_boxes_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`uid`) ON DELETE CASCADE,
  CONSTRAINT `user_drawn_boxes_ibfk_2` FOREIGN KEY (`box_item_id`) REFERENCES `mystery_box_items` (`box_item_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=37 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ----------------------------
-- Records of user_drawn_boxes
-- ----------------------------
BEGIN;
INSERT INTO `user_drawn_boxes` (`drawn_box_id`, `user_id`, `box_item_id`, `draw_time`, `is_completed`) VALUES (28, 100001, 94, '2025-07-27 18:31:44', 1);
INSERT INTO `user_drawn_boxes` (`drawn_box_id`, `user_id`, `box_item_id`, `draw_time`, `is_completed`) VALUES (29, 1, 112, '2025-07-27 19:06:36', 0);
INSERT INTO `user_drawn_boxes` (`drawn_box_id`, `user_id`, `box_item_id`, `draw_time`, `is_completed`) VALUES (30, 1, 107, '2025-07-27 19:06:45', 1);
INSERT INTO `user_drawn_boxes` (`drawn_box_id`, `user_id`, `box_item_id`, `draw_time`, `is_completed`) VALUES (31, 1, 94, '2025-07-29 13:39:17', 1);
INSERT INTO `user_drawn_boxes` (`drawn_box_id`, `user_id`, `box_item_id`, `draw_time`, `is_completed`) VALUES (32, 100001, 91, '2025-07-29 15:18:43', 0);
INSERT INTO `user_drawn_boxes` (`drawn_box_id`, `user_id`, `box_item_id`, `draw_time`, `is_completed`) VALUES (33, 100001, 116, '2025-07-29 15:18:51', 0);
INSERT INTO `user_drawn_boxes` (`drawn_box_id`, `user_id`, `box_item_id`, `draw_time`, `is_completed`) VALUES (34, 1, 93, '2025-07-29 15:24:37', 0);
INSERT INTO `user_drawn_boxes` (`drawn_box_id`, `user_id`, `box_item_id`, `draw_time`, `is_completed`) VALUES (35, 1, 106, '2025-07-29 15:27:23', 1);
INSERT INTO `user_drawn_boxes` (`drawn_box_id`, `user_id`, `box_item_id`, `draw_time`, `is_completed`) VALUES (36, 1, 89, '2025-07-29 15:32:13', 0);
COMMIT;

SET FOREIGN_KEY_CHECKS = 1;
