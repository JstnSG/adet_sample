const express = require('express');
const pool = require('../config/database');

const app = express();

// Middleware for parsing JSON request bodies
app.use(express.json());

// Function to get all courses
const getAllCourses = async (req, res) => {
  try {
    const [rows] = await pool.query('SELECT course_id, name, description, created_at, updated_at FROM courses');
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// Function to get a course by ID
const getCourseById = async (req, res) => {
  const { id } = req.params;

  try {
    const [rows] = await pool.query('SELECT course_id, name, description, created_at, updated_at FROM courses WHERE course_id = ?', [id]);

    if (rows.length === 0) {
      return res.status(404).json({ error: 'Course not found' });
    }

    res.json(rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// Function to create a new course
const createCourse = async (req, res) => {
  const { name, description } = req.body;

  try {
    const [result] = await pool.query('INSERT INTO courses (name, description) VALUES (?, ?)', [name, description]);

    res.status(201).json({ id: result.insertId, name, description });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// Function to update a course
const updateCourse = async (req, res) => {
  const { id } = req.params;
  const { name, description } = req.body;

  try {
    const [result] = await pool.query('UPDATE courses SET name = ?, description = ? WHERE course_id = ?', [name, description, id]);

    if (result.affectedRows === 0) {
      return res.status(404).json({ error: 'Course not found' });
    }

    res.json({ message: 'Course updated successfully' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// Function to delete a course
const deleteCourse = async (req, res) => {
  const { id } = req.params;

  try {
    const [result] = await pool.query('DELETE FROM courses WHERE course_id = ?', [id]);

    if (result.affectedRows === 0) {
      return res.status(404).json({ error: 'Course not found' });
    }

    res.json({ message: 'Course deleted successfully' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// Export the functions
module.exports = { getAllCourses, getCourseById, createCourse, updateCourse, deleteCourse };
