use std::{env, sync::LazyLock};

pub mod credentials;
pub mod crypto;
pub mod dids;

pub mod errors;
pub mod json;
pub mod rfc3339;

#[cfg(test)]
mod test_helpers;
#[cfg(test)]
mod test_vectors;

pub const GIT_COMMIT_HASH: &str = include_str!("resources/git_sha.txt");

// TODO: https://github.com/TBD54566975/web5-rs/issues/287
#[allow(dead_code)]
static LOG_LEVEL: LazyLock<Option<String>> = LazyLock::new(|| env::var("WEB5_SDK_LOG_LEVEL").ok());

pub(crate) mod logging {
    #[macro_export]
    macro_rules! log_dbg {
        ($msg:literal $(, $arg:tt)*) => {
            if let Some(ref level) = *$crate::LOG_LEVEL {
                if level.to_lowercase() == "debug" {
                   println!("[DEBUG] {}: {}", $crate::GIT_COMMIT_HASH, format!($msg, $($arg)*));
                }
            }
        };
        ($closure:expr) => {
            if let Some(ref level) = *$crate::LOG_LEVEL {
                if level.to_lowercase() == "debug" {
                    let msg = $closure();
                    println!("[DEBUG] {}: {}", $crate::GIT_COMMIT_HASH, msg);
                }
            }
        };
    }
}

#[cfg(test)]
mod test {
    use crate::log_dbg;

    #[test]
    fn can_log_dbg() {
        log_dbg!("Log debugging without arguments");
        log_dbg!("Log debugging with arguments {}", "Some value");
        log_dbg!(|| { 2 + 2 });
    }
}
