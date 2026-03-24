#!/bin/bash
# ============================================================================
# Wrapper script - Environnement Pan-Génome
# ============================================================================

USER=$1
PASSWORD=$2

echo "=========================================="
echo "DEBUT DU SCRIPT - $(date)"
echo "=========================================="

set -e

# ============================================================================
# CONFIGURATION ENVIRONNEMENT
# ============================================================================

echo "🔧 Configuration de l'environnement..."

# Ajouter ~/bin au PATH pour Trimmomatic
export PATH="$HOME/bin:$PATH"

# Source conda
source /opt/conda/etc/profile.d/conda.sh 2>/dev/null || true

echo ""
echo "📦 Outils pan-génome disponibles:"
command -v fastqc >/dev/null 2>&1 && echo "  ✅ FastQC" || echo "  ⚠️  FastQC"
command -v trimmomatic >/dev/null 2>&1 && echo "  ✅ Trimmomatic" || echo "  ⚠️  Trimmomatic"
command -v spades.py >/dev/null 2>&1 && echo "  ✅ SPAdes" || echo "  ⚠️  SPAdes"
command -v quast.py >/dev/null 2>&1 && echo "  ✅ QUAST" || echo "  ⚠️  QUAST"
command -v prokka >/dev/null 2>&1 && echo "  ✅ Prokka" || echo "  ⚠️  Prokka"
command -v roary >/dev/null 2>&1 && echo "  ✅ Roary" || echo "  ⚠️  Roary"
command -v samtools >/dev/null 2>&1 && echo "  ✅ Samtools" || echo "  ⚠️  Samtools"
command -v mlst >/dev/null 2>&1 && echo "  ✅ MLST" || echo "  ⚠️  MLST"
echo ""

# ============================================================================
# MESSAGE D'ACCUEIL
# ============================================================================

echo "=========================================="
echo "  🧬 ENVIRONNEMENT PAN-GÉNOME PRÊT"
echo "=========================================="
echo ""
echo "📝 Configuration post-démarrage:"
echo "  1. Prokka DB: bash ~/setup_prokka_db.sh"
echo "  2. BLAST DB (optionnel): bash ~/setup_blast_db.sh"
echo "  3. Vérifier outils: bash ~/check_tools.sh"
echo ""
echo "📚 Workflow pan-génome:"
echo "  FastQC → Trimmomatic → SPAdes → QUAST"
echo "  → BWA/Samtools → BLAST/MLST → Prokka → Roary"
echo ""
echo "🚀 Jupyter Lab démarre sur le port 8888..."
echo "=========================================="
echo ""

# ============================================================================
# DÉMARRAGE JUPYTER LAB SANS MOT DE PASSE
# ============================================================================

cd /root
pwd
whoami

# Lancer Jupyter SANS mot de passe
exec jupyter lab \
    --allow-root \
    --no-browser \
    --ip="0.0.0.0" \
    --port=8888 \
    --IdentityProvider.token='' \
    --ServerApp.password='' \
    --ServerApp.shutdown_no_activity_timeout=1200 \
    --MappingKernelManager.cull_idle_timeout=1200 \
    --TerminalManager.cull_inactive_timeout=1200
