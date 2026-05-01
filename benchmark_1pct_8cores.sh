#!/bin/bash
#SBATCH --job-name=matsim_1pct_8cores
#SBATCH --partition=barnard
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --time=08:00:00
#SBATCH --exclusive
#SBATCH --output=/home/bada220h/MATSim/matsim-dresden-hpc-benchmark/logs/benchmark_1pct_4cores_%j.out
#SBATCH --error=/home/bada220h/MATSim/matsim-dresden-hpc-benchmark/logs/benchmark_1pct_4cores_%j.err

# Environment
module load Java

SCRIPT_DIR=/home/bada220h/MATSim/matsim-dresden-hpc-benchmark
mkdir -p "$SCRIPT_DIR/runs"
mkdir -p "$SCRIPT_DIR/logs"
CORES=8
CONFIG="$SCRIPT_DIR/local-input/v1.0/dresden-v1.0-1pct.local.config.xml"
OUTDIR="$SCRIPT_DIR/runs/dresden-1pct-${CORES}cores"
JAR="$SCRIPT_DIR/matsim-dresden-*.jar"

# Prepare output directory
mkdir -p "$OUTDIR"

# Patch output directory and thread counts in config
LOCAL_CONFIG="$SCRIPT_DIR/local-input/v1.0/dresden-v1.0-1pct-${CORES}cores.local.config.xml"
cp "$CONFIG" "$LOCAL_CONFIG"

sed -i "s|<param name=\"outputDirectory\" value=\"[^\"]*\"|<param name=\"outputDirectory\" value=\"$OUTDIR\"|g" "$LOCAL_CONFIG"
sed -i "s|<param name=\"numberOfThreads\" value=\"[^\"]*\"|<param name=\"numberOfThreads\" value=\"$CORES\"|g" "$LOCAL_CONFIG"

# Print job info
echo "Job ID        : $SLURM_JOB_ID"
echo "Node          : $SLURMD_NODENAME"
echo "Cores         : $CORES"
echo "Config        : $LOCAL_CONFIG"
echo "Output dir    : $OUTDIR"
echo "Start time    : $(date)"
echo "---"

# Run MATSim
java -Xmx28g -Djava.awt.headless=true \
     -jar $JAR \
     --config "$LOCAL_CONFIG"

echo "---"
echo "End time      : $(date)"
echo "Exit code     : $?"
