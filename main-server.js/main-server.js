const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const http = require('http');
const { Server } = require('socket.io');
require('dotenv').config();

const { connectMongoDB } = require('./config/database');
const authRoutes = require('./routes/auth');
const portfolioRoutes = require('./routes/portfolio');
const tradeRoutes = require('./routes/trades');
const forecastRoutes = require('./routes/forecast');
const { initializeStockWebSocket } = require('./websocket/stockSocket');

const app = express();
const server = http.createServer(app);
const io = new Server(server, {
  cors: {
    origin: process.env.CLIENT_URL || 'http://localhost:3000',
    methods: ['GET', 'POST']
  }
});

// Middleware
app.use(helmet());
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Rate Limiting
const limiter = rateLimit({
  windowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS) || 900000,
  max: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS) || 100,
  message: 'Too many requests from this IP, please try again later.'
});
app.use('/api/', limiter);

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/portfolio', portfolioRoutes);
app.use('/api/trades', tradeRoutes);
app.use('/api/forecast', forecastRoutes);

// Health Check
app.get('/api/health', (req, res) => {
  res.status(200).json({ 
    status: 'OK', 
    message: 'Server is running',
    timestamp: new Date().toISOString()
  });
});

// Error Handler
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(err.status || 500).json({
    success: false,
    message: err.message || 'Internal Server Error',
    ...(process.env.NODE_ENV === 'development' && { stack: err.stack })
  });
});

// Initialize WebSocket for real-time stock updates
initializeStockWebSocket(io);

// Database Connection and Server Start
const PORT = process.env.PORT || 5000;
const WS_PORT = process.env.WS_PORT || 8080;

connectMongoDB().then(() => {
  server.listen(PORT, () => {
    console.log(`🚀 Server running on port ${PORT}`);
    console.log(`📡 WebSocket running on port ${WS_PORT}`);
    console.log(`🌍 Environment: ${process.env.NODE_ENV}`);
  });
});

// Graceful Shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM signal received: closing HTTP server');
  server.close(() => {
    console.log('HTTP server closed');
    process.exit(0);
  });
});
