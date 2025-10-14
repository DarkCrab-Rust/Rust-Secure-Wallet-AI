//! Local patch for elliptic curve tools
//!
//! This is a placeholder implementation to satisfy the patch dependency.

pub mod serdes;

// removed unused import

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

// Expose the sop helper when requested so external tests can import it as
// `elliptic_curve_tools::sum_of_products_impl_relaxed`.
#[cfg(any(feature = "sop_patch_tests", test))]
pub mod sop;

#[cfg(any(feature = "sop_patch_tests", test))]
pub use crate::sop::sum_of_products_impl_relaxed;
