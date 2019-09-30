#!/bin/bash
set -e

HERE="$(dirname "$(readlink -f "${0}")")"
cd "$HERE"

# Extract domains from list
awk -F ';' '{print $2}' temp/list.csv | sort -u | awk '/^$/ {next} /\\/ {next} /^[a-zA-Z0-9\-\_\.\*]*+$/ {gsub(/\*\./, ""); print}' | idn > result/hostlist_original.txt

# Generate zones from domains
# FIXME: nxdomain list parsing is disabled due to its instability on z-i
###cat exclude.txt temp/nxdomain.txt > temp/exclude.txt
cat exclude.txt > temp/exclude.txt

cat include.txt result/hostlist_original.txt > temp/hostlist_original_with_include.txt
awk -f getzones.awk temp/hostlist_original_with_include.txt | grep -v -F -x -f temp/exclude.txt | sort -u > result/hostlist_zones.txt
# Generate a list of IP addresses
awk -F ';' '($1 ~ /^([0-9]{1,3}\.){3}[0-9]{1,3}/) {gsub(/ \| /, RS, $1); print $1}' temp/list.csv | sort -u > result/iplist_all.txt
awk -F ';' '($1 ~ /^([0-9]{1,3}\.){3}[0-9]{1,3}/) && (($2 == "" && $3 == "") || ($1 == $2)) {gsub(/ \| /, RS); print $1}' temp/list.csv | sort -u > result/iplist_blockedbyip.txt

awk -F ';' '$1 ~ /\// {print $1}' temp/list.csv | egrep -o '([0-9]{1,3}\.){3}[0-9]{1,3}\/[0-9]{1,2}' | sort -u > result/blocked-ranges.txt

echo -n > result/openvpn-blocked-ranges.txt
while read -r line
do
    C_NET="$(echo $line | awk -F '/' '{print $1}')"
    C_NETMASK="$(ipcalc -bn "$line" | awk '/Netmask/ {print $2}')"
    echo $"push \"route ${C_NET} ${C_NETMASK}\"" >> result/openvpn-blocked-ranges.txt
done < result/blocked-ranges.txt

# Generate dnsmasq aliases
echo -n > result/dnsmasq-aliases-alt.conf
while read -r line
do
    echo "server=/$line/127.0.0.4" >> result/dnsmasq-aliases-alt.conf
done < result/hostlist_zones.txt


# Generate knot-resolver aliases
echo 'blocked_hosts = {' > result/knot-aliases-alt.conf
while read -r line
do
    line="$line."
    echo "${line@Q}," >> result/knot-aliases-alt.conf
done < result/hostlist_zones.txt
echo '}' >> result/knot-aliases-alt.conf


# Generate squid zone file
echo -n > result/squid-whitelist-zones.conf
while read -r line
do
    echo ".$line" >> result/squid-whitelist-zones.conf
done < result/hostlist_zones.txt
