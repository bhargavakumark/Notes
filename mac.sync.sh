#!/bin/bash

# This script syncs various things into mac

function download_firefox
{
    [ -z "$1" -o -z "$2" ] && {
        echo "Usage download_firefox <src> <local-file-path>"
        return 1
    }
    curl -o "${2}.new" -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:122.0) Gecko/20100101 Firefox/122.0' -H 'Accept: image/avif,image/webp,*/*' -H 'Accept-Language: en-US,en;q=0.5'  -H 'Referer: https://nsearchives.nseindia.com/' -H 'DNT: 1' -H 'Connection: keep-alive' -H 'Sec-Fetch-Dest: image' -H 'Sec-Fetch-Mode: no-cors' -H 'Sec-Fetch-Site: same-site' -H 'Sec-GPC: 1' -H 'Pragma: no-cache' -H 'Cache-Control: no-cache' "$1" && mv "${2}.new" "${2}"
}

function pull_nse_debt
{
    while :; do
        download_firefox https://nsearchives.nseindia.com/content/equities/DEBT.csv ~/zerodha/nse.debt.csv
        download_firefox https://nsearchives.nseindia.com/content/equities/eq_etfseclist.csv ~/zerodha/nse.etf.csv
        download_firefox https://nsearchives.nseindia.com/content/equities/EQUITY_L.csv ~/zerodha/nse.equity.csv
        download_firefox https://nsearchives.nseindia.com/emerge/corporates/content/SME_EQUITY_L.csv ~/zerodha/nse.sme.csv
        sleep 86400
    done
}

pull_nse_debt &

echo "Started all background sync"

wait
