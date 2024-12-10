#!/bin/bash

# This script syncs various things into mac

function download_firefox {
    [ -z "$1" -o -z "$2" ] && {
        echo "Usage download_firefox <src> <local-file-path>"
        return 1
    }
    curl -o "${2}.new" -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:122.0) Gecko/20100101 Firefox/122.0' -H 'Accept: image/avif,image/webp,*/*' -H 'Accept-Language: en-US,en;q=0.5'  -H 'Referer: https://nsearchives.nseindia.com/' -H 'DNT: 1' -H 'Connection: keep-alive' -H 'Sec-Fetch-Dest: image' -H 'Sec-Fetch-Mode: no-cors' -H 'Sec-Fetch-Site: same-site' -H 'Sec-GPC: 1' -H 'Pragma: no-cache' -H 'Cache-Control: no-cache' "$1" && mv "${2}.new" "${2}"
}

function pull_nse
{
    while :; do
        download_firefox https://nsearchives.nseindia.com/content/equities/DEBT.csv ~/zerodha/nse.debt.csv
        download_firefox https://nsearchives.nseindia.com/content/equities/eq_etfseclist.csv ~/zerodha/nse.etf.csv
        download_firefox https://nsearchives.nseindia.com/content/equities/EQUITY_L.csv ~/zerodha/nse.equity.csv
        download_firefox https://nsearchives.nseindia.com/emerge/corporates/content/SME_EQUITY_L.csv ~/zerodha/nse.sme.csv
        sleep 86400
    done
}

function download_bse
{
    [ -z "$1" -o -z "$2" ] && {
        echo "Usage download_bse <src> <local-file-path>"
        return 1
    }
    curl -o "$2" -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:122.0) Gecko/20100101 Firefox/122.0' -H 'Accept: image/avif,image/webp,*/*' -H 'Accept-Language: en-US,en;q=0.5'  -H 'Referer: https://nsearchives.nseindia.com/' -H 'DNT: 1' -H 'Connection: keep-alive' -H 'Sec-Fetch-Dest: image' -H 'Sec-Fetch-Mode: no-cors' -H 'Sec-Fetch-Site: same-site' -H 'Sec-GPC: 1' -H 'Pragma: no-cache' -H 'Cache-Control: no-cache' "$1"
}

function download_bse_csv
{
    [ -z "$1" -o -z "$2" ] && {
        echo "Usage download_bse <src> <local-file-prefix>"
        return 1
    }
    local basefilename=$(basename "$1")
    local basename="${basefilename/_CSV.ZIP/.csv}"
    basename="${basename/.zip/.csv}"
    download_bse "$1" ~/zerodha/"${basefilename}" && {
        pushd ~/zerodha
        yes | unzip ~/zerodha/"${basefilename}" && mv ~/zerodha/"${basename}" ~/zerodha/"${2}".csv
        rm ~/zerodha/"${basefilename}"
        popd
    }
}

function pull_bse
{
    while :; do
        set -x
        # These URLs are from https://www.bseindia.com/markets/equity/EQReports/Equitydebcopy.aspx
        download_bse_csv https://www.bseindia.com/download/BhavCopy/Equity/EQ_ISINCODE_230224.zip "bse.equity"
        download_bse_csv https://www.bseindia.com/download/Bhavcopy/Debt/DEBTBHAVCOPY23022024.zip "bse.debt"
        break
        sleep 86400
    done
}

pull_nse &
#pull_bse

echo "Started all background sync"

wait
