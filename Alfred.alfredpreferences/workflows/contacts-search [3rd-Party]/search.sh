#!/bin/zsh --no-rcs

readonly sqlQuery="SELECT r.ZFIRSTNAME, r.ZMIDDLENAME, r.ZLASTNAME, r.ZMAIDENNAME, r.ZNICKNAME, r.ZJOBTITLE, r.ZORGANIZATION, r.ZSORTINGLASTNAME, r.ZUNIQUEID,
(SELECT JSON_GROUP_ARRAY(p.ZFULLNUMBER) FROM ZABCDPHONENUMBER p WHERE p.ZOWNER = r.Z_PK) AS ZPHONENUMBER,
(SELECT GROUP_CONCAT(e.ZADDRESSNORMALIZED, ' ') FROM ZABCDEMAILADDRESS e WHERE e.ZOWNER = r.Z_PK) AS ZEMAILADDRESS,
(SELECT GROUP_CONCAT(a.ZSTREET, ' ') FROM ZABCDPOSTALADDRESS a WHERE a.ZOWNER = r.Z_PK) AS ZSTREET,
(SELECT GROUP_CONCAT(n.ZTEXT, ' ') FROM ZABCDNOTE n WHERE n.ZCONTACT = r.Z_PK) AS ZTEXT
FROM ZABCDRECORD r
WHERE r.ZUNIQUEID LIKE '%ABPerson';"

# Load Contacts
dbs=("${contacts_dir}"/**/"AddressBook-v22.abcddb"(N))
for db in "${dbs[@]}"; do
    dir="${db:h}"
    sqlite3 -json "${db}" "SELECT '${dir//\'/\'\'}' as ABpath, ${sqlQuery#SELECT}"
done |
jq -cs \
   --argjson useJobTitle "${useJobTitle}" \
   --argjson useOrganization "${useOrganization}" \
   --argjson usePhone "${usePhone}" \
   --argjson useEmail "${useEmail}" \
   --argjson useStreet "${useStreet}" \
   --argjson useNotes "${useNotes}" \
   --argjson sortBy "${sortBy}" \
'{
    "items": (if (length > 0) then
    map(.[] |
        (if (.ZORGANIZATION != null and .ZFIRSTNAME == null and .ZLASTNAME == null) then false else true end) as $isNotORG |
        (if (.ZORGANIZATION == null and .ZFIRSTNAME == null and .ZLASTNAME == null) then "No Name" elif $isNotORG then ([.ZFIRSTNAME, .ZLASTNAME] | map(select(.)) | join(" ")) else .ZORGANIZATION end) as $title |
    	{
	        "title": "\($title) \(.ZNICKNAME | if . then "("+.+")" else "" end)",
            "subtitle": (if $isNotORG then ([.ZJOBTITLE, .ZORGANIZATION] | map(select(.)) | join(" • ")) else "" end),
            "arg": .ZUNIQUEID,
            "icon": { "path": "images/VCard.png" },
            "match": [
                $title, .ZMIDDLENAME, .ZMAIDENNAME, .ZNICKNAME,
                (if $useJobTitle == 1 then .ZJOBTITLE else empty end),
                (if $useOrganization == 1 then .ZORGANIZATION else empty end),
                (if $usePhone == 1 then (
                    .ZPHONENUMBER | fromjson[] // empty |
                    gsub("[()]"; "")+" "+gsub("[^0-9]"; "")+" "+gsub("\\+[0-9]+ |[^0-9]"; "")
                ) else empty end),
                (if $useEmail == 1 then .ZEMAILADDRESS else empty end),
                (if $useStreet == 1 then .ZSTREET else empty end),
                (if $useNotes == 1 then .ZTEXT else empty end)
            ] | map(select(.)) | join(" "),
            "variables": {"ABpath": .ABpath},
            "sortindex": (if $title != "No Name" then (if $sortBy == 0 then $title else .ZSORTINGLASTNAME end) else "~" end)
    	}
    ) | sort_by(.sortindex) else
        [{ "title": "Search Contacts...","subtitle": "No contacts found","valid": "false" }]
    end)
}'
