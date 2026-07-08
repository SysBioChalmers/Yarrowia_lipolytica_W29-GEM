"""Curations for release version 4.2.0 — reproduce iYali4_corr on the 4.1.2 backbone.

iYali4_corr (Xu, Holic, Hua 2020, Biotechnol Bioprocess Eng 25:53-61) is iYali 4.0.0
plus a small, undocumented correction layer. This script applies that layer -- and only
the parts of it that are still applicable -- on top of the iYali 4.1.2 release.

The Xu layer, established by an ID-matched diff of iYali4_corr against iYali 4.0.0
(both retain the original bare-numeric reaction IDs), is exactly:

    74 bound / reversibility changes
     4 stoichiometry changes  (235, 718, 3312g, xBIOMASS)
     2 reactions added        (newBiom, biomass_C -- alternative biomass equations)
     1 reaction renamed       ("Biomass production" -> "xBIOMASS")
     0 GPR changes
     0 reaction removals

4.0.0 reaction N maps to 4.1.2 reaction ``y0{N:05d}`` (verified by reaction name for
every reaction touched below).

Triage (see docs/HANDOFF.md section 4; buckets sum to the 81 source modifications):

    B3 applied     64 = 62 bounds + rxn 235 + xBIOMASS
    B1 convergent   7 = 5 bounds already at Xu's value + rxn 718 + rxn 3312g
    B2 orphaned     6 = bounds on reactions dropped in the 4.1.0 rebuild
    excluded        4 = glucose exchange (medium constraint), newBiom, biomass_C, rename

Run from anywhere inside the repository:  python code/curation/v4_2_0.py
"""

from __future__ import annotations

import subprocess
import sys
import tempfile
import warnings
from pathlib import Path

import cobra

warnings.filterwarnings("ignore")

BASE_TAG = "4.1.2"
RELEASE = "4.2.0"
SOURCE_MODEL = "iYali4_corr"
# The Xu et al. 2020 DOI could not be verified from a primary source; do not invent one.
SOURCE_DOI = "UNVERIFIED:Biotechnol_Bioprocess_Eng_25:53-61"

# --- the 62 applicable bound changes (bucket B3) -----------------------------------
# Xu made these irreversible. All 30 are still [-1000, 1000] in 4.1.2.
# 27 fatty-acid--CoA ligases (ATP -> AMP + PPi driven, effectively irreversible)
# + 1-pyrroline-5-carboxylate DH, L-1-pyrroline-3-hydroxy-5-carboxylate DH, NAD synthase.
MADE_IRREVERSIBLE = (
    ["y000012", "y000399", "y000400", "y000402", "y000410", "y000412", "y000672", "y000769"]
    + [f"y00{n}" for n in range(2194, 2206)]
    + [f"y00{n}" for n in range(2209, 2219)]
)

# Xu made these reversible. Nucleotide kinases and other near-equilibrium reactions.
MADE_REVERSIBLE = (
    ["y000057", "y000148", "y000149", "y000163", "y000165", "y000363", "y000443", "y000528"]
    + [f"y000{n}" for n in range(795, 802)]
    + ["y000811", "y000908", "y001022", "y001072", "y001073", "y001079", "y001080", "y001703"]
    + [f"y00{n}" for n in range(2266, 2271)]
)

# Xu blocked these outright.
BLOCKED = ["y000175", "y000320", "y000321", "y001010"]

GAM = 86.7881  # unchanged by Xu; only the H2O/H+ of ATP hydrolysis were missing


def load_base() -> cobra.Model:
    """Load the iYali 4.1.2 release model straight from its git tag."""
    root = subprocess.run(
        ["git", "rev-parse", "--show-toplevel"], capture_output=True, text=True, check=True
    ).stdout.strip()
    blob = subprocess.run(
        ["git", "-C", root, "show", f"{BASE_TAG}:model/iYali.xml"],
        capture_output=True, check=True,
    ).stdout
    with tempfile.NamedTemporaryFile("wb", suffix=".xml", delete=False) as fh:
        fh.write(blob)
        path = fh.name
    return cobra.io.read_sbml_model(path), Path(root)


def free_atp(model: cobra.Model) -> float:
    """Max ATP hydrolysis with every uptake closed. Must be 0 (no energy from nothing)."""
    with model:
        for rxn in model.boundary:
            # set both at once: y001714 is pinned at (-1, -1), so assigning lb first
            # would transiently violate lb <= ub (see docs/TOOLING.md section 5).
            rxn.bounds = (0.0, 1000.0)
        model.objective = "xMAINTENANCE"
        return abs(model.slim_optimize() or 0.0)


def imbalanced(model: cobra.Model) -> tuple[int, int]:
    """Count mass- and charge-unbalanced reactions, ignoring boundary + pseudo-reactions."""
    skip = {r.id for r in model.boundary} | {
        r.id for r in model.reactions if r.id.startswith("x")
    }
    mass = charge = 0
    for rxn in model.reactions:
        if rxn.id in skip:
            continue
        try:
            bal = rxn.check_mass_balance()
        except ValueError:
            # a participating metabolite carries no formula -> not checkable.
            # Skipped identically before and after, so the comparison stays valid.
            continue
        if not bal:
            continue
        if any(k != "charge" for k in bal):
            mass += 1
        if "charge" in bal:
            charge += 1
    return mass, charge


def main() -> int:
    model, root = load_base()
    log: list[tuple[str, str, str, str]] = []  # rxnID, changeType, evidenceStrength, bucket

    before_growth = model.slim_optimize()
    before_mass, before_charge = imbalanced(model)
    before_atp = free_atp(model)

    # --- 1. reversibility / bound corrections (62) ---------------------------------
    for rid in MADE_IRREVERSIBLE:
        model.reactions.get_by_id(rid).bounds = (0.0, 1000.0)
        log.append((rid, "reversibility", "medium", "applied"))
    for rid in MADE_REVERSIBLE:
        model.reactions.get_by_id(rid).bounds = (-1000.0, 1000.0)
        log.append((rid, "reversibility", "medium", "applied"))
    for rid in BLOCKED:
        model.reactions.get_by_id(rid).bounds = (0.0, 0.0)
        log.append((rid, "bounds", "weak", "applied"))

    # --- 2. rxn 235: Xu swapped the cofactor NAD -> NADP ---------------------------
    # NOTE: undocumented, and contrary to the NAD+-dependence of ERG26. Applied for
    # faithfulness to iYali4_corr; evidence strength is weak. Revisit at 5.x.
    r235 = model.reactions.get_by_id("y000235")
    r235.subtract_metabolites(
        {model.metabolites.s_1198: -1.0, model.metabolites.s_1203: 1.0}  # NAD, NADH out
    )
    r235.add_metabolites(
        {model.metabolites.s_1207: -1.0, model.metabolites.s_1212: 1.0}  # NADP(+), NADPH in
    )
    log.append(("y000235", "add", "weak", "applied"))

    # --- 3. xBIOMASS: Xu balanced the GAM term (ATP + H2O -> ADP + Pi + H+) --------
    # GAM itself is unchanged (86.7881); 4.0.0/4.1.2 simply omitted the water and proton.
    bio = model.reactions.get_by_id("xBIOMASS")
    bio.add_metabolites({model.metabolites.s_0803: -GAM, model.metabolites.s_0794: +GAM})
    log.append(("xBIOMASS", "biomass", "strong", "applied"))

    # --- validation ----------------------------------------------------------------
    model.objective = "xBIOMASS"
    after_growth = model.slim_optimize()
    after_mass, after_charge = imbalanced(model)
    after_atp = free_atp(model)

    print(f"reactions/metabolites/genes : {len(model.reactions)}/"
          f"{len(model.metabolites)}/{len(model.genes)}")
    print(f"growth      : {before_growth:.6f} -> {after_growth:.6f}")
    print(f"free ATP    : {before_atp:.6f} -> {after_atp:.6f}   (must stay 0)")
    print(f"mass unbal. : {before_mass} -> {after_mass}   (must not increase)")
    print(f"charge unbal: {before_charge} -> {after_charge}   (must not increase)")
    print(f"curations applied: {len(log)}")

    assert after_growth is not None and after_growth > 1e-6, "model must grow"
    assert after_atp < 1e-6, "energy generated from nothing"
    assert after_mass <= before_mass, "mass balance worsened"
    assert after_charge <= before_charge, "charge balance worsened"

    # --- write model files + curation log -------------------------------------------
    from raven_toolbox.io import export_for_git

    export_for_git(model, root / "model", prefix="iYali",
                   formats=("txt", "xml", "yml"), sub_dirs=False)

    logfile = root / "data" / "curationLog.tsv"
    logfile.parent.mkdir(parents=True, exist_ok=True)
    new = not logfile.exists()
    with logfile.open("a", encoding="utf-8", newline="\n") as fh:
        if new:
            fh.write("rxnID\tchangeType\tsourceModel\tsourceDOI\tevidenceType\t"
                     "evidenceStrength\treleaseVersion\tbucket\n")
        for rid, ctype, strength, bucket in log:
            fh.write(f"{rid}\t{ctype}\t{SOURCE_MODEL}\t{SOURCE_DOI}\tliterature\t"
                     f"{strength}\t{RELEASE}\t{bucket}\n")
    print(f"wrote {logfile.relative_to(root)} ({len(log)} rows)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
