const jwt = require('jsonwebtoken');

const authenticateToken = (req, res, next) => {

    const authHeader = req.headers.authorization;

    if (!authHeader) {
        return res.status(401).json({ error: 'Access denied' });
    }

    // ✅ Strip "Bearer " prefix before verifying
    const token = authHeader.startsWith('Bearer ')
        ? authHeader.slice(7)
        : authHeader;

    try {
        const verified = jwt.verify(token, process.env.JWT_SECRET);
        req.user = verified;
        next();
    } catch (err) {
        res.status(400).json({ error: 'Invalid token' });
    }
};

module.exports = authenticateToken;