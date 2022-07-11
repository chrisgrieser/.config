<?php

function ot($request) {

	$url = "http://www.openthesaurus.de/synonyme/search?q=" . $request . "&format=application/json";

	$defaults = array(
		CURLOPT_RETURNTRANSFER => true,
		CURLOPT_URL => $url,
		CURLOPT_FRESH_CONNECT => true
	);

	$ch  = curl_init();
	curl_setopt_array($ch, $defaults);
	$out = curl_exec($ch);
	$err = curl_error($ch);
	curl_close($ch);

	$result = '<?xml version="1.0" encoding="utf-8"?><items>';

	$json = json_decode($out);

	if(empty($json->synsets)) {
		$result .= '<item uid="synonym">';
		$result .= '<title>No result found!</title>';
		$result .= '<icon>icon.png</icon>';
		$result .= '</item>';
	}
	else {
		$syns = array();
		foreach($json->synsets as $item) {
			foreach($item->terms as $itm) {
				$itm->term = clean_utf8($itm->term);
				if(!in_array($itm->term, $syns) && (strtolower($itm->term) != strtolower($request))) {
					array_push($syns, $itm->term);
					$result .= '<item uid="' . $itm->term . '" arg="' . $itm->term . '">';
					$result .= '<title>' . $itm->term . '</title>';
					$result .= '<icon>icon.png</icon>';
					$result .= '</item>';
				}
			}
		}
	}
	
	$result .= '</items>';
	echo $result;
}

function clean_utf8($string) {
	return iconv('UTF-8-Mac', 'UTF-8', $string);
}

?>