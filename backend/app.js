const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');

// Routes
const authRoutes = require('./routes/authRoutes');
const userRoutes = require('./routes/userRoutes');

const app = express();
app.use(cors());
app.use(bodyParser.json());

app.get('/', function(req, res) {
    res.send("Justen SanGabriel, STUDENT");
});

// Endpoints
app.use('/api/auth', authRoutes);
app.use('/api/user', userRoutes);

// ✅ Export for Vercel serverless (do NOT use app.listen)
module.exports = app;