const express = require('express');
const pool = require('../config/database'); // Assuming a database configuration file

const app = express();

// Middleware for parsing JSON request bodies
app.use(express.json());

// Function to get all students
const getAllStudents = async (req, res) => {
  try {
    const [rows] = await pool.query('SELECT student_id, fullname, course, created_at, updated_at FROM students');
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// Function to get a student by ID
const getStudentById = async (req, res) => {
  const { id } = req.params;

  try {
    const [rows] = await pool.query('SELECT student_id, fullname, course, created_at, updated_at FROM students WHERE student_id = ?', [id]);

    if (rows.length === 0) {
      return res.status(404).json({ error: 'Student not found' });
    }

    res.json(rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// Function to create a new student
const createStudent = async (req, res) => {
  const { fullname, course } = req.body;

  try {
    const [result] = await pool.query('INSERT INTO students (fullname, course) VALUES (?, ?)', [fullname, course]);

    res.status(201).json({ id: result.insertId, fullname, course });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// Function to update a student
const updateStudent = async (req, res) => {
  const { id } = req.params;
  const { fullname, course } = req.body;

  try {
    const [result] = await pool.query('UPDATE students SET fullname = ?, course = ? WHERE student_id = ?', [fullname, course, id]);

    if (result.affectedRows === 0) {
      return res.status(404).json({ error: 'Student not found' });
    }

    res.json({ message: 'Student updated successfully' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// Function to delete a student
const deleteStudent = async (req, res) => {
  const { id } = req.params;

  try {
    const [result] = await pool.query('DELETE FROM students WHERE student_id = ?', [id]);

    if (result.affectedRows === 0) {
      return res.status(404).json({ error: 'Student not found' });
    }

    res.json({ message: 'Student deleted successfully' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// Export the functions
module.exports = { getAllStudents, getStudentById, createStudent, updateStudent, deleteStudent };
