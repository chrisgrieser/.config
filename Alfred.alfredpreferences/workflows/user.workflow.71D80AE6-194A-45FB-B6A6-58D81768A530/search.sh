#!/bin/zsh --no-rcs

readonly sqlQuery="SELECT r.ZFIRSTNAME, r.ZMIDDLENAME, r.ZLASTNAME, r.ZMAIDENNAME, r.ZNICKNAME, r.ZJOBTITLE, r.ZORGANIZATION, r.ZSORTINGLASTNAME, r.ZUNIQUEID, JSON_GROUP_ARRAY(p.ZFULLNUMBER) AS ZPHONENUMBER, JSON_GROUP_ARRAY(e.ZADDRESSNORMALIZED) AS ZEMAILADDRESS, a.ZSTREET, n.ZTEXT
FROM ZABCDRECORD r
LEFT JOIN ZABCDPHONENUMBER p ON p.ZOWNER = r.Z_PK
LEFT JOIN ZABCDEMAILADDRESS e ON e.ZOWNER = r.Z_PK
LEFT JOIN ZABCDPOSTALADDRESS a ON a.ZOWNER = r.Z_PK
LEFT JOIN ZABCDNOTE n ON n.ZCONTACT = r.Z_PK
GROUP BY r.ZUNIQUEID;"

# Load Contacts
find "${contacts_dir}" -name "AddressBook-v22.abcddb" -exec sqlite3 -json {} "${sqlQuery}" \; |
jq -cs \
   --argjson useJobTitle "${useJobTitle}" \
   --argjson useOrganization "${useOrganization}" \
   --argjson usePhone "${usePhone}" \
   --argjson useEmail "${useEmail}" \
   --argjson useStreet "${useStreet}" \
   --argjson useNotes "${useNotes}" \
   --argjson sortBy "${sortBy}" \
'{
    "items": (if (length > 0) then walk(if . == "" then null end) |
    map(.[] | select(.ZUNIQUEID | endswith("ABPerson")) |
        (.ZPHONENUMBER | fromjson | join(" ") | gsub("(\\(|\\))"; "")) as $PHONES |
        (.ZEMAILADDRESS | fromjson | join(" ")) as $EMAILS |
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
                (if $usePhone == 1 then ($PHONES | .+" "+gsub("[^0-9]"; "")) else empty end),
                (if $useEmail == 1 then $EMAILS else empty end),
                (if $useStreet == 1 then .ZSTREET else empty end),
                (if $useNotes == 1 then .ZTEXT else empty end)
            ] | map(select(.)) | join(" "),
            "sortindex": (if $title != "No Name" then (if $sortBy == 0 then $title else .ZSORTINGLASTNAME end) else "~" end)
    	}
    ) | sort_by(.sortindex) else
        [{ "title": "Search Contacts...","subtitle": "No contacts found","valid": "false" }]
    end)
}'
