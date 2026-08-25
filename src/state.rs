use bevy::prelude::*;

/// Top-level game states for the one-month pet commute game.
///
/// The app boots into [`GameState::Onboarding`] so a new player can start a
/// micro commute run in under ten seconds without configuration.
#[derive(Debug, Clone