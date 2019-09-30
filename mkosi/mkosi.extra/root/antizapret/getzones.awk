# Skipping empty strings
(!$1) {next}

# Exclude some domains
(/duckdns/) {next}
(/\.r\.cloudfront\.net/) {next}

# Skipping IP addresses
(/^([0-9]{1,3}\.){3}[0-9]{1,3}$/) {next}

# Removing leading "www."
{gsub(/^www\./, "", $1)}

{
 if (/\.(ru|co|cu|com|info|net|org|gov|edu|int|mil|biz|pp|ne|msk|spb|nnov|od|in|ho|cc|dn|i|tut|v|dp|sl|ddns|dyndns|livejournal|herokuapp|azurewebsites|cloudfront|ucoz|3dn|nov|linode|amazonaws|sl-reverse|kiev|beget|kirov|akadns|scaleway)\.[^.]+$/)
  {$1 = gensub(/(.+)\.([^.]+\.[^.]+\.[^.]+$)/, "\\2", 1)}
 else
  {$1 = gensub(/(.+)\.([^.]+\.[^.]+$)/, "\\2", 1)}
}

# Sorting domains
{d_other[$1] = $1}

function printarray(arrname, arr) {
    for (i in arr) {
        print i
    }
}

# Final function
END {
    printarray("d_other", d_other)
}