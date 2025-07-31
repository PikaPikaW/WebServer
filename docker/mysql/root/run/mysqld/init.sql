-- 创建数据库
CREATE DATABASE IF NOT EXISTS webserver;

-- 使用数据库
USE webserver;

-- 创建表
CREATE TABLE IF NOT EXISTS user (
    username VARCHAR(50) NOT NULL,
    password VARCHAR(50) NULL,
    PRIMARY KEY (username)
) ENGINE=InnoDB;

-- 插入初始数据
INSERT IGNORE INTO user (username, password) VALUES ('admin', '123456');

-- 远程访问用户
CREATE USER 'root'@'172.17.0.1' IDENTIFIED BY '123456';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'172.17.0.1' WITH GRANT OPTION;
FLUSH PRIVILEGES;