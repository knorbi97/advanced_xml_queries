(: A lekérdezés eredménye egy JSON dokumentum melynek gyökéreleme egy tömb.      :)
(: Tartalmazza azon körözések címét és a körözésekhez tartozó egyedi azonosítót, :)
(: amelyekhez tartozó személyek feltehetően Maryland államban tartózkodnak.      :)
(: Az eredmény dokumentumban az objektumok cím szerint lexikografikus sorrendbe  :)
(: vannak rendezve.                                                              :)

xquery version "3.1";

declare namespace map = "http://www.w3.org/2005/xpath-functions/map";
declare namespace array = "http://www.w3.org/2005/xpath-functions/array";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

declare option output:method "json";
declare option output:indent "yes";

declare function local:get-wanteds-by-possible-state($wanteds as item()*, $possible-state as xs:string) as item()*
{
    array:flatten(for $wanted in $wanteds
                  order by $wanted?title
                  where not(fn:empty($wanted?possible_states[. = $possible-state]))
                  return map {
                      "title": $wanted?title,
                      "uid": $wanted?uid
                  })
};

let $wanteds := array:flatten(fn:json-doc("merged.json"))
return array { local:get-wanteds-by-possible-state($wanteds, "US-MD") }