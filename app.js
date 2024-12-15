const express = require('express');
const bodyParser = require('body-parser');

//Routes Here
const authRoutes = require('./routes/authRoutes');
const userRoutes = require('./routes/userRoutes');

const app = express();
app.use(bodyParser.json());
const cors = require('cors');
app.use(cors());

app.get('/', function(req, res){
    res.send("Justen SanGabriel, STUDENT");
});

// Endpoint Here
app.use('/api/auth', authRoutes);
app.use('/api/user', userRoutes);

const PORT = 5002;

app.listen(PORT, () => {
    console.log(`The server is working on port ${PORT}`);
});    
