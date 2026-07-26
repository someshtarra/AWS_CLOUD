// ==============================================================================
// Mindcircuit Book Store - Backend Express API Server
// Database: Amazon RDS MySQL 8.0 (book.rds.com)
// Process Name: backendapi | Author: Tarra Someswararao
// ==============================================================================

const express = require('express');
const mysql = require('mysql2');
const cors = require('cors');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 8080;

app.use(express.json());
app.use(cors());

// MySQL Database Connection Pool
const db = mysql.createPool({
  host: process.env.DB_HOST || 'book.rds.com',
  user: process.env.DB_USERNAME || 'admin',
  password: process.env.DB_PASSWORD || 'Somesh12345',
  database: process.env.DB_NAME || 'test',
  port: process.env.DB_PORT || 3306,
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
});

// System Health Check Endpoint for Load Balancer Probes
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'HEALTHY',
    application: 'Mindcircuit Book Store API',
    tier: 'Application Tier (BE-ASG)',
    uptime: process.uptime(),
    timestamp: new Date().toISOString()
  });
});

// Fetch All Books Catalog
app.get('/books', (req, res) => {
  const query = 'SELECT * FROM books';
  db.query(query, (err, data) => {
    if (err) return res.status(500).json({ error: err.message });
    return res.status(200).json(data);
  });
});

// Add New Book Entry
app.post('/books', (req, res) => {
  const query = 'INSERT INTO books (`title`, `desc`, `price`, `cover`) VALUES (?)';
  const values = [req.body.title, req.body.desc, req.body.price, req.body.cover];

  db.query(query, [values], (err, data) => {
    if (err) return res.status(500).json({ error: err.message });
    return res.status(201).json({ message: 'Book created successfully', id: data.insertId });
  });
});

// Delete Book Entry
app.delete('/books/:id', (req, res) => {
  const bookId = req.params.id;
  const query = 'DELETE FROM books WHERE id = ?';

  db.query(query, [bookId], (err, data) => {
    if (err) return res.status(500).json({ error: err.message });
    return res.status(200).json({ message: 'Book deleted successfully' });
  });
});

// Update Book Entry
app.put('/books/:id', (req, res) => {
  const bookId = req.params.id;
  const query = 'UPDATE books SET `title` = ?, `desc` = ?, `price` = ?, `cover` = ? WHERE id = ?';
  const values = [req.body.title, req.body.desc, req.body.price, req.body.cover];

  db.query(query, [...values, bookId], (err, data) => {
    if (err) return res.status(500).json({ error: err.message });
    return res.status(200).json({ message: 'Book updated successfully' });
  });
});

if (require.main === module) {
  app.listen(PORT, () => {
    console.log(`[INFO] Mindcircuit Book Store API running on port ${PORT}`);
  });
}

module.exports = app;
