-- Pet Commute local SQLite schema.
-- Stores pet saves, micro commute runs, and leaderboard entries.

PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS pet_saves (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    pet_name TEXT NOT NULL,
    commute_length_seconds INTEGER NOT NULL DEFAULT 8 CHECK (commute_length_seconds > 0),
    monthly_goal_runs INTEGER NOT NULL DEFAULT 30 CHECK (monthly_goal_runs > 0),
    mood REAL NOT NULL DEFAULT 0.7 CHECK (mood >= 0.0 AND mood <= 1.0),
    energy REAL NOT NULL DEFAULT 1.0 CHECK (energy >= 0.0 AND energy <= 1.0),
    month_start_date TEXT NOT NULL,
    month_end_date TEXT NOT NULL,
    current_month_index INTEGER NOT NULL DEFAULT 0 CHECK (current_month_index >= 0),
    total_runs INTEGER NOT NULL DEFAULT 0 CHECK (total_runs >= 0),
    best_streak INTEGER NOT NULL DEFAULT 0 CHECK (best_streak >= 0),
    settings_json TEXT NOT NULL DEFAULT '{}',
    created_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
    updated_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now'))
);

CREATE TABLE IF NOT EXISTS micro_commute_runs (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    pet_save_id INTEGER NOT NULL REFERENCES pet_saves(id) ON DELETE CASCADE,
    run_date TEXT NOT NULL,
    started_at TEXT NOT NULL,
    finished_at TEXT,
    duration_seconds REAL NOT NULL DEFAULT 0 CHECK (duration_seconds >= 0),
    distance_meters REAL NOT NULL DEFAULT 0 CHECK (distance_meters >= 0),
    success INTEGER NOT NULL DEFAULT 0 CHECK (success IN (0, 1)),
    score INTEGER NOT NULL DEFAULT 0 CHECK (score >= 0),
    mood_delta REAL NOT NULL DEFAULT 0,
    energy_delta REAL NOT NULL DEFAULT 0,
    share_code TEXT,
    created_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now'))
);

CREATE TABLE IF NOT EXISTS leaderboard_entries (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    pet_save_id INTEGER REFERENCES pet_saves(id) ON DELETE SET NULL,
    pet_name TEXT NOT NULL,
    month_start_date TEXT NOT NULL,
    total_runs INTEGER NOT NULL DEFAULT 0 CHECK (total_runs >= 0),
    best_streak INTEGER NOT NULL DEFAULT 0 CHECK (best_streak >= 0),
    total_score INTEGER NOT NULL DEFAULT 0 CHECK (total_score >= 0),
    last_run_at TEXT,
    is_friend INTEGER NOT NULL DEFAULT 0 CHECK (is_friend IN (0, 1)),
    source TEXT NOT NULL DEFAULT 'local',
    share_code TEXT,
    created_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
    updated_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now'))
);

CREATE TABLE IF NOT EXISTS share_codes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    code TEXT NOT NULL UNIQUE,
    kind TEXT NOT NULL DEFAULT 'friend',
    pet_name TEXT,
    payload_json TEXT NOT NULL DEFAULT '{}',
    imported_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now'))
);

CREATE INDEX IF NOT EXISTS idx_pet_saves_month ON pet_saves(month_start_date);
CREATE INDEX IF NOT EXISTS idx_runs_pet_date ON micro_commute_runs(pet_save_id, run_date);
CREATE INDEX IF NOT EXISTS idx_runs_share_code ON micro_commute_runs(share_code);
CREATE INDEX IF NOT EXISTS idx_leaderboard_month_score ON leaderboard_entries(month_start_date, total_score DESC);
CREATE INDEX IF NOT EXISTS idx_share_codes_code ON share_codes(code);
