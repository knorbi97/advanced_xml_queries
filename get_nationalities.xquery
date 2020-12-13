(: A lekérdezés eredménye egy JSON dokumentum melynek gyökéreleme egy tömb.       :)
(: Tartalmazza, hogy nemzetiség szerint hány körözött személy van az FBI API-ban. :)

xquery version "3.1";

declare namespace map = "http://www.w3.org/2005/xpath-functions/map";
declare namespace array = "http://www.w3.org/2005/xpath-functions/array";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

declare option output:method "json";
declare option output:indent "yes";

declare function local:get-nationalities($wanteds as item()*) as item()*
{
    fn:distinct-values(for $wanted in $wanteds
                       where fn:not(fn:empty($wanted?nationality)) and
                             $wanted?nationality != "" and
                             $wanted?nationality != "Unknown"
                       return $wanted?nationality)
};

declare function local:get-unknown-nationalities(
    $nationalities as map(xs:string, item())*,
    $wanteds as item()*
) as map(xs:string, item())*
{
    let $count := fn:count($wanteds[fn:empty(?nationality) or ?nationality = "" or ?nationality = "Unknown"])
    return ($nationalities, map {
        "nationality": "Unknown",
        "count": $count
    })
};

declare function local:get-nationalities-with-count($wanteds as item()*) as item()*
{
    array:flatten(local:get-unknown-nationalities(
      (for $nationality in local:get-nationalities($wanteds)
      let $count := fn:count($wanteds[?nationality = $nationality])
      return map {
          "nationality": $nationality,
          "count": $count
      }),
      $wanteds)
    )
};

let $wanteds := array:flatten(fn:json-doc("merged.json"))
return array { local:get-nationalities-with-count($wanteds) }