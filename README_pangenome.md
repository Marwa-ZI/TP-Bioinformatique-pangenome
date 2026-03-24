# TP Bioinformatique — Pipeline Pan-Genome Bacterien

> Travaux pratiques d'analyse de la diversite genomique de souches bacteriennes via un pipeline complet d'assemblage, d'annotation et de comparaison pan-genomique, dans un environnement Docker Jupyter pre-configure.

**Auteur : Marwa Zidi** — Universite Paris Cite

---

## Acces a l'environnement

L'environnement de TP est disponible en ligne via l'infrastructure Docker de l'Universite Paris Cite :

**[Lancer l'environnement Jupyter](https://mydocker.universite-paris-saclay.fr/course/fae9b00f-b215-4ec7-a73f-aea88e8a0a4d/magic-link)**

> Aucune installation locale necessaire. Tous les outils et les donnees sont pre-integres dans l'image Docker.

---

## Description

Ce TP suit un pipeline complet en trois phases pour analyser la diversite genomique de souches bacteriennes :

- **Phase 1** — Controle qualite, nettoyage et assemblage des reads Illumina
- **Phase 2** — Identification MLST, annotation genomique et detection de metabolites secondaires
- **Phase 3** — Construction et visualisation du pan-genome

---

## Structure des notebooks

| Notebook | Description | Mode |
|----------|-------------|------|
| `Pipeline_Pangenome_ETUDIANTS.ipynb` | Commandes avec blancs a completer | Exercice |
| `Pipeline_Pangenome_CORRECTION.ipynb` | Toutes les reponses et explications | Correction |

---

## Pipeline d'analyse

```
Raw_Files/*.fastq.gz
      |
      | Phase 1.1 — FastQC       : controle qualite des reads bruts
      | Phase 1.2 — Trimmomatic  : nettoyage des adaptateurs et bases de mauvaise qualite
      | Phase 1.3 — SPAdes       : assemblage de novo en contigs
      | Phase 1.4 — QUAST        : evaluation de la qualite de l'assemblage
      v
results/03_assembly/*/contigs.fasta
      |
      | Phase 2.1 — pubMLST (web) : typage MLST (Sequence Type)
      | Phase 2.2 — Prokka        : annotation automatique du genome
      | Phase 2.3 — antiSMASH (web) : detection de clusters de metabolites secondaires
      v
results/04_annotation/*_prokka/*.gff
      |
      | Phase 3.1 — NCBI (web)   : telechargement de genomes de reference
      | Phase 3.2 — Roary        : calcul du pan-genome (core + accessoire)
      | Phase 3.3 — Phandango (web) : visualisation interactive
      v
results/05_pangenome/roary_output/
```

---

## Structure des donnees

```
/root/
├── data/
│   └── for-Pangenome/
│       ├── Raw_Files/          reads FASTQ bruts (R1/R2 par souche)
│       └── Inputs/             assemblages pre-calcules (contigs.fasta)
├── results/
│   ├── 01_quality_control/     rapports FastQC
│   ├── 02_trimmed/             reads nettoyes (Trimmomatic)
│   ├── 03_assembly/            assemblages SPAdes + rapports QUAST
│   ├── 04_annotation/          annotations Prokka (GFF, GBK, FAA...)
│   └── 05_pangenome/           resultats Roary + arbre + matrice
├── notebooks/                  notebooks Jupyter
└── scripts/
    ├── check_tools.sh          verification des outils installes
    ├── setup_prokka_db.sh      configuration de la base Prokka
    └── enrichr_shell.sh        analyse d'enrichissement (optionnel)
```

---

## Outils utilises

| Outil | Version | Role |
|-------|---------|------|
| FastQC | 0.12.1 | Controle qualite des reads bruts |
| Trimmomatic | derniere | Nettoyage des reads (adaptateurs, qualite) |
| SPAdes | derniere | Assemblage de novo (mode --careful) |
| QUAST | derniere | Evaluation de la qualite de l'assemblage |
| Prokka | derniere | Annotation automatique du genome bacterien |
| Roary | derniere | Calcul du pan-genome (core/accessoire) |
| pubMLST | web | Typage MLST en ligne |
| antiSMASH | web | Detection de metabolites secondaires |
| Phandango | web | Visualisation interactive du pan-genome |
| BLAST+ | derniere | Comparaison de sequences |
| Samtools | derniere | Manipulation de fichiers BAM/SAM |
| R (enrichR) | 4.x | Analyse d'enrichissement fonctionnel |

---

## Fichiers de sortie cles

| Fichier | Localisation | Description |
|---------|-------------|-------------|
| `report.html` | `03_assembly/*/SAMPLE_quast/` | Statistiques d'assemblage |
| `SAMPLE.gff` | `04_annotation/SAMPLE_prokka/` | Annotation — REQUIS pour Roary |
| `SAMPLE.gbk` | `04_annotation/SAMPLE_prokka/` | Format GenBank — pour antiSMASH |
| `summary_statistics.txt` | `05_pangenome/roary_output/` | Statistiques pan-genome |
| `gene_presence_absence.csv` | `05_pangenome/roary_output/` | Matrice core/accessoire |
| `*.newick` | `05_pangenome/roary_output/` | Arbre phylogenetique |

---

## Parametres Trimmomatic expliques

```bash
ILLUMINACLIP:NexteraPE-PE.fa:2:30:10   # Suppression des adaptateurs Nextera
LEADING:3                               # Supprimer bases de debut si qualite < 3
TRAILING:3                              # Supprimer bases de fin si qualite < 3
SLIDINGWINDOW:4:15                      # Fenetre glissante : 4 bases, qualite moyenne >= 15
MINLEN:36                               # Supprimer reads de moins de 36 pb
```

---

## Objectifs pedagogiques

A l'issue de ce TP, l'etudiant sera capable de :

- Evaluer et nettoyer des donnees de sequencage Illumina (FastQC, Trimmomatic)
- Assembler un genome bacterien de novo (SPAdes) et evaluer la qualite (QUAST)
- Annoter automatiquement un genome bacterien (Prokka)
- Typer une souche bacterienne par MLST (pubMLST)
- Detecter des clusters de metabolites secondaires (antiSMASH)
- Calculer un pan-genome avec Roary et interpreter les resultats (core vs accessoire)
- Visualiser la diversite genomique avec Phandango
- Utiliser des variables Bash dans un workflow bioinformatique

---

## Configuration post-demarrage

A lancer une seule fois dans le terminal Jupyter :

```bash
# Configurer la base de donnees Prokka
bash ~/setup_prokka_db.sh

# Verifier tous les outils
bash ~/check_tools.sh
```

---

## Ressources

- Prokka : https://github.com/tseemann/prokka
- Roary : https://sanger-pathogens.github.io/Roary/
- pubMLST : https://pubmlst.org/
- antiSMASH : https://antismash.secondarymetabolites.org/
- Phandango : https://jameshadfield.github.io/phandango/
- SPAdes : https://github.com/ablab/spades

---

## Licence

Ce materiel pedagogique est distribue a des fins educatives dans le cadre des enseignements de bioinformatique de l'Universite Paris Cite.
