(: A lekérdezés eredménye egy JSON dokumentum melynek gyökéreleme egy tömb, :)
(: amely tartalmazza az FBI API-ban található körözött személyek adatait.   :)

xquery version "3.1";

declare namespace array = "http://www.w3.org/2005/xpath-functions/array";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

declare option output:method "json";
declare option output:indent "yes";

declare function local:get-pages($api-address as xs:string, $page-number as xs:integer) as item()* {
    let $page-content := json-doc($api-address || "?page=" || string($page-number))
    return
        if (array:size($page-content?items) = 0) then ()
        else array:flatten(($page-content?items, local:get-pages($api-address, $page-number + 1)))
};

let $arr := array {local:get-pages("https://api.fbi.gov/wanted/v1/list", 1)}
return $arr