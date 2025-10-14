//! Local patch for elliptic curve tools
//!
//! This is a placeholder implementation to satisfy the patch dependency.

pub mod serdes;

#[cfg(feature = "sop_patch_tests")]
pub mod sop;

#[cfg(feature = "sop_patch_tests")]
pub use sop::sum_of_products_impl_relaxed;

/// Placeholder function
pub fn placeholder() -> bool {
    true
}

#[cfg(feature = "sop_patch_tests")]
pub mod tests {
    /// Placeholder test function
    pub fn test_placeholder() -> bool {
        true
    }
}
