PYTHONIOENCODING=utf-8 chcp 65001 > /dev/null && \
python scripts/devel/21_backup_pre_retrieve.py 2>&1 | tee "$logfile"
