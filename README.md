# pca-pump-ec-artifacts

This is a repository with source codes and experiments for the ICLP'24 paper "Early Validation of High-level System Requirements
with Event Calculus and Answer Set Programming" by Vasicek O., Arias J., Fiedor J., Gupta G., Hall B., Krena B., Larson B.,
Varanasi S. Ch., and Vojnar T.

## Directory Structure
- `ec_theory/bec_scasp-pca_pump.pl`            - Our implementation of BEC axioms
- `model_sources/*`                            - Source files of the PCA pump model
- `narratives_and_queries/*`                   - Narratives and queries for all experiments presented in the paper.
                                                 Also includes a makefile and supporting scripts.
- `narratives_and_queries/archived-test-run/*` - Output of measuring all experiments on a 2.67GHz Xeon CPU using `test.sh`
- `model_utils/*`                              - Utility predicates
- `model-*`                                    - Different version of the PCA pump model. Differences are use of cache
                                                 and version of or lack of overdose protection measures.

## How To
- Use the `makefile` in `narratives_and_queries/` to run individual experiments (or to see how to run them manually)
- See the paper and the PCA pump specification for context.
