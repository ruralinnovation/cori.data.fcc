echo "$(pwd)"

# Set memory limits
ulimit -d 8388608  # Data segment size limit in kilobytes
ulimit -v 12582912  # Virtual memory limit in kilobytes

nohup Rscript data-raw/nbm_block.R > process_nbm.log 2>&1 &

PID=$!

echo "The PID of the started process is: $PID"

cpulimit -p $PID -l 50 &

echo "Watch with: tail -f $(pwd)/process_nbm.log"
