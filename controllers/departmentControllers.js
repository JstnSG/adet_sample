const express = require('express');
const pool = require('../config/database');

const app = express();

// Middleware for parsing JSON request bodies
app.use(express.json());

// Function to get all departments
const getAllDepartments = async (req, res) => {
  try {
    const [rows] = await pool.query('SELECT department_id, department_name, created_at, updated_at FROM departments');
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// Function to get a department by ID
const getDepartmentById = async (req, res) => {
  const { id } = req.params;

  try {
    const [rows] = await pool.query('SELECT department_id, department_name, created_at, updated_at FROM departments WHERE department_id = ?', [id]);

    if (rows.length === 0) {
      return res.status(404).json({ error: 'Department not found' });
    }

    res.json(rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// Function to create a new department
const createDepartment = async (req, res) => {
  const { department_name } = req.body;

  try {
    const [result] = await pool.query('INSERT INTO departments (department_name) VALUES (?)', [department_name]);

    res.status(201).json({ id: result.insertId, department_name });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// Function to update a department
const updateDepartment = async (req, res) => {
  const { id } = req.params;
  const { department_name } = req.body;

  try {
    const [result] = await pool.query('UPDATE departments SET department_name = ? WHERE department_id = ?', [department_name, id]);

    if (result.affectedRows === 0) {
      return res.status(404).json({ error: 'Department not found' });
    }

    res.json({ message: 'Department updated successfully' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// Function to delete a department
const deleteDepartment = async (req, res) => {
  const { id } = req.params;

  try {
    const [result] = await pool.query('DELETE FROM departments WHERE department_id = ?', [id]);

    if (result.affectedRows === 0) {
      return res.status(404).json({ error: 'Department not found' });
    }

    res.json({ message: 'Department deleted successfully' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// Export the functions
module.exports = { getAllDepartments, getDepartmentById, createDepartment, updateDepartment, deleteDepartment };
