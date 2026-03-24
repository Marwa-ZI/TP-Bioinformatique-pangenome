# ============================================================================
# Dockerfile pour environnement Pan-Génome avec Jupyter 
# AVEC DONNÉES INTÉGRÉES - Les étudiants ont les données immédiatement
# Auteur: Marwa ZIDI
# ============================================================================

FROM ubuntu:24.04

# Variables d'environnement
ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="/root/bin:/opt/conda/bin:$PATH"

# ============================================================================
# 1. INSTALLATION DES OUTILS DE BASE
# ============================================================================
RUN apt-get update && apt-get install -y \
    vim nano gawk tree htop build-essential curl wget git unzip procps ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# ============================================================================
# 2. INSTALLATION DES BIBLIOTHÈQUES SYSTÈME
# ============================================================================
RUN apt-get update && apt-get install -y \
    libncurses5-dev libbz2-dev liblzma-dev libcurl4-openssl-dev zlib1g-dev \
    autoconf automake pkg-config make gcc g++ libssl-dev libmysqlclient-dev \
    libxml2-dev libxml2 libfontconfig1-dev libharfbuzz-dev libfribidi-dev \
    libfreetype6-dev libpng-dev libtiff5-dev libjpeg-dev libdb5.3 \
    && rm -rf /var/lib/apt/lists/*

# ============================================================================
# 3. INSTALLATION DE PYTHON + JAVA + R VIA APT
# ============================================================================
RUN apt-get update && apt-get install -y \
    python3 python3-pip python3-dev python3-venv \
    default-jre default-jdk \
    r-base r-base-dev \
    fonts-dejavu fonts-liberation fontconfig ghostscript python3-pil python3-tk \
    && rm -rf /var/lib/apt/lists/*

# ============================================================================
# 4. INSTALLATION DES OUTILS BIOINFORMATIQUES VIA APT
# ============================================================================
RUN apt-get update && apt-get install -y \
    ncbi-blast+ samtools bwa fastqc trimmomatic spades prokka roary \
    && rm -rf /var/lib/apt/lists/*

# ============================================================================
# 5. INSTALLATION DE JUPYTERLAB ET PACKAGES PYTHON VIA PIP
# ============================================================================
RUN pip3 install --no-cache-dir --break-system-packages --ignore-installed \
    jupyterlab notebook ipykernel jupyter-resource-usage \
    bash_kernel numpy pandas scipy matplotlib seaborn \
    biopython pysam scikit-learn plotly cyvcf2 watermark quast

# ============================================================================
# 6. CONFIGURATION DU KERNEL BASH
# ============================================================================
RUN python3 -m bash_kernel.install

# ============================================================================
# 7. INSTALLATION DES PACKAGES R
# ============================================================================
RUN Rscript -e "install.packages(c('tidyverse', 'ggplot2', 'readr', 'dplyr', 'tidyr', 'stringr', 'httr', 'jsonlite', 'enrichR'), repos='https://cloud.r-project.org/', dependencies=TRUE, quiet=TRUE)" || true

# ============================================================================
# 8. CONFIGURATION DU WRAPPER TRIMMOMATIC
# ============================================================================
RUN mkdir -p /root/bin && \
    TRIMMOMATIC_JAR=$(find /usr/share -name "trimmomatic*.jar" 2>/dev/null | head -1) && \
    printf '#!/bin/bash\njava -jar %s "$@"\n' "$TRIMMOMATIC_JAR" > /root/bin/trimmomatic && \
    chmod +x /root/bin/trimmomatic

# ============================================================================
# 9. TÉLÉCHARGEMENT ET EXTRACTION DES DONNÉES (INTÉGRÉ DANS L'IMAGE)
# ============================================================================
RUN mkdir -p /root/data && cd /root/data && \
    wget -q "https://filesender.renater.fr/download.php?token=e84f9703-7720-4410-897c-10472a0a7035&files_ids=68275677" -O data.tar && \
    tar -xf data.tar && rm data.tar && \
    echo "✅ Données extraites dans /root/data"

# ============================================================================
# 10. CRÉATION DES SCRIPTS - setup_prokka_db.sh
# ============================================================================
RUN printf '%s\n' \
    '#!/bin/bash' \
    'echo "=========================================="' \
    'echo "  CONFIGURATION PROKKA DATABASE"' \
    'echo "=========================================="' \
    'echo ""' \
    'if command -v prokka &>/dev/null; then' \
    '    echo "Configuration en cours..."' \
    '    prokka --setupdb' \
    '    [ $? -eq 0 ] && echo "✅ Prokka DB configurée" || echo "❌ Erreur"' \
    '    prokka --listdb 2>/dev/null || true' \
    'else' \
    '    echo "❌ Prokka non installé"' \
    'fi' \
    > /root/setup_prokka_db.sh && chmod +x /root/setup_prokka_db.sh

# ============================================================================
# 11. CRÉATION DES SCRIPTS - check_tools.sh
# ============================================================================
RUN printf '%s\n' \
    '#!/bin/bash' \
    'echo "=========================================="' \
    'echo "  VÉRIFICATION DES OUTILS"' \
    'echo "=========================================="' \
    'echo ""' \
    'for tool in fastqc trimmomatic spades.py quast.py prokka roary samtools bwa blastn R jupyter python3; do' \
    '    command -v $tool >/dev/null 2>&1 && echo "✅ $tool" || echo "❌ $tool"' \
    'done' \
    'echo ""' \
    > /root/check_tools.sh && chmod +x /root/check_tools.sh

# ============================================================================
# 12. CRÉATION DES SCRIPTS - enrichr_shell.sh
# ============================================================================
RUN printf '%s\n' \
    '#!/bin/bash' \
    'GENE_FILE=""' \
    'OUTPUT_DIR="enrichr_results"' \
    'DATABASE="GO_Biological_Process_2021"' \
    '' \
    'while getopts "f:o:d:" opt; do' \
    '  case $opt in' \
    '    f) GENE_FILE="$OPTARG" ;;' \
    '    o) OUTPUT_DIR="$OPTARG" ;;' \
    '    d) DATABASE="$OPTARG" ;;' \
    '  esac' \
    'done' \
    '' \
    '[ -z "$GENE_FILE" ] && { echo "Usage: enrichr_shell.sh -f genes.txt [-o output_dir] [-d database]"; exit 1; }' \
    '' \
    'mkdir -p "$OUTPUT_DIR"' \
    'Rscript -e "library(enrichR); genes<-readLines('"'"'${GENE_FILE}'"'"'); enriched<-enrichr(genes,c('"'"'${DATABASE}'"'"')); write.csv(enriched[[1]],'"'"'${OUTPUT_DIR}/enrichr_results.csv'"'"',row.names=FALSE)"' \
    'echo "✅ Résultats dans ${OUTPUT_DIR}/enrichr_results.csv"' \
    > /root/enrichr_shell.sh && chmod +x /root/enrichr_shell.sh

# ============================================================================
# 13. CRÉATION DES RÉPERTOIRES DE TRAVAIL
# ============================================================================
RUN mkdir -p /root/notebooks /root/results /root/blast_db

# ============================================================================
# 14. COPIE DU SCRIPT WRAPPER
# ============================================================================
COPY wrapper_script.sh /usr/local/lib/wrapper_script.sh
RUN chmod +x /usr/local/lib/wrapper_script.sh

# ============================================================================
# 15. CONFIGURATION FINALE
# ============================================================================
WORKDIR /root
EXPOSE 8888

ENTRYPOINT ["/bin/bash", "/usr/local/lib/wrapper_script.sh"]
