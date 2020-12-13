(: A lekérdezés eredménye egy szekvencia. Tartalmazza azokat a körözés címeket, :)
(: melyekhez köthető személyeknek van a legtöbb álneve.                         :)

xquery version "3.1";

declare namespace array = "http://www.w3.org/2005/xpath-functions/array";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

declare option output:method "text";

let $wanteds := array:flatten(fn:json-doc("merged.json"))
let $max-aliases := (for $wanted in $wanteds
                    return fn:count(array:flatten($wanted?aliases))) => fn:max()
return $wanteds[fn:count(array:flatten(?aliases)) = $max-aliases]?title