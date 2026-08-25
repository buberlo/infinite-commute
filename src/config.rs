use bevy::prelude::*;
use serde::de::DeserializeOwned;
use serde::Deserialize;
use std::path::Path;
use std::time::Duration;

#[derive(Debug, Clone, PartialEq, Eq, Deserialize)]
#[serde(deny_unknown_fields)]
struct Defaults {
    pet_name: String,
    commute_seconds: u32,
    monthly_goal_runs: u32,
}

#[derive(Debug, Clone, PartialEq, Eq, Deserialize)]
#[serde(deny_unknown_fields)]
struct Overrides {
    pet_name: Option<String>,
    commute_seconds: Option<u32>,
    monthly_goal_runs: Option<u32>,
}

#[derive(Debug, Clone, PartialEq, Eq, Resource)]
pub struct GameConfig {
    pub pet_name: String,
    pub commute_seconds: u32,
    pub monthly_goal_runs: u32,
    pub month_days: u32,
}

impl GameConfig {
    pub const MONTH_DAYS: u32 = 30;
    pub const MAX_COMMUTE_SECONDS: u32 = 10;

    pub fn load() -> Self {
        let defaults = read_json::<Defaults>("assets/default.json").unwrap_or(Defaults {
            pet_name: "Pixel".into(),
            commute_seconds: 5,
            monthly_goal_runs: 20,
        });

        let mut config = Self {
            pet_name: sanitize_name(&defaults.pet_name),
            commute_seconds: defaults.commute_seconds.clamp(1, Self::MAX_COMMUTE_SECONDS),
            monthly_goal_runs: defaults.monthly_goal_runs.clamp(1, 365),
            month_days: Self::MONTH_DAYS,
        };

        if let Some(overrides) = read_json::<Overrides>("user.json") {
            if let Some(name) = overrides.pet_name {
                config.pet_name = sanitize_name(&name);
            }
            if let Some(seconds) = overrides.commute_seconds {
                config.commute_seconds = seconds.clamp(1, Self::MAX_COMMUTE_SECONDS);
            }
            if let Some(goal) = overrides.monthly_goal_runs {
                config.monthly_goal_runs = goal.clamp(1, 365);
            }
        }

        config
    }

    pub fn commute_duration(&self) -> Duration {
        Duration::from_secs(self.commute_seconds)
    }
}

fn sanitize_name(raw: &str) -> String {
    let trimmed = raw.trim();
    if trimmed.is_empty() {
        "Pixel".into()
    } else {
        trimmed.chars().take(16).collect()
    }
}

fn read_json<T: DeserializeOwned>(path: impl AsRef<Path>) -> Option<T> {
    let text = std::fs::read_to_string(path).ok()?;
    serde_json::from_str(&text).ok()
}
