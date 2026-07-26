-- ==============================================================================
-- Mindcircuit Book Store - Production MySQL Database Schema & Seed Data
-- Target Database Engine: Amazon RDS MySQL 8.0 (somesh-db-1)
-- Database Name: test | Private CNAME: book.rds.com
-- Author: Tarra Someswararao
-- ==============================================================================

CREATE DATABASE IF NOT EXISTS test;
USE test;

-- Drop table if existing for idempotency
DROP TABLE IF EXISTS books;

-- Create Books Catalog Table
CREATE TABLE books (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    `desc` TEXT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    cover VARCHAR(255) DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Seed Initial Book Catalog Records (Empirically Verified in Production Thesis)
INSERT INTO books (title, `desc`, price, cover) VALUES
('Gamer of throne', 'this is an amazing book to read when you are free', 2343.20, NULL),
('Fire folks', 'fire folks is ming blowing book to read it will blow your mind', 2342.30, NULL),
('Ulysses', 'First edition of Ulysses by James Joyce, published by Paris-Shakespeare, 1922. The colour of the cover was meant to match the blue of the Greek flag.', 243.00, 'https://upload.wikimedia.org/wikipedia/commons/a/ab/JoyceUlysses2.jpg');
