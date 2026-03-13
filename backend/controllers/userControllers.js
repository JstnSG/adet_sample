const pool = require('../config/database');
const bcrypt = require('bcryptjs');

const getAllUsers = async (req, res) => {
    try {
        const [rows] = await pool.query('SELECT user_id, fullname, username, created_at, updated_at FROM users');
        res.json(rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

const getUserById = async (req, res) => {
    const { id } = req.params;
    try {
        const [rows] = await pool.query(
            'SELECT user_id, fullname, username, created_at, updated_at FROM users WHERE user_id = ?', [id]
        );
        if (rows.length === 0) return res.status(404).json({ error: 'User not found' });
        res.json(rows[0]);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

const createUser = async (req, res) => {
    const { fullname, username, password } = req.body;

    // ✅ Validate required fields
    if (!fullname || !username || !password) {
        return res.status(400).json({ error: 'fullname, username, and password are required' });
    }

    try {
        const hashedPassword = await bcrypt.hash(password, 10);
        const [result] = await pool.query(
            'INSERT INTO users (fullname, username, password) VALUES (?, ?, ?)',
            [fullname, username, hashedPassword]
        );
        // ✅ Return user_id (not id) so Flutter UserModel.fromJson works
        res.status(201).json({ user_id: result.insertId, fullname, username });
    } catch (err) {
        // ✅ Handle duplicate username
        if (err.code === 'ER_DUP_ENTRY') {
            return res.status(400).json({ error: 'Username already exists' });
        }
        res.status(500).json({ error: err.message });
    }
};

const updateUser = async (req, res) => {
    const { id } = req.params;
    const { fullname, username, password } = req.body;

    // ✅ Validate required fields
    if (!fullname || !username || !password) {
        return res.status(400).json({ error: 'fullname, username, and password are required' });
    }

    try {
        const hashedPassword = await bcrypt.hash(password, 10);
        const [result] = await pool.query(
            'UPDATE users SET fullname = ?, username = ?, password = ? WHERE user_id = ?',
            [fullname, username, hashedPassword, id]
        );
        if (result.affectedRows === 0) return res.status(404).json({ error: 'User not found' });
        // ✅ Return updated user
        res.json({ user_id: parseInt(id), fullname, username });
    } catch (err) {
        if (err.code === 'ER_DUP_ENTRY') {
            return res.status(400).json({ error: 'Username already exists' });
        }
        res.status(500).json({ error: err.message });
    }
};

const deleteUser = async (req, res) => {
    const { id } = req.params;
    try {
        const [result] = await pool.query('DELETE FROM users WHERE user_id = ?', [id]);
        if (result.affectedRows === 0) return res.status(404).json({ error: 'User not found' });
        res.json({ message: 'User deleted successfully' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

module.exports = { getAllUsers, getUserById, createUser, updateUser, deleteUser };