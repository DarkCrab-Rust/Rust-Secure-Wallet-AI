// Simplified helper: provide a relaxed sum_of_products implementation when the
// sop_patch_tests feature is enabled. Keep the implementation minimal and
// avoid heavy dependencies so it compiles reliably in tests.
#![allow(dead_code)]

use elliptic_curve::Group;

/// A relaxed sum-of-products implementation that requires Copy + Mul on the
/// group type. This is intentionally small and feature-gated via the
/// `sop_patch_tests` feature in the workspace.
pub fn sum_of_products_impl_relaxed<G>(pairs: &[(G::Scalar, G)]) -> G
where
    G: Group + Copy + core::ops::Mul<G::Scalar, Output = G>,
    G::Scalar: Copy,
{
    pairs.iter().copied().fold(G::identity(), |acc, (s, p)| acc + (p * s))
}

#[cfg(test)]
mod tests {
    use super::*;
    use k256::{ProjectivePoint as KPoint, Scalar as KScalar};

    #[test]
    fn sum_of_products_impl_with_k256() {
        let s1 = KScalar::from(2u64);
        let s2 = KScalar::from(3u64);
        let g = KPoint::GENERATOR;
        let pairs: Vec<(KScalar, KPoint)> = vec![(s1, g), (s2, g)];

        let res = sum_of_products_impl_relaxed(&pairs);
        let expected = g * KScalar::from(5u64);
        assert_eq!(res, expected);
    }

    #[test]
    fn sum_of_products_impl_empty_returns_identity_k256() {
        let pairs: Vec<(KScalar, KPoint)> = Vec::new();
        let res = sum_of_products_impl_relaxed(&pairs);
        assert_eq!(res, KPoint::IDENTITY);
    }
}
