-- Users Table
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Portfolios Table
CREATE TABLE portfolios (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(255) DEFAULT 'My Portfolio',
    total_invested DECIMAL(20, 2) DEFAULT 0,
    current_value DECIMAL(20, 2) DEFAULT 0,
    unrealized_pnl DECIMAL(20, 2) DEFAULT 0,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Holdings Table
CREATE TABLE holdings (
    id SERIAL PRIMARY KEY,
    portfolio_id INTEGER REFERENCES portfolios(id) ON DELETE CASCADE,
    ticker VARCHAR(20) NOT NULL,
    quantity DECIMAL(20, 5) NOT NULL CHECK (quantity >= 0),
    avg_price DECIMAL(20, 2) NOT NULL CHECK (avg_price >= 0),
    current_price DECIMAL(20, 2) DEFAULT 0,
    sector VARCHAR(100),
    exchange VARCHAR(20) DEFAULT 'NSE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(portfolio_id, ticker)
);

-- Trades Table
CREATE TABLE trades (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    portfolio_id INTEGER REFERENCES portfolios(id) ON DELETE CASCADE,
    ticker VARCHAR(20) NOT NULL,
    type VARCHAR(10) CHECK (type IN ('BUY', 'SELL')),
    quantity DECIMAL(20, 5) NOT NULL CHECK (quantity > 0),
    price DECIMAL(20, 2) NOT NULL CHECK (price >= 0),
    commission DECIMAL(10, 2) DEFAULT 0,
    trade_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    realized_pnl DECIMAL(20, 2) DEFAULT 0,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Expert Notes Table
CREATE TABLE expert_notes (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    ticker VARCHAR(20) NOT NULL,
    view VARCHAR(20) CHECK (view IN ('BULLISH', 'BEARISH', 'NEUTRAL')),
    target_price DECIMAL(20, 2),
    stop_loss DECIMAL(20, 2),
    thesis TEXT NOT NULL,
    catalysts TEXT[],
    risks TEXT[],
    tags TEXT[],
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Stock Prices Cache (for real-time data)
CREATE TABLE stock_prices_cache (
    ticker VARCHAR(20) PRIMARY KEY,
    current_price DECIMAL(20, 2) NOT NULL,
    change_percent DECIMAL(10, 4),
    volume BIGINT,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for performance
CREATE INDEX idx_holdings_portfolio ON holdings(portfolio_id);
CREATE INDEX idx_trades_user ON trades(user_id);
CREATE INDEX idx_trades_portfolio ON trades(portfolio_id);
CREATE INDEX idx_expert_notes_user ON expert_notes(user_id);
CREATE INDEX idx_stock_prices_ticker ON stock_prices_cache(ticker);
